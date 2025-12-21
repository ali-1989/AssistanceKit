// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:assistance_kit/date_formatter/src/duration/local_date.dart';
import 'local_time.dart';

class DurationFormatter {
  DurationFormatter._();

  static String duration(Duration? duration, {bool showSuffix = true}) {
    if (duration == null) {
      return '';
    }

    if (duration.inHours >= 1) {
      // h:mm
      return '${duration.inHours}'
          ':'
          '${(duration.inMinutes % 60).toString().padLeft(2, '0')}'
          '${(showSuffix ? ' min' : '')}';
    } else {
      return '${duration.inMinutes.toString()}'
          ':${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
          '${(showSuffix ? ' secs' : '')}';
    }
  }

  static String localDate(LocalDate date, [String pattern = 'yyyy/MM/dd']) {
    return DateFormat(pattern).format(date.toDateTime());
  }

  static String dateTime(DateTime date, [String pattern = 'yyyy/MM/dd h:ss a']) {
    return DateFormat(pattern).format(date);
  }

  static String formatNice(DateTime when) {
    var today = LocalDate.today();
    var whenDate = LocalDate.fromDateTime(when);

    if (whenDate.isEqual(today)) {
      // for today just the time.
      return dateTime(when, 'h:mm a');
    } else if (whenDate.add(Duration(days: 7)).isAfter(today)) {
      // use the day name for the last 7 days.
      return dateTime(when, 'EEEE h:mm a');
    } else {
      return dateTime(when, 'dd MMM h:mm a');
    }
  }

  static String smartFormat(DateTime date, [String pattern = 'yyyy/MM/dd h:ss a']) {
    return DateFormat(pattern).format(date);
  }

  static String time(DateTime date, [String pattern = 'h:mm:ss a']) {
    return DateFormat(pattern).format(date);
  }

  static String localTime(LocalTime time, [String pattern = 'h:mm:ss a']) {
    return DurationFormatter.time(time.toDateTime(), pattern);
    // AMPMParts parts = AMPMParts.fromLocalTime(time);

    // return parts.hour.toString() +
    //     ':' +
    //     parts.minute.toString().padLeft(2, '0') +
    //     (parts.am ? ' am' : ' pm');
  }

  static String toProperCase(String name) {
    var parts = name.split(' ');

    var result = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      var word = parts[i];
      if (word.length == 1) {
        word = word.toUpperCase();
      } else if (word.length > 1) {
        word = word.substring(0, 1).toUpperCase() +
            word.substring(1).toLowerCase();
      }

      if (result.length > 0) result.write(' ');

      result.write(word);
    }
    return result.toString();
  }
  
  static String onDate(LocalDate date, {bool abbr = false}) {
    String message;

    if (date.isEqual(LocalDate.today())) {
      // not certain this variation makes much sense?
      message = abbr ? 'today' : 'later today';
    } else if (date.addDays(-1).isEqual(LocalDate.today())) {
      message = 'tomorrow';
    } else if (date.addDays(-7).isBefore(LocalDate.today())) {
      if (abbr) {
        message = DateFormat('EEE.').format(date.toDateTime());
      } else {
        message = 'on ${DateFormat('EEEE').format(date.toDateTime())}';
      }
    } else if (date.addDays(-364).isBefore(LocalDate.today())) {
      var ordinal = getDayOrdinal(date);
      if (abbr) {
        var format = '''d'$ordinal' MMM.''';
        message = DateFormat(format).format(date.toDateTime());
      } else {
        var format = '''d'$ordinal' 'of' MMMM''';
        message = 'on the ${DateFormat(format).format(date.toDateTime())}';
      }
    } else {
      message = 'on the ${DurationFormatter.localDate(date)}';
    }
    return message;
  }

  static String getDayOrdinal(LocalDate date) {
    var day = date.day % 10;

    var ordinal = 'th';

    if (day == 1) {
      ordinal = 'st';
    } else if (day == 2) {
      ordinal = 'nd';
    } else if (day == 3) ordinal = 'rd';

    return ordinal;
  }
}
