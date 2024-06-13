import 'dart:async';
import 'dart:math';
import 'package:assistance_kit/api/generator.dart';
import 'package:assistance_kit/dateSection/ADateStructure.dart';
import 'package:assistance_kit/dateSection/time_zone.dart';

part 'package:assistance_kit/cron_job/cron_job.dart';
part 'package:assistance_kit/cron_job/utils.dart';

class CronJobs {
  static final List<Job> _jobList = [];
  static int _serviceStartInMills = 0;
  static bool _isStarted = false;
  static late Timer _timer;
  static bool debugMode = false;


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

  // timezone: "Asia/Tehran"
  static Job createExactCronJob(String timezone, int hour, int min, Duration interval, VoidTask task) {
    final gr = GregorianDate();
    final timeZoneCurrent = TimeZone.getDateTimeZoned(timezone, gr.getDaylightState());

    final now = GregorianDate.from(timeZoneCurrent);
    now.attachTimeZone(timezone);
    now.changeTime(hour, min, 0, 0);
    now.moveLocalToUTC();

    final utc = now.convertToSystemDate();

    final res = Job(task, interval, Duration.zero, utc);
    scheduleJob(res);
    return res;
  }

  static void start() async {
    if (_isStarted) {
      return;
    }

    _isStarted = true;

    final cur = _currentTimeMillisUtc();
    final curInSec = cur / 1000;
    final overSec = curInSec % 60;

    var wait = 0;

    if(overSec > 0){
      wait = 60 - overSec.toInt();
    }

    if(wait > 0){
      await Future.delayed(Duration(seconds: wait));
    }

    _serviceStartInMills = ((curInSec.toInt() + wait) * 1000).toInt();
    _timer = Timer.periodic(Duration(seconds: 60), _timerTick);

    if(debugMode){
      print('[CRON-JOB] started at: ${DateTime.fromMillisecondsSinceEpoch(_serviceStartInMills)} UTC. (after $wait sec waiting)');
    }
  }

  static void purgeJob(Job job) {
    job._state = JobState.purge;
    _jobList.remove(job);

    if(debugMode){
      print('[CRON-JOB] a job purged. name:${job.name} id:${job.id}');
    }

    _checkCanContinue();
  }

  static void shutdown() {
    if (!_isStarted) {
      return;
    }

    _isStarted = false;
    _timer.cancel();

    if(debugMode){
      print('[CRON-JOB] shutdown');
    }
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

        if (job.repeatedCount < 1) {
          if ((job.firstCallAt!.millisecondsSinceEpoch + job.interval.inMilliseconds) > nowInMills) {
            continue;
          }

          final firstInMin = (job.firstCallAt!.millisecondsSinceEpoch + job.interval.inMilliseconds)/60000;
          var checkInMin = nowInMills/60000;

          if (firstInMin != checkInMin) {
            while(checkInMin > firstInMin){
              checkInMin = checkInMin - job.interval.inMinutes;
            }

            if(firstInMin != checkInMin){
              continue;
            }
          }
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

        if(debugMode){
          print('[CRON-JOB] a job called. name:${job.name} id:${job.id}');
        }

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
