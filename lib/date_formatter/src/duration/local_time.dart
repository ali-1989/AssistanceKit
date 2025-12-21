// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:assistance_kit/date_formatter/src/duration/duration_formatter.dart';
import 'local_date.dart';

@immutable
class LocalTime {
  final int hour;
  final int minute;
  final int second;

  const LocalTime({required this.hour, required this.minute, this.second = 0});

  LocalTime.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second;

  DateTime toDateTime() {
    var now = DateTime.now();

    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  static DateTime stripDate(DateTime dateTime) {
    return DateTime(0, 0, 0, dateTime.hour, dateTime.minute, dateTime.second,
        dateTime.millisecond, dateTime.microsecond);
  }

  static LocalTime now() {
    var now = DateTime.now();

    return LocalTime(hour: now.hour, minute: now.minute, second: now.second);
  }

  LocalTime addDuration(Duration duration) {
    return LocalTime.fromDateTime(toDateTime().add(duration));
  }

  bool isAfter(LocalTime rhs) {
    return hour > rhs.hour ||
        (hour == rhs.hour && minute > rhs.minute) ||
        (hour == rhs.hour && minute == rhs.minute && second > rhs.second);
  }

  bool isAfterOrEqual(LocalTime rhs) {
    return isAfter(rhs) || isEqual(rhs);
  }

  bool isBefore(LocalTime rhs) {
    return !isAfter(rhs) && !isEqual(rhs);
  }

  bool isBeforeOrEqual(LocalTime rhs) {
    return isBefore(rhs) || isEqual(rhs);
  }

  bool isEqual(LocalTime rhs) {
    return hour == rhs.hour && minute == rhs.minute && second == rhs.second;
  }

  DateTime atDate(LocalDate date) {
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  @override
  String toString() {
    return DurationFormatter.localTime(this);
  }
}
