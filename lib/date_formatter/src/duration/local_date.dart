// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'local_time.dart';

@immutable
class LocalDate {
  final DateTime date;
  int get weekday => date.weekday;
  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  LocalDate(int year, int month, int day)
      : date = DateTime(year, month, day, 0, 0, 0);

  LocalDate.fromDateTime(DateTime dateTime) : date = stripTime(dateTime);

  DateTime toDateTime(
      {LocalTime time = const LocalTime(hour: 24, minute: 0, second: 0)}) {
    return DateTime(
        date.year, date.month, date.day, time.hour, time.minute, time.second);
  }

  static DateTime stripTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  LocalDate.today() : date = stripTime(DateTime.now());

  LocalDate addDays(int days) {
    return LocalDate.fromDateTime(date.add(Duration(days: days)));
  }

  LocalDate subtractDays(int days) {
    return LocalDate.fromDateTime(date.subtract(Duration(days: days)));
  }

  bool isAfter(LocalDate rhs) {
    return date.isAfter(rhs.date);
  }

  bool isAfterOrEqual(LocalDate rhs) {
    return isAfter(rhs) || isEqual(rhs);
  }

  bool isBefore(LocalDate rhs) {
    return date.isBefore(rhs.date);
  }

  bool isBeforeOrEqual(LocalDate rhs) {
    return isBefore(rhs) || isEqual(rhs);
  }

  bool isEqual(LocalDate rhs) {
    return date.compareTo(rhs.date) == 0;
  }

  LocalDate add(Duration duration) {
    return LocalDate.fromDateTime(date.add(duration));
  }

  int daysBetween(LocalDate other) {
    return date.difference(other.date).inDays;
  }
}
