part of 'package:assistance_kit/cron_job/cron_jobs.dart';

typedef VoidTask = void Function();
///=============================================================================
class IntervalException implements Exception {
	String message = 'Job Interval must be bigger than 59 seconds.';

	@override
	String toString() {
		return message;
	}
}
///=============================================================================
class DelayException implements Exception {
	String message = 'Job firstDelay must be 0 or bigger than 59 seconds.';

	@override
	String toString() {
		return message;
	}
}
///=============================================================================
enum JobState {
	created,
	running,
	finish,
	stop,
	purge,
}

