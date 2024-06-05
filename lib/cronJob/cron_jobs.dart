import 'dart:async';
import 'package:assistance_kit/api/generator.dart';
import 'package:assistance_kit/dateSection/ADateStructure.dart';
import 'package:assistance_kit/dateSection/timeZone.dart';

part 'package:assistance_kit/cronJob/cron_job.dart';
part 'package:assistance_kit/cronJob/utils.dart';

class CronJobs {
  static final List<Job> _jobList = [];
  static int _serviceStartInMills = 0;
  static bool _isStarted = false;
  static late Timer _timer;

  static void scheduleJob(Job job) {
    if(!_jobList.contains(job)){
      _jobList.add(job);
    }

    job.start();
  }

  static Job createCronJob(Duration interval, VoidTask task) {
    final job = Job.start(task, interval);
    scheduleJob(job);
    return job;
  }

  static Job createCronJobDelay(Duration firstDelay, Duration interval, VoidTask task) {
    final job = Job.delay(task, firstDelay, interval);
    scheduleJob(job);
    return job;
  }

  // "Asia/Tehran"
  static Job createExactCronJob(String timezone, int hour, int min, Duration interval, VoidTask task) {
    final gr = GregorianDate();
    final timeZoneCurrent = TimeZone.getDateTimeZoned(timezone, gr.getDaylightState());

    final now = GregorianDate.from(timeZoneCurrent);
    print('/// cron > today: $gr | timeZone date: $timeZoneCurrent | now with tz: $now');
    now.attachTimeZone(timezone);
    now.changeTime(hour, min, 0, 0);
    now.moveLocalToUTC();

    /*if (now.convertToSystemDate().isBefore(DateHelper.nowMinusUtcOffset())) {
        now.moveDay(1);
      }*/

    final utc = now.convertToSystemDate();
    print('///2 cron >   utc: $utc');

    final res = Job(task, interval, Duration.zero, utc);
    scheduleJob(res);
    return res;
  }

  static void start() {
    if (_isStarted) {
      return;
    }

    _timer = Timer.periodic(Duration(seconds: 60), _timerTick);
    _serviceStartInMills = _currentTimeMillisUtc();
    _isStarted = true;
  }

  static void purgeJob(Job job) {
    job._state = JobState.purge;
    _jobList.remove(job);
    _checkCanContinue();
  }

  static void shutdown() {
    if (!_isStarted) {
      return;
    }

    _isStarted = false;
    _timer.cancel();
  }

  static void _timerTick(timer) {
    if (_jobList.isEmpty) {
      shutdown();
      return;
    }

    for (final job in _jobList) {
      if (job._state != JobState.running) {
        continue;
      }

      final nowInMills = _currentTimeMillisUtc();

      if (job.firstCallAt != null) {
        if (job.firstCallAt!.millisecondsSinceEpoch > nowInMills) {
          continue;
        }

        if (job.repeatedCount < 1 && (job.firstCallAt!.millisecondsSinceEpoch + job.interval.inMilliseconds) > nowInMills) {
          continue;
        }
      }

      if (job.startDelay.inSeconds > 0) {
        if (_serviceStartInMills + job.startDelay.inMilliseconds > nowInMills) {
          continue;
        }
      }

      if (job._lastTick + job.interval.inMilliseconds <= nowInMills) {
        if (job.mustCancelAfter > 0 && job.mustCancelAfter >= job.repeatedCount) {
          job._state = JobState.finish;
          continue;
        }

        job._repeatedCount++;
        job._lastTick = nowInMills;
        job.getTask().call();
      }
    }
  }

  static bool _checkCanContinue() {
    for (final j in _jobList) {
      if (j._state == JobState.running) {
        return true;
      }
    }

    shutdown();
    return false;
  }

  static bool contains(Job job) {
    return _jobList.contains(job);
  }

  static int _currentTimeMillisUtc(){
    var now = DateTime.now();
    var offset = now.timeZoneOffset.inMilliseconds;
    return now.millisecondsSinceEpoch - offset;
  }
}
