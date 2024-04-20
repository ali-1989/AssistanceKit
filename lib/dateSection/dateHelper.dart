import 'package:assistance_kit/dateFormatter/src/date_format_base.dart';
import 'package:assistance_kit/dateSection/timeZone.dart' as tz;

/// note: .toUtc() not change [millisecondsSinceEpoch] value

/**
    final d1 = DateTime.now();
		final d2 = DateTime.timestamp();
		final d3 = DateTime.now().toUtc();

		d2 == d3 != d1
		d1.millisecondsSinceEpoch == d2.millisecondsSinceEpoch == d3.millisecondsSinceEpoch
 */
/*
  When working with DateTime, it recommended to always use DateTime.utc if possible.
  If not possible, then avoid using the add and subtract
 */

class DateHelper {
	DateHelper._();

	static DateTime parse(String date){
		return DateTime.parse(date);
	}

	static String toTimestampIso8601(DateTime date){
		/*String s = '${date.year}-${date.month}-${date.day}T${date.hour}:${date.minute}:${date.second}.${date.millisecond}';

		if(!date.isUtc){ or timeZoneOffset != 0
			s += 'Z';
		}

		return s;*/
		return date.toIso8601String();
	}
	static DateTime now(){
		return DateTime.now();
	}

	static DateTime nowMinusUtcOffset(){
		final now = DateTime.now();
		final offset = now.timeZoneOffset.inMilliseconds;

		return DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - offset);
	}

	static DateTime nowAsUtcTz(){
		return DateTime.now().toUtc(); // same DateTime.timestamp()
	}

	static String nowToTimestamp(){
		final now = DateTime.now();
		return toTimestamp(now);
	}

	static String nowMinusUtcOffsetToTimestamp(){
		final now = nowMinusUtcOffset();
		return toTimestamp(now);
	}

	static String nowAsUtcTzToTimestamp(){
		final now = nowAsUtcTz();
		return toTimestamp(now, withTZ: true);
	}

	/// withTZ is same toUtc()
	static String toTimestamp(DateTime src, {bool withTZ = false}){
		if(withTZ) {
		  return DF.formatDate(src, [DF.yyyy, '-', DF.mm, '-', DF.dd, ' ', DF.HH, ':', DF.nn, ':', DF.ss, '.', DF.SSS, DF.z]);
		}
		else {
		  return DF.formatDate(src, [DF.yyyy, '-', DF.mm, '-', DF.dd, ' ', DF.HH, ':', DF.nn, ':', DF.ss, '.', DF.SSS]);
		}
	}

	static String toTimestampDateOnly(DateTime src){
		return DF.formatDate(src, [DF.yyyy, '-', DF.mm, '-', DF.dd]);
	}

	static String? toTimestampNullable(DateTime? src, {bool withTZ = false}){
		if(src == null) {
		  return null;
		}

		return toTimestamp(src, withTZ: withTZ);
	}


	static String toYmdHmTimestamp(DateTime src){
		return DF.formatDate(src, [DF.yyyy, '-', DF.mm, '-', DF.dd, ' ', DF.HH, ':', DF.nn]);
	}

	static DateTime millToDateTime(int mil) {
		return DateTime.fromMillisecondsSinceEpoch(mil);
	}

	static String millToTimestamp(int mil, {bool withTZ = false}){
		final now = millToDateTime(mil);

		return toTimestamp(now, withTZ: withTZ);
	}

	static String directoryName(){
		final now = nowAsUtcTz();
		return DF.formatDate(now, [DF.yyyy, '_', DF.mm, '_', DF.dd]);
	}

	static String getTimeZoneName(){
		return DateTime.now().timeZoneName;
	}

	/*static String getTimeZoneCity(){
		String tz = DateTime.now().timeZoneName;
		return tz.contains('/')? tz.split('/')[0] : "c-$tz";
	}

	static String getTimeZoneContinent(){
		String tz = DateTime.now().timeZoneName;
		return tz.contains('/')? tz.split('/')[1] : "nul-$tz";
	}*/

	static int getTimeZoneOffsetMillis(){
		return DateTime.now().timeZoneOffset.inMilliseconds;
	}

	static DateTime? timestampToSystem(String? ts){
		if(ts == null){
			return null;
		}

		try {
			return DateTime.parse(ts);
		}
		catch(e){
			return null;
		}
	}

	static DateTime? timestampToSystemToLocale(String? ts){
		try {
			return utcToLocal(DateTime.parse(ts?? ''));
		}
		catch(e){
			return null;
		}
	}

	static DateTime utcToLocal(DateTime utc){
		final timezoneOffset = utc.timeZoneOffset;
		final timeDiff = Duration(milliseconds: timezoneOffset.inMilliseconds);

		return utc.add(timeDiff);
	}

	static DateTime localPcToUtc(DateTime locale){
		final tzLocalOffset = locale.timeZoneOffset;
		var dif = tzLocalOffset.inMilliseconds;

		/* no need
		//is bug,   2:30 -> 3:30
		if(locale.month == 9 && locale.day == 22){
			d += 3600000;
		}
		*/

		if(dif > 0){
			dif *= -1;
		}

		final timeDiff = Duration(milliseconds: dif);
		return locale.add(timeDiff);
	}

	static DateTime localToUtc(DateTime locale, String srcTimezone, {bool isDayLight = false}){
		final twoResult = tz.TimeZone.getOffsetAsMillis(srcTimezone);
		
		if(twoResult == null){
			return locale;
		}
		print('---$twoResult');
		int dif;

		if(isDayLight){
			dif = twoResult.dayLight;
		}
		else {
			dif = twoResult.nonDayLight;
		}

		if(dif > 0){
			dif *= -1;
		}

		final timeDiff = Duration(milliseconds: dif);
		return locale.add(timeDiff);
	}

	static String localToUtcAsTimestamp(DateTime inp){
		return toTimestamp(localPcToUtc(inp));
	}

	// https://pub.dev/packages/flutter_native_timezone
	static DateTime serverDiff(String serverTs){
		final serverDate = DateTime.parse(serverTs);
		final localDate = DateTime.now();

		final timezoneOffset = localDate.timeZoneOffset;
		final timeDiff = Duration(milliseconds: timezoneOffset.inMilliseconds);

		return serverDate.add(timeDiff);
	}

	static Duration difference(DateTime from, DateTime to) {
		return to.difference(from);
	}

	static int daysDifference(DateTime from, DateTime to) {
		from = DateTime(from.year, from.month, from.day);
		to = DateTime(to.year, to.month, to.day);

		return to.difference(from).inDays;
		//return (to.difference(from).inHours / 24).round();
	}

	static int daysSince(DateTime from) {
		return daysDifference(from, DateTime.now().toUtc());
	}

	static int calculateAge(DateTime? birthDate, {int def = 0}) {
		if(birthDate != null) {
			final currentDate = DateTime.now();
			var age = currentDate.year - birthDate.year;
			final nowMonth = currentDate.month;
			final birthMonth = birthDate.month;

			if (birthMonth > nowMonth) {
				age--;
			} else if (nowMonth == birthMonth) {
				final day1 = currentDate.day;
				final day2 = birthDate.day;

				if (day2 > day1) {
					age--;
				}
			}

			return age;
		}

		return def;
	}

	static String formatYmd(DateTime dt){
		return DF.formatDate(dt, [DF.yyyy, '-', DF.mm, '-', DF.dd]);
	}

	static String formatYmdHm(DateTime dt){
		return DF.formatDate(dt, [DF.yyyy, '-', DF.mm, '-', DF.dd, ' ', DF.HH, ':', DF.nn]);
	}

	static String formatYmdHms(DateTime dt){
		return DF.formatDate(dt, [DF.yyyy, '-', DF.mm, '-', DF.dd, ' ', DF.HH, ':', DF.nn, ':', DF.ss]);
	}

	static bool isToday(DateTime date, {bool utc = false}){
		return isSameYmd(date,utc? nowMinusUtcOffset(): now());
	}

	static bool isSameY(DateTime d1, DateTime d2){
		return d1.year == d2.year;
	}

	static bool isSameYm(DateTime d1, DateTime d2){
		return d1.year == d2.year && d1.month == d2.month;
	}

	static bool isSameYmd(DateTime d1, DateTime d2){
		return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
	}

	static bool isBiggerYear(DateTime mustBig, DateTime base){
		return mustBig.year > base.year;
	}

	static bool isLittleYear(DateTime mustLittle, DateTime base){
		return mustLittle.year < base.year;
	}

	static bool isBiggerMonth(DateTime mustBig, DateTime base){
		return mustBig.year > base.year || mustBig.year == base.year && mustBig.month > base.month;
	}

	static bool isBiggerEqualMonth(DateTime mustBig, DateTime base){
		return mustBig.year > base.year || mustBig.year == base.year && mustBig.month >= base.month;
	}

	static bool isLittleMonth(DateTime mustLittle, DateTime base){
		return mustLittle.year < base.year || mustLittle.year == base.year && mustLittle.month < base.month;
	}

	static bool isLittleEqualMonth(DateTime mustLittle, DateTime base){
		return mustLittle.year < base.year || mustLittle.year == base.year && mustLittle.month <= base.month;
	}

	static bool isBetweenYmd(DateTime ts, DateTime date1, DateTime date2){
		var isSame = (ts.year > date1.year
				|| (ts.year == date1.year && ts.month > date1.month)
				|| (ts.year == date1.year && ts.month == date1.month && ts.day >= date1.day));

		isSame &= (ts.year < date2.year
				|| (ts.year == date2.year && ts.month < date2.month)
				|| (ts.year == date2.year && ts.month == date2.month && ts.day <= date2.day));

		return isSame;
	}

	static bool isBeforeTodayUtc(DateTime d){
		final today = DateHelper.nowMinusUtcOffset();

		return (today.year > d.year
				|| (today.year == d.year && today.month > d.month)
				|| (today.year == d.year && today.month == d.month && today.day > d.day));
	}

	static bool isBeforeEqualTodayUtc(DateTime d){
		final today = DateHelper.nowMinusUtcOffset();

		return (today.year > d.year
				|| (today.year == d.year && today.month > d.month)
				|| (today.year == d.year && today.month == d.month && today.day >= d.day));
	}

	static bool isAfterTodayUtc(DateTime d){
		final today = DateHelper.nowMinusUtcOffset();

		return (today.year < d.year
				|| (today.year == d.year && today.month < d.month)
				|| (today.year == d.year && today.month == d.month && today.day < d.day));
	}

	// minus: today < d   plus: today > d
	static int getTodayDifferentDayUtc(DateTime d){
		final today = DateHelper.nowMinusUtcOffset();

		return today.difference(d).inDays;
	}

	static bool isPastOf(DateTime? date, Duration dur){
		if(date == null){
			return true;
		}

		final future = date.add(dur);

		return DateTime.now().compareTo(future) > 0;
	}

	static bool isPastOfOrSame(DateTime? date, Duration dur){
		if(date == null){
			return true;
		}

		final future = date.add(dur);

		return DateTime.now().compareTo(future) > -1;
	}

	static int compareDatesTs(String? d1, String? d2, {bool asc = true}){
		final s1 = timestampToSystem(d1);
		final s2 = timestampToSystem(d2);

		return compareDates(s1, s2, asc: asc);
	}

	static int compareDates(DateTime? d1, DateTime? d2, {bool asc = true}){
		if(d1 == null && d2 == null){
			return 0;
		}

		if(d1 == null){
			return asc? -1: 1;
		}

		if(d2 == null){
			return asc? 1: -1;
		}

		return asc? d1.compareTo(d2) : d2.compareTo(d1);
	}
}