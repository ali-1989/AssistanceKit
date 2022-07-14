import 'package:assistance_kit/cronJob/cronJobs.dart';
import 'package:assistance_kit/cronJob/job.dart';

class JobHandler {
	late Job job;
	late JobState state;
	late int lastTick;

	JobHandler(Job j) {
		job = j;
		state = JobState.initial;
		lastTick = 0;
	}

	void start() {
		if(state == JobState.active) {
		  return;
		}

		if(!CronJobs.jobList.contains(this)) {
		  throw Exception('This job can not start, may be this is purge.');
		}

		lastTick = 0;
		state = JobState.active;

		CronJobs.start();
	}

	void stop() {
		state = JobState.finished;
		CronJobs.stop();
	}

	void purge() {
		state = JobState.finished;
		CronJobs.purgeJob(this);
	}

	Job getJob() {
		return job;
	}

	int getLastTick() {
		return lastTick;
	}
}
