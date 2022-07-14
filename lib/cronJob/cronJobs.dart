import 'package:assistance_kit/cronJob/job.dart';
import 'package:assistance_kit/cronJob/jobHandler.dart';
import 'dart:async';
import 'package:assistance_kit/api/system.dart';

class CronJobs {
    static final List<JobHandler> jobList = [];
    static int serviceStartTime = 0;
    static bool isStarted = false;
    static late Timer timer;

    static JobHandler scheduleJob(Job job) {
        init();
        var jh = JobHandler(job);
        jobList.add(jh);

        return jh;
    }

   static void init() {
    }

  static void _timerTick(timer) {
    if (jobList.isEmpty) {
      stop();
      return;
    }

    for (var j in jobList) {
      if (j.state != JobState.active) {
        continue;
      }

      var now = System.currentTimeMillisUtc();
      var job = j.getJob();

      if (job.firstTickAt != null) {
        if (job.firstTickAt!.millisecondsSinceEpoch > now) {
          continue;
        }
      }

      if (job.firstDelay > 0) {
        if (serviceStartTime + job.firstDelay > now) {
          continue;
        }
      }

      if (j.lastTick + job.getJobInterval() <= now) {
        j.lastTick = now;
        job.firstTickAt = null;
        job.firstDelay = 0;
        job.repeatCount++;

        var cancelRepeat = job.CancelAfterRepeat;

        if (cancelRepeat > 0 && job.repeatCount > cancelRepeat) {
          j.state = JobState.finished;
        }

        job.getJobTask().call();
      }
    }
  }

 static void start() {
    if (!isStarted) {
        timer = Timer.periodic(Duration(milliseconds: 60000), _timerTick);
        isStarted = true;
    }
  }

 static void purgeJob(JobHandler jh) {
    stop();
    jobList.remove(jh);
  }

 static void stop() {
    if (isStarted) {
        if (jobList.isEmpty) {
            shutdown();
        }
        else {
            for (var j in jobList) {
                if (j.state == JobState.active) {
                  return;
                }
            }

            shutdown();
        }
    }
  }

 static void shutdown() {
    isStarted = false;
    timer.cancel();

    for (var j in jobList) {
        j.state = JobState.initial;
    }
  }
}
