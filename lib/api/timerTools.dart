import 'dart:async';
import 'dart:isolate';
import 'package:assistance_kit/api/generator.dart';
import 'package:assistance_kit/api/logger/logger.dart';

class TimerTools {

	static Future wait(Duration dur) {
		return Future.delayed(dur, (){});
	}

	static Future waitThen(Duration dur, void Function() fn) {
		return Future.delayed(dur, fn);
		//Timer(dur, fn);
	}

	static Timer timer(Duration dur, void Function() fn) {
		 return Timer(dur, fn);
	}

	static Timer periodic(Duration dur, void Function(Timer timer) fn) {
		return Timer.periodic(dur, fn);
	}

	static Timer periodicUntil(Duration dur, int count, void Function(Timer timer, int tickCount) tickFn, {void Function()? onFinish}) {
		var c = 0;
		return Timer.periodic(dur, (timer){
			if(c >= count){
				timer.cancel();
				onFinish?.call();
				return;
			}

			c++;
			tickFn.call(timer, c);
		});
	}
}
///======================================================================================================
class TickTimer {
	DateTime? _begin;
	late Timer _timer;
	late Duration _duration;
	Duration? remainingTime;
	late Duration _refresh;
	bool isPaused = false;
	late StreamController<Duration> _controller;
	late int _everyTick, counter = 0;

	TickTimer(Duration duration, {Duration refresh = const Duration(milliseconds: 100), int everyTick= 1}) {
		_refresh = refresh;
		_everyTick = everyTick;
		_duration = duration;
		_controller = StreamController<Duration>(
				onListen: _onListen,
				onPause: _onPause,
				onResume: _onResume,
				onCancel: _onCancel);
	}

	Stream<Duration> get stream => _controller.stream;

	void _onListen() {
		_begin = DateTime.now();
		_timer = Timer.periodic(_refresh, _tick);
	}

	void _onPause() {
		isPaused = true;
		_timer.cancel();
	}

	void _onResume() {
		_begin = DateTime.now();
		_duration = remainingTime!;
		isPaused = false;

		_timer = Timer.periodic(_refresh, _tick);
	}

	void _onCancel() {
		if (!isPaused) {
			_timer.cancel();
		}
		// _controller.close(); // close automatically the "pipe" when the sub close it by sub.cancel()
	}

	void _tick(Timer timer) {
		counter++;
		var alreadyConsumed = DateTime.now().difference(_begin!);
		remainingTime = _duration - alreadyConsumed;

		if (remainingTime!.isNegative) {
			timer.cancel();

			_controller.close();
		}
		else {
			if (counter % _everyTick == 0) {
				_controller.add(remainingTime!);
				counter = 0;
			}
		}
	}
}
///======================================================================================================
typedef TimerTaskAction = void Function();

class TimerTaskHandler {
	late List<TimerTask> _taskList;
	late List<String> _taskNames;
	Timer? _timer;

	TimerTaskHandler(){
		_taskList = [];
		_taskNames = [];
	}

	void _wind() {
		if(_timer != null && _timer!.isActive) {
		  return;
		}

		if(_taskList.isEmpty){
			_timer?.cancel();
			return;
		}

		_timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
			var now = DateTime.now();
			var toRemove = <TimerTask>[];

			for(var t in _taskList){
				if(now.millisecondsSinceEpoch > (t.start + t.wait.inMilliseconds)) {
					toRemove.add(t);
				}
			}

			_taskList.removeWhere((v) => toRemove.contains(v));
			_taskNames.removeWhere((name) => toRemove.indexWhere((element) => element.name == name) > -1);

			if(_taskList.isEmpty) {
				_timer!.cancel();
			}

			for(var t in toRemove){
				try{
					t.action?.call();
				}
				on Exception{
					Logger.L.logToScreen('Exception in task');
				}
				catch (e){
					Logger.L.logToScreen('Error in task, $e');
				}
			}
		});
	}

	void add(TimerTask task){
		if(_taskList.contains(task) || _taskNames.contains(task.name)) {
		  return;
		}

		_taskList.add(task);
		_taskNames.add(task.name);
		task.start = DateTime.now().millisecondsSinceEpoch;

		_wind();
	}

	void cancel(TimerTask task){
		if(_taskList.remove(task)) {
			_taskNames.remove(task.name);
			_wind();
		}
	}

	bool exist(String name){
		return _taskNames.contains(name);
	}

	void clear(){
		_taskList.clear();
		_taskNames.clear();

		_wind();
	}

	void dispose(){
		for(var t in _taskList){
			if(t.runOnDispose) {
			  try{
					t.action?.call();
				}
				on Exception catch(ex){
					Logger.L.logToScreen('Exception in task, $ex');
				}
				catch (e){
					Logger.L.logToScreen('Error in task, $e');
				}
			}
		}

		_taskList.clear();
		_taskNames.clear();
	}
}
//---------------------------------------------------------------------------------------------
class TimerTask {
	late final String name;
	Duration wait;
	TimerTaskAction? action;
	late int start;
	bool runOnDispose = true;

	TimerTask(this.wait, {String? name}) : name = name?? Generator.generateKey(12);

	TimerTask.byAction(this.wait, this.action, {String? name}) : name = name?? Generator.generateKey(8);

	void setAction(TimerTaskAction fn){
		action = fn;
	}
}
///======================================================================================================
class CountTimer {
	final receivePort = ReceivePort();
	late Isolate _isolate;

	CountTimer();


	void stop() {
		receivePort.close();
		_isolate.kill(priority: Isolate.immediate);
	}

	Future<void> start(Duration initialDuration, Function(dynamic tick) onTick) async {
		receivePort.listen((message) {onTick(message);} );

		var map = {
			'port': receivePort.sendPort,
			'initial_duration': initialDuration,
		};

		_isolate = await Isolate.spawn(_entryPoint, map);
		receivePort.sendPort.send(initialDuration);
	}

	static void _entryPoint(Map map) async {
		Duration initialTime = map['initial_duration'];
		SendPort port = map['port'];

		Timer.periodic(
			Duration(seconds: 1), (timer) {
			if (timer.tick == initialTime.inSeconds) {
				timer.cancel();
				port.send(timer.tick);
				port.send('Timer finished');
			}
			else {
				port.send(timer.tick);
			}
		},
		);
	}
}
///======================================================================================================
