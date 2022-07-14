import 'package:assistance_kit/api/generator.dart';

enum JobState {
	initial,
	active,
	finished
}
///====================================================================================================
class JobTask {
	JobTask();

	late void Function() call;
}
///====================================================================================================
class Job {
	String _id;
	JobTask _task;
	int interval;
	DateTime? firstTickAt;
	int firstDelay = 0;
	int repeatCount = 0;
	int CancelAfterRepeat = 0;

	Job(this._task, this.interval, this.firstTickAt): _id = Generator.generateKey(5) {
		if(interval < 60000) {
		  throw Exception('Job Interval must be bigger than 60000 milliseconds.');
		}
	}

	factory Job.now(JobTask task, int interval) {
		return Job(task, interval, null);
	}

	factory Job.delay(JobTask task, int  firstDelay, int  interval) {
		if(firstDelay < 60000) {
			throw Exception('Job firstDelay must be bigger than 60000 milliseconds.');
		}

		var job = Job(task, interval, null);
		job.firstDelay = firstDelay;

		return job;
	}

	void changeId(String id) {
		_id = id;
	}

	String getId() {
		return _id;
	}

	JobTask getJobTask() {
		return _task;
	}

	int  getJobInterval() {
		return interval;
	}

	void setCancelAfter(int repeat) {
		CancelAfterRepeat = repeat;
	}

	int  getRepeatCount() {
		return repeatCount;
	}

	void changeJobInterval(int interval) {
		if(interval < 60000) {
		  throw Exception('Job Interval must be bigger than 60_000 milliseconds.');
		}

		this.interval = interval;
	}
}
