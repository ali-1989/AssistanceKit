import 'locale/english.dart';
import 'locale/locale.dart';

export 'locale/locale.dart';

class DF{
  DF._();

  static const String yyyy = 'yyyy';
  static const String yy = 'yy';
  static const String mm = 'mm';
  static const String m = 'm';
  static const String MM = 'MM';
  static const String M = 'M';
  static const String dd = 'dd';
  static const String d = 'd';
  static const String w = 'w';
  static const String WW = 'WW';
  static const String W = 'W';
  static const String DD = 'DD';
  static const String D = 'D';
  static const String hh = 'hh';
  static const String h = 'h';
  static const String HH = 'HH';
  static const String H = 'H';
  static const String nn = 'nn';
  static const String n = 'n';
  static const String ss = 'ss';
  static const String s = 's';
  static const String SSS = 'SSS';
  static const String S = 'S';
  static const String uuu = 'uuu'; // microsecond
  static const String u = 'u';
  static const String am = 'am';
  static const String z = 'z'; // timeZone offset
  static const String Z = 'Z'; // timeZone Name

  /// use: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ".", SSS]);
  /// use: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ".", SSS, z]);

  static String formatDate(DateTime date, List<String> formats, {Locale locale = const EnglishLocale()}) {
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
            sb.write('+'); // me change this from '-' to '+' in 1402-07-16
            sb.write(_digits((-date.timeZoneOffset.inHours) % 24, 2));
            sb.write(_digits((-date.timeZoneOffset.inMinutes) % 60, 2));
          } else {
            sb.write('-'); // me change this from '+' to '-' in 1402-07-16
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

  static String _digits(int value, int length) {
    var ret = '$value';

    if (ret.length < length) {
      ret = '0' * (length - ret.length) + ret;
    }
    return ret;
  }

  static int dayInYear(DateTime date) => date.difference(DateTime(date.year, 1, 1)).inDays;
}
