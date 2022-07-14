import 'dart:async';

/*
  if(!AppManager.timeoutCache.addTimeout('getUtcTimeOfServer', Duration(seconds: 5))){
      return Future.value(false);
    }
 */

class TimeoutCache {
  final List<String> _timers = [];

  TimeoutCache();

  void clearAll(){
    _timers.clear();
  }

  void deleteTimeout(String key){
    _timers.remove(key);
  }

  bool addTimeout(String key, Duration dur){
    if(_timers.contains(key)) {
      return false;
    }

    _timers.add(key);
    Timer(dur, (){_timers.remove(key);});

    return true;
  }

  bool existTimeout(String key){
    return _timers.contains(key);
  }
}
///===================================================================================================
class RewindCall {
  static final Map _holder = <String, RewindCall>{};
  Function? actionFn;
  Function? onStartFn;
  late Duration _waitTime;
  Timer? _timer;

  RewindCall._init(this._waitTime, {this.actionFn, this.onStartFn});

  factory RewindCall(String name, Duration waitTime, {Function? actionFn, Function? onStartFn}){
    if(_holder.containsKey(name)) {
      return _holder[name]!;
    }

    var res = RewindCall._init(waitTime, actionFn: actionFn, onStartFn: onStartFn);
    _holder[name] = res;

    return res;
  }

  void changeDelay(Duration timeDelay) {
    _waitTime = timeDelay;
  }

  void setOnStartAction(Function onStartFn) {
    this.onStartFn = onStartFn;
  }

  void setAction(Function doFn) {
    actionFn = doFn;
  }

  Timer? getTimer(){
    return _timer;
  }

  void fire() {
    if (_timer == null || !_timer!.isActive){
      onStartFn?.call();
    }

    _timer?.cancel();

    _timer = Timer(_waitTime, () {
      actionFn?.call();
      purge();
    });
  }

  void fireBy({Function? fn, Function? startFn}) {
    onStartFn = startFn?? onStartFn;
    actionFn = fn?? actionFn;

    fire();
  }

  void purge(){
    _timer?.cancel();
    actionFn = null;
    onStartFn = null;
    _holder.removeWhere((name, caller) => caller == this);
  }
  ///---------------------------------------------------------------
  static void purgeItem(String name){
    if(_holder.containsKey(name)) {
      _holder[name]!.purge();
    }
  }
}
///===================================================================================================
/*
    ManageCallInDuration o = ManageCallInDuration('updateImageAdvertising', Duration(minutes: 30));
    o.defineAction(fn);
    o.call();
 */
class ManageCallInDuration {
  static final _holder = <String, ManageCallInDuration>{};
  Function? _actionFn;
  DateTime? _lastCalledTime;
  late Duration _distanceTime;
  bool _isPurge = false;

  ManageCallInDuration._init(this._distanceTime, {Function? action}) : _actionFn = action;

  factory ManageCallInDuration(String name, Duration distance, {Function? doFn}){
    if(_holder.containsKey(name)) {
      return _holder[name]!;
    }

    var res = ManageCallInDuration._init(distance, action: doFn);
    _holder[name] = res;

    return res;
  }

  void changeDuration(Duration delay) {
    _distanceTime = delay;
  }

  void defineAction(Function action) {
    _actionFn ??= action;
  }

  void call() {
    if (_isPurge) {
      throw Exception('this OnceCallInDuration is purge.');
    }

    if (_lastCalledTime == null) {
      _lastCalledTime = DateTime.now();
      _actionFn?.call();
      return;
    }

    if (_lastCalledTime!.add(_distanceTime).isBefore(DateTime.now())) {
      _actionFn?.call();
      _lastCalledTime = DateTime.now();
    }
  }

  void purge(){
    _holder.removeWhere((name, caller) => caller == this);
    _actionFn = null;
    _isPurge = true;
  }
  ///---------------------------------------------------------------
  static void purgeItem(String name){
    if(_holder.containsKey(name)) {
      _holder[name]!.purge();
    }
  }
}
///================================================================================================
