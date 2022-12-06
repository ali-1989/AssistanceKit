import 'package:assistance_kit/dateFormatter/src/date_format_base.dart';

/// note: .toUtc() not change [millisecondsSinceEpoch] value

/*
  When working with DateTime, it recommended to always use DateTime.utc if possible.
  If not possible, then avoid using the add and subtract
 */

class DateHelper {
	DateHelper._();

	/*static DateTime parseUtc(String utcTz){
		return DateFormat().parseUtc(utcTz);
	}*/

	static DateTime getNow(){
		return DateTime.now();
	}

	static int getNowAsMillis(){
		return DateTime.now().millisecondsSinceEpoch;
	}

	static DateTime getNowToUtc(){
		final now = DateTime.now();
		final offset = now.timeZoneOffset.inMilliseconds;

		return DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - offset);
	}

	static DateTime getNowAsUtcZ(){
		return DateTime.now().toUtc();
	}

	static int getNowToUtcAsMillis(){
		final now = DateTime.now();
		final offset = now.timeZoneOffset.inMilliseconds;
		return now.millisecondsSinceEpoch - offset;
	}

	static String getNowTimestamp(){
		final now = DateTime.now();
		return formatDate(now, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
	}

	static String getNowTimestampToUtc(){
		final now = getNowToUtc();
		return formatDate(now, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
	}

	static String getTimestampUtcWithoutMill(){
		final now = getNowToUtc();
		return formatDate(now, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.000']);
	}

	static String toTimestamp(DateTime src, {bool isLocal = false}){
		if(isLocal) {
		  return formatDate(src, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS, z]);
		} else {
		  return formatDate(src, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
		}
	}

	static String toTimestampDate(DateTime src){
		return formatDate(src, [yyyy, '-', mm, '-', dd]);
	}

	static String? toTimestampNullable(DateTime? src, {bool isLocal = false}){
		if(src == null) {
		  return null;
		}

		return toTimestamp(src, isLocal: isLocal);
	}

	static String toTimestampWithoutTimezone(DateTime src){
		return formatDate(src, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
	}

	static String dateOnlyToStamp(DateTime src){
		return formatDate(src, [yyyy, '-', mm, '-', dd]);
	}

	static String toYmdHmStamp(DateTime src){
		return formatDate(src, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
	}

	static DateTime milToDateTime(int mil) {
		return DateTime.fromMillisecondsSinceEpoch(mil);
	}

	static String milToTimestamp(int mil, {bool isLocal = false}){
		final now = DateTime.fromMillisecondsSinceEpoch(mil);
		if(isLocal) {
		  return formatDate(now, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
		} else {
		  return formatDate(now, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS, z]);
		}
	}

	static String todayUtcDirectoryName(){
		final now = getNowToUtc();
		return formatDate(now, [yyyy, '_', mm, '_', dd]);
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

	static DateTime? tsToSystemDate(String? ts){
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

	static DateTime? tsToSystemDateToLocale(String? ts){
		try {
			return utcToLocal(DateTime.parse(ts?? ''));
		}
		catch(e){
			return null;
		}
	}

	static DateTime utcToLocal(DateTime utc){
		//var utcD = DateTime.now();

		final timezoneOffset = utc.timeZoneOffset;
		final timeDiff = Duration(milliseconds: timezoneOffset.inMilliseconds);

		return utc.add(timeDiff);
	}

	static DateTime localToUtc(DateTime locale){
		final tzLocalOffset = locale.timeZoneOffset;
		var d = tzLocalOffset.inMilliseconds;

		if(locale.month == 9 && locale.day == 22){ //is bug,   2:30 -> 3:30
			d += 3600000;
		}

		final timeDiff = Duration(milliseconds: -d);

		return locale.add(timeDiff);
	}

	static String localToUtcTs(DateTime inp){
		return toTimestamp(localToUtc(inp));
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
		return formatDate(dt, [yyyy, '-', mm, '-', dd]);
	}

	static String formatYmdHm(DateTime dt){
		return formatDate(dt, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
	}

	static String formatYmdHms(DateTime dt){
		return formatDate(dt, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
	}

	static bool isToday(DateTime date, {bool utc = false}){
		return isSameYmd(date,utc? getNowToUtc(): getNow());
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

	static bool isBiggerY(DateTime main, DateTime d2){
		return main.year > d2.year;
	}

	static bool isLittleY(DateTime main, DateTime d2){
		return main.year < d2.year;
	}

	static bool isBiggerM(DateTime d1, DateTime d2){
		return d1.year == d2.year && d1.month > d2.month;
	}

	static bool isLittleM(DateTime main, DateTime d2){
		return main.year == d2.year && main.month < d2.month;
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
		final today = DateHelper.getNowToUtc();

		return (today.year > d.year
				|| (today.year == d.year && today.month > d.month)
				|| (today.year == d.year && today.month == d.month && today.day > d.day));
	}

	static bool isBeforeEqualTodayUtc(DateTime d){
		final today = DateHelper.getNowToUtc();

		return (today.year > d.year
				|| (today.year == d.year && today.month > d.month)
				|| (today.year == d.year && today.month == d.month && today.day >= d.day));
	}

	static bool isAfterTodayUtc(DateTime d){
		final today = DateHelper.getNowToUtc();

		return (today.year < d.year
				|| (today.year == d.year && today.month < d.month)
				|| (today.year == d.year && today.month == d.month && today.day < d.day));
	}

	// minus: today < d   plus: today > d
	static int getTodayDifferentDayUtc(DateTime d){
		final today = DateHelper.getNowToUtc();

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
		final s1 = tsToSystemDate(d1);
		final s2 = tsToSystemDate(d2);

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