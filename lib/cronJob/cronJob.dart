import 'package:assistance_kit/cronJob/cronJobs.dart';
import 'package:assistance_kit/cronJob/job.dart';
import 'package:assistance_kit/cronJob/jobHandler.dart';
import 'package:assistance_kit/dateSection/ADateStructure.dart';
import 'package:assistance_kit/dateSection/dateHelper.dart';
import 'package:assistance_kit/dateSection/timeZone.dart';

class CronJob {
    static JobHandler createCronJob(int interval, JobTask task) {
        var job = Job.now(task, interval);
        return CronJobs.scheduleJob(job);
    }

    static JobHandler createCronJobDelay(int firstDelay, int interval, JobTask task) {
        var job = Job.delay(task, firstDelay, interval);
        return CronJobs.scheduleJob(job);
    }

    // "Asia/Tehran"
    static JobHandler createExactCronJob(String timezone, int hour, int min, int interval, JobTask fun) {
      final gr = GregorianDate();
      final timeZoneCurrent = TimeZone.getDateTimeZoned(timezone, gr.getDaylightState());

      final now = GregorianDate.from(timeZoneCurrent);
      now.attachTimeZone(timezone);
      now.changeTime(hour, min, 0, 0);
      now.moveLocalToUTC();

      /*if (now.convertToSystemDate().isBefore(DateHelper.nowMinusUtcOffset())) {
        now.moveDay(1);
      }*/

      final utc = now.convertToSystemDate();

      final res = Job(fun, interval, utc);
      return CronJobs.scheduleJob(res);
    }
}
