import 'locale/english.dart';
import 'locale/locale.dart';
export 'locale/locale.dart';

const String yyyy = 'yyyy';
const String yy = 'yy';
const String mm = 'mm';
const String m = 'm';
const String MM = 'MM';
const String M = 'M';
const String dd = 'dd';
const String d = 'd';
const String w = 'w';
const String WW = 'WW';
const String W = 'W';
const String DD = 'DD';
const String D = 'D';
const String hh = 'hh';
const String h = 'h';
const String HH = 'HH';
const String H = 'H';
const String nn = 'nn';
const String n = 'n';
const String ss = 'ss';
const String s = 's';
const String SSS = 'SSS';
const String S = 'S';
const String uuu = 'uuu';
const String u = 'u';
const String am = 'am';
const String z = 'z'; //timeZone offset
const String Z = 'Z'; //timeZoneName

/// use: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ".", SSS]);
/// use: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ".", SSS, z]);

String formatDate(DateTime date, List<String> formats, {Locale locale = const EnglishLocale()}) {
  final sb = StringBuffer();

  for (var format in formats) {
    if (format == yyyy) {
      sb.write(_digits(date.year, 4));
    } else if (format == yy) {
      sb.write(_digits(date.year % 100, 2));
    } else if (format == mm) {
      sb.write(_digits(date.month, 2));
    } else if (format == m) {
      sb.write(date.month);
    } else if (format == MM) {
      sb.write(locale.monthsLong[date.month - 1]);
    } else if (format == M) {
      sb.write(locale.monthsShort[date.month - 1]);
    } else if (format == dd) {
      sb.write(_digits(date.day, 2));
    } else if (format == d) {
      sb.write(date.day);
    } else if (format == w) {
      sb.write((date.day + 7) ~/ 7);
    } else if (format == W) {
      sb.write((dayInYear(date) + 7) ~/ 7);
    } else if (format == WW) {
      sb.write(_digits((dayInYear(date) + 7) ~/ 7, 2));
    } else if (format == DD) {
      sb.write(locale.daysLong[date.weekday - 1]);
    } else if (format == D) {
      sb.write(locale.daysShort[date.weekday - 1]);
    } else if (format == HH) {
      sb.write(_digits(date.hour, 2));
    } else if (format == H) {
      sb.write(date.hour);
    } else if (format == hh) {
      var hour = date.hour % 12;
      if (hour == 0) hour = 12;
      sb.write(_digits(hour, 2));
    } else if (format == h) {
      var hour = date.hour % 12;
      if (hour == 0) hour = 12;
      sb.write(hour);
    } else if (format == am) {
      sb.write(date.hour < 12 ? locale.am : locale.pm);
    } else if (format == nn) {
      sb.write(_digits(date.minute, 2));
    } else if (format == n) {
      sb.write(date.minute);
    } else if (format == ss) {
      sb.write(_digits(date.second, 2));
    } else if (format == s) {
      sb.write(date.second);
    } else if (format == SSS) {
      sb.write(_digits(date.millisecond, 3));
    } else if (format == S) {
      sb.write(date.second);
    } else if (format == uuu) {
      sb.write(_digits(date.microsecond, 2));
    } else if (format == u) {
      sb.write(date.microsecond);
    } else if (format == z) {
      if (date.timeZoneOffset.inMinutes == 0) {
        sb.write('Z');
      } else {
        if (date.timeZoneOffset.isNegative) {
          sb.write('-');
          sb.write(_digits((-date.timeZoneOffset.inHours) % 24, 2));
          sb.write(_digits((-date.timeZoneOffset.inMinutes) % 60, 2));
        } else {
          sb.write('+');
          sb.write(_digits(date.timeZoneOffset.inHours % 24, 2));
          sb.write(_digits(date.timeZoneOffset.inMinutes % 60, 2));
        }
      }
    } else if (format == Z) {
      sb.write(date.timeZoneName);
    }
    else {
      sb.write(format);
    }

  }  return sb.toString();

}

String _digits(int value, int length) {
  var ret = '$value';

  if (ret.length < length) {
    ret = '0' * (length - ret.length) + ret;
  }
  return ret;
}

int dayInYear(DateTime date) => date.difference(DateTime(date.year, 1, 1)).inDays;
