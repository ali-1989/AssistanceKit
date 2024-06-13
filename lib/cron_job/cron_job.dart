part of 'package:assistance_kit/cron_job/cron_jobs.dart';

class Job {
	String _id;
	String name;
	VoidTask _task;
	Duration _interval;
	final DateTime? firstCallAt;
	final Duration startDelay;
	int _repeatedCount = 0;
	int mustCancelAfter = 0;
	JobState _state = JobState.created;
	int _lastTick = 0;

	/// [firstCallAt] must be in UTC
	Job(VoidTask task, Duration interval, this.startDelay, DateTime? firstCallAt)
			: _id = Generator.generateKey(5),
				_interval = interval,
		_task = task,
	name = _generateName(5),
	firstCallAt = firstCallAt == null? null : DateTime(firstCallAt.year, firstCallAt.month, firstCallAt.day, firstCallAt.hour, firstCallAt.minute, 0, 0, 0)
	{
		if(interval < Duration(seconds: 60)) {
		  throw IntervalException();
		}

		if(startDelay != Duration.zero && startDelay < Duration(seconds: 60)) {
			throw DelayException();
		}
	}

	factory Job.start(VoidTask task, Duration interval) {
		return Job(task, interval,Duration.zero, null);
	}

	factory Job.delay(VoidTask task, Duration firstDelay, Duration interval) {
		return Job(task, interval, firstDelay,null);
	}

	String get id {
		return _id;
	}

	VoidTask getTask() {
		return _task;
	}

	Duration get interval {
		return _interval;
	}

	void setCancelAfter(int repeat) {
		mustCancelAfter = repeat;
	}

	int get repeatedCount {
		return _repeatedCount;
	}

	void changeInterval(Duration interval) {
		if(interval < Duration(seconds: 60)) {
		  throw IntervalException();
		}

		_interval = interval;
	}

	void start() {
		if(_state == JobState.running) {
			return;
		}

		if(!CronJobs.contains(this)) {
			throw Exception('This job can not start, may be this is purge.');
		}

		_lastTick = 0;
		_state = JobState.running;

		CronJobs.start();
	}

	void stop() {
		_state = JobState.stop;

		if(CronJobs.debugMode){
			print('[CRON-JOB] a job stopped. name:$name id:$id');
		}
	}

	void purge() {
		CronJobs.purgeJob(this);
	}

	DateTime? get lastTick {
		if(_lastTick < 1){
			return null;
		}

		return DateTime.fromMillisecondsSinceEpoch(_lastTick);
	}

	static String _generateName(int len){
	final s = 'abcdefghijklmnopqrstwxyzABCEFGHIJKLMNOPQRSTUWXYZ';
	var res = '';

	for(var i=0; i<len; i++) {
	final j = Random().nextInt(s.length);
	res += s[j];
	}

	return res;
	}
}
