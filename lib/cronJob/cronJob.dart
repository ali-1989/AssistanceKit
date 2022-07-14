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
    static JobHandler createExactCronJob(String timezone, int hour, int min, int interval, JobTask fun, bool startNow) {
        var dt = TimeZone.getDateTimeZoned(timezone);

        var check = GregorianDate.from(dt);
        check.attachTimeZone(timezone);
        check.changeTime(hour, min, 0, 0);

        var now = GregorianDate.from(dt);
        now.attachTimeZone(timezone);

        if (!startNow) {
            if (now.isAfterEqual(check)) {
              now.moveDay(1);
            }
        }

        now.changeTime(hour, min, 0, 0);
        var cal = now.convertToSystemDate();
        cal = DateHelper.localToUtc(cal);

        var res = Job(fun, interval, cal);
        return CronJobs.scheduleJob(res);
    }
}
