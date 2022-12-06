part of 'ADateStructure.dart';

class SolarHijriDate extends ADateStructure {
  static final List<String> monthNameInLatin = ['', 'FARVARDIN', 'ORDIBEHESHT', 'KHORDAD', 'TIR', 'MORDAD', 'SHAHRIVAR', 'MEHR', 'ABAN', 'AZAR', 'DEY', 'BAHMAN', 'ESFAND'];
  static final List<String> monthNameInPersian = ['', 'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];
  static final List<String> weekDayNameInLatin = ['SHANBE', 'YEK SHANBE', 'DU SHANBE', 'SE SHANBE', 'CHAHAR SHANBE', 'PANJ SHANBE', 'JOME'];
  static final List<String> weekDayNameInPersian = ['شنبه', 'یک شنبه', 'دو شنبه', 'سه شنبه', 'چهار شنبه', 'پنج شنبه', 'جمعه'];
  static final List<int> solarMonths = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
  static final List<int> solarMonthsLeap = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30];

  SolarHijriDate() {
    var dt = DateTime.now();
    var days = _convertDateTimeToDays(dt);
    var date = _convertGregorianDaysToSolar(days).getValue();
    _setValue(date);
    changeTime(dt.hour, dt.minute, dt.second, dt.microsecond);
  }

  SolarHijriDate.by(int solarHijriDateValue) {
    if (solarHijriDateValue == 0 || (solarHijriDateValue.abs() / ADateStructure._eightZero) < 1) {
      throw ArgumentError('Err: SolarHijriDate.by(), parameter is not correct.');
    }

    _setValue(solarHijriDateValue);
  }

  SolarHijriDate.from(DateTime systemDate) {
    final days = _convertDateTimeToDays(systemDate);
    final date = _convertGregorianDaysToSolar(days).getValue();
    _setValue(date);

    changeTime(systemDate.hour, systemDate.minute, systemDate.second, systemDate.microsecond);

    /*_timeZone = 'utc';

    if(!isLocal){
      moveUtcToLocal();
    }*/
  }

  SolarHijriDate.parse(String solarHijriDate) {
    _setValue(SolarHijriDate.parseFrom(solarHijriDate).getValue());
  }

  void _init(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    if (year == 0 || month < 1 || month > 12 || day < 1 || day > 31 || hrs < 0 || hrs > 23 || min < 0 || min > 59 || sec < 0 || sec > 59 || millSec < 0 || millSec > 999) {
      throw ArgumentError('Err: Parameters for SolarHijriDate() is invalid. (Y/M/D ,$year/$month/$day $hrs:$min:$sec). ');
    }

    if (month > 6 && day > 30) {
      throw ArgumentError('Err: parameters for SolarHijriDate() is invalid. Max day must be 30 for this month. ');
    }

    if (month == 12 && day == 30 && !isSolarLeapYear(year)) {
      throw ArgumentError('Err: parameters for SolarHijriDate() is invalid. Year ($year) is not the leap. ');
    }

    if (year > 0) {
      _setValue(_plusYear(year, month, day, hrs, min, sec, millSec));
    } else {
      _setValue(_minusYear(year, month, day, hrs, min, sec, millSec));
    }

    if (getDaylightState() && month == 1 && day == 2 && hrs == 0) {
      throw ArgumentError('Err: parameters for SolarHijriDate() is invalid. (year/1/2 00:xx.xx) Hour must bigger than 0. ');
    }
  }

  int _plusYear(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    var res = (year - 1) * 365;
    var leaps = getLeapYears(0, year).length;
    res += leaps;

    if (month < 7) {
      res += (month - 1) * 31;
    }
    else {
      var x = (month - 7); // :(month-6)-1
      res += 6 * 31;
      res += x * 30;
    }

    res += day;

    int time;
    time = hrs * ADateStructure.oneHourInSec;
    time += min * ADateStructure.oneMinInSec;
    time += sec * 1000;
    time += millSec;

    res *= ADateStructure._eightZero;

    return (res + time);
  }

  int _minusYear(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    var pYear = year.abs();
    var all = (pYear - 1) * 365;
    var leaps = getLeapYears(year + 1, 0).length;
    all += leaps;
    all++; // 1 is for different 1/1/1 (1) ~~  (0)  ~~  -1/12/30 (-1)

    var days = 0;

    if (month < 7) {
      days += (month - 1) * 31;
    } else {
      var x = (month - 7);
      days += 6 * 31;
      days += x * 30;
    }

    days += day;
    var thisYear = isSolarLeapYear(year) ? 366 : 365;
    days = thisYear - days;

    int time;
    time = hrs * ADateStructure.oneHourInSec;
    time += min * ADateStructure.oneMinInSec;
    time += sec * 1000;
    time += millSec;

    all = -(all + days);
    all *= ADateStructure._eightZero;

    return (all + time);
  }

  SolarHijriDate.full(int year, int month, int day, int hrs, int min, int sec, int milSec) {
    _init(year, month, day, hrs, min, sec, milSec);
  }

  SolarHijriDate.hm(int year, int month, int day, int hrs, int min) {
    _init(year, month, day, hrs, min, 0, 0);
  }

  SolarHijriDate.date(int year, int month, int day) {
    _init(year, month, day, 0, 0, 0, 0);
  }

  @override
  bool getDaylightState() {
    return useDST() && isAtDaylightRange();
  }

  @override
  bool isValidDate() {
    var month = getMonth(), day = getDay(), hour = hoursOfToday();

    if (getDaylightState()) {
      if (month == 1 && day == 2 && hour == 0) {
        return false;
      }
    }

    return true;
  }

  void _checkLimitDate() {
    var days = ADateStructure._getDateSection(_value!);

    if ((days > 913200)) {
      throw ArgumentError('Err: this date is bigger than 2500 years  [it is $days days now]. ');
    }
  }

  @override
  bool isLeapYear() {
    return isSolarLeapYear(getYear());
  }

  static bool isLeapYearThis(int year) {
    return year != 0 && getSolarLeapYears(year - 5, year + 5).contains(year);
  }

  static bool isSolarLeapYear(int year) {
    if (year == 0) return false;

    int y;
    if (year > 0) {
      y = year + 1128; //1128 is Hakhamanesh date
    } else {
      y = year + 1129;
    }

    var t2 = (y * 365.24219).toInt();
    var t3 = ((y - 1) * 365.24219).toInt();
    return (t2 - t3) == 366;
  }

  static List<int> getSolarLeapYears(int start, int end) { //  := [start, end)
    var res = List<int>.empty(growable: true);

    if (end < start) {
      var t = start;
      start = end;
      end = t;
    }

    while (start < end) {
      if (isSolarLeapYear(start)) {
        res.add(start);
        start += 3;
      }
      start++;
    }

    return res;
  }

  @override
  List<int> getLeapYears(int start, int end) {//  := [ start, end )
    return getSolarLeapYears(start, end);
  }

  @override
  T getAsUTC<T extends ADateStructure>() {
    var res = SolarHijriDate.by(getValue());
    res.moveLocalToUTC();
    return res as T;
  }

  @override
  List<int> convertToGregorian() {
    var d = getDateAsDay();

    if (d > 0) {
      d += 226895;
    } else {
      d += 226896;
    }

    int allDays, leaps, day;
    var year = 1, monthDays = 0, m = 0;

    if (d > 0) {
      allDays = d;

      if (allDays > 365) {
        year = allDays ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(0, year).length;

        year = (allDays - leaps) ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(0, year + 1).length;
        allDays = allDays - leaps - (year * 365);

        if (allDays == 0) {
          allDays += 365;

          if (ADateStructure.isGregorianLeapYear(year)) {
            allDays++;
          }

          year--;
        }

        year++;
      }
    } else {
      allDays = d.abs();

      if (allDays > 365) {
        year = allDays ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(-year, 0).length;

        year = (allDays - leaps) ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(-(year - 1), 0).length;
        allDays = allDays - leaps - (year * 365);
        var v = ADateStructure.isGregorianLeapYear(year) ? 366 : 365;
        allDays = v - allDays;

        if (allDays == 0) {
          allDays += 365;

          if (ADateStructure.isGregorianLeapYear(year)) {
            allDays++;
          }

          year--; //this line maybe need to move up
        }

        year++;
      }

      year *= -1;
    }

    day = allDays;
    var mo = ADateStructure.gregorianMonths;

    if (ADateStructure.isGregorianLeapYear(year)) mo = ADateStructure.gregorianMonthsLeap;

    if (allDays > mo[m]) {
      do {
        monthDays += mo[m];
        m++;
      } while ((allDays - monthDays) > mo[m]);

      day = allDays - monthDays;
    }

    return [year, m + 1, day];
  }

  @override
  DateTime convertToSystemDate() {
    final ge = convertToGregorian();
    return DateTime(ge[0], ge[1], ge[2], hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  SolarHijriDate getFromSystemDate(DateTime date) {
    return _convertGregorianDaysToSolar(_convertSystemDateToDays(date));
  }

  static SolarHijriDate convertGregorianToSolar(int year, int month, int day) {
    var s = _convertGregorianDateToDays(year, month, day);
    return _convertGregorianDaysToSolar(s);
  }

  static SolarHijriDate _convertGregorianDaysToSolar(int days) {
    days -= 226895; //  {621/3/21} : (621*365)= 226665 + (150 Leap) + (31 + 28 + 21)

    if (days < 1) {
      days--;
    }

    return convertDaysToDate(days);
  }

  static int _convertGregorianDateToDays(int year, int month, int day) {
    var days = 0;
    var absYear = year.abs();
    List<int> mo;

    if (ADateStructure.isGregorianLeapYear(year)) {
      mo = ADateStructure.gregorianMonthsLeap;
    } else {
      mo = ADateStructure.gregorianMonths;
    }

    for (var i = 0; i < (month - 1); i++) {
      days += mo[i];
    }

    days += day;

    int yearDays;
    yearDays = (absYear - 1) * 365;
    yearDays += ADateStructure.getGregorianLeapYears(0, year).length;
    days += yearDays;

    if (year < 0) {
      days *= -1;
    }

    return days;
  }

  static int _convertDateTimeToDays(DateTime dateTime) {
    return _convertGregorianDateToDays(dateTime.year, dateTime.month, dateTime.day);
  }

  static int _convertSystemDateToDays(DateTime greDate) {
    return _convertDateTimeToDays(greDate);
  }

  static SolarHijriDate convertDaysToDate(int days) {
    if (days == 0) {
      throw Exception('Err: convertDaysToDate(), days is 0. ');
    }

    int year = 1, leaps, leftDays;

    if (days > 0) {
      leftDays = days;

      if (leftDays > 365) {
        var temp = leftDays ~/ 365;
        leaps = getSolarLeapYears(0, temp).length;

        year = (leftDays - leaps) ~/ 365;
        leaps = getSolarLeapYears(0, year + 1).length;
        leftDays = leftDays - leaps - (year * 365);

        if (leftDays == 0) {
          leftDays = 365;
          if (isSolarLeapYear(year)) {
            leftDays++;
          }

          year--;
        }

        year++;
      }
    } else {
      leftDays = days.abs();
      leftDays--;

      if (leftDays > 365) {
        var temp = leftDays ~/ 365;
        leaps = getSolarLeapYears(-temp, 0).length;

        year = (leftDays - leaps) ~/ 365;
        leaps = getSolarLeapYears(-(year + 1), 0).length;
        leftDays = leftDays - leaps - (year * 365);

        year++;
      }

      year *= -1;

      var plu = isSolarLeapYear(year) ? 366 : 365;
      leftDays = plu - leftDays;
    }

    var day = leftDays, monthDays = 0, j = 0;
    var mo = solarMonths;

    if (isSolarLeapYear(year)) {
      mo = solarMonthsLeap;
    }

    if (day > mo[j]) {
      do {
        monthDays += mo[j++];
      } while ((leftDays - monthDays) > mo[j]);

      day = leftDays - monthDays;
    }

    return SolarHijriDate.date(year, j + 1, day);
  }

  @override
  SolarHijriDate getFromDays(int days) {
    return convertDaysToDate(days);
  }

  static SolarHijriDate parseFrom(String? solarHijriDate) {
    if (solarHijriDate == null || solarHijriDate.isEmpty) {
      throw ArgumentError('Err: parse(), SolarHijriDate can not parse ,parameter is invalid. ');
    }

    int y, m, d, h = 0, mi = 0, s = 0, ms = 0;
    late RegExpMatch match;
    var pat1 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})$');
    var pat2 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})$');
    var pat3 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})$');
    var pat4 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})[.](\d{1,3})');

    var matched = false;

    if (pat1.hasMatch(solarHijriDate)) {
      match = pat1.allMatches(solarHijriDate).elementAt(0);
      matched = true;
    } else if (pat2.hasMatch(solarHijriDate)) {
      matched = true;
      match = pat2.allMatches(solarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
    } else if (pat3.hasMatch(solarHijriDate)) {
      matched = true;
      match = pat3.allMatches(solarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
    } else if (pat4.hasMatch(solarHijriDate)) {
      matched = true;
      match = pat4.allMatches(solarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
      ms = int.parse(match.group(7)!);
    }

    if (!matched) {
      throw ArgumentError('Err: parse(), can not parse solar hijri date,parameter is not a valid date.');
    }

    y = int.parse(match.group(1)!);
    m = int.parse(match.group(2)!);
    d = int.parse(match.group(3)!);

    return SolarHijriDate.full(y, m, d, h, mi, s, ms);
  }

  @override
  SolarHijriDate parse(String date) {
    return parseFrom(date);
  }

  @override
  int getYear() {
    _year ??= getYearFromDate(_value!);

    return _year!;
  }

  @override
  String getLatinWeekDayNameAs(int day) {
    return weekDayNameInLatin[day - 1];
  }

  @override
  String getLatinWeekDayName() {
    return weekDayNameInLatin[getWeekDay() - 1];
  }

  @override
  String getLatinWeekDayShortName(int day) {
    return subStringByRegex(getLatinWeekDayNameAs(day), r'^(.*?)(\\s.*|$)', 1);
  }

  @override
  String getLocalMonthName(int month, String lang) {
    return monthNameInPersian[month];
  }

  @override
  String getLocalWeekDayName(int day, String lang) {
    return weekDayNameInPersian[day - 1];
  }

  @override
  String getLocalWeekDayShortName(int day, String lang) {
    return getLocalWeekDayName(day, lang).substring(0, 3);
  }

  @override
  String getWeekDayName() {
    return weekDayNameInPersian[getWeekDay() - 1];
  }

  @override
  String getGregorianWeekDayName() {
    return GregorianDate.weekDayNameInLatin[getWeekDay() - 1];
  }

  @override
  String getLatinMonthName() {
    return monthNameInLatin[getMonth()];
  }

  @override
  String getMonthName() {
    return monthNameInPersian[getMonth()];
  }

  @override
  int getWeekDay() {
    var w = getDateAsDay();

    if (w > 0) {
      return ((w + 5) % 7) + 1;
    } else {
      return ((w + 6) % 7).abs() + 1;
    }
  }

  static int getYearFromDate(int date) {
    int days, year, leapYears = 0, leftDays;

    if (date > 0) {
      days = ADateStructure._getDateSection(date);
      year = days ~/ 365;

      if (year > 0) leapYears = getSolarLeapYears(0, year).length;

      leftDays = days - leapYears;
      year = leftDays ~/ 365;
      leftDays = leftDays - (year * 365);

      if (leftDays == 0 || (leftDays == 1 && isSolarLeapYear(year))) {
        return year;
      } else {
        return ++year;
      }
    } else {
      days = ADateStructure._getDateSection(date).abs();
      year = days ~/ 365;

      if (year > 0) leapYears = getSolarLeapYears(-year, 0).length;

      leftDays = days - leapYears;
      year = leftDays ~/ 365;
      leftDays = leftDays - (year * 365);

      if (leftDays == 0) {
        return (-year);
      } else {
        return (-1 * ++year);
      }
    }
  }

  static int getMonthFromDate(int inDate) {
    int day, leaps;
    var years = getYearFromDate(inDate);

    if (inDate > 0) {
      leaps = getSolarLeapYears(0, years).length;
      day = ADateStructure._getDateSection(inDate) - ((years - 1) * 365);
      day = day - leaps;
    } else {
      leaps = getSolarLeapYears(years - 1, 0).length;
      day = (-years * 365) + 1 + ADateStructure._getDateSection(inDate);
      day = day + leaps;
    }

    if (day < 31) {
      return 1;
    }

    int m1 = day ~/ 31, m2;

    if (m1 > 6) {
      var mul = 6 * 31;
      m2 = (day - mul) ~/ 30;
      if ((day - (mul + (m2 * 30))) == 0) {
        return (6 + m2);
      }
      return (7 + m2);
    } else {
      if ((day - (m1 * 31)) == 0) {
        return m1;
      }
      return (m1 + 1);
    }
  }

  @override
  int getMonth() {
    _month ??= getMonthFromDate(_value!);

    return _month!;
  }

  @override //dayInMonth
  int getDay() {
    var days = getDayInYear();

    if (days < 32) {
      return days;
    }

    int m1 = days ~/ 31, m2;

    if (m1 > 6) {
      var mul = 6 * 31;
      m2 = (days - mul) ~/ 30;

      if ((days - (mul + (m2 * 30))) == 0) m2--;

      return (days - (mul + (m2 * 30)));
    }
    else {
      if ((days - (m1 * 31)) == 0) m1--;

      return (days - (m1 * 31));
    }
  }

  @override
  int getLastDayOfMonth() {
    var mon = getMonth();

    if (isLeapYear()) {
      return solarMonthsLeap[mon-1];
    }

    return solarMonths[mon-1];
  }

  @override
  bool isEndOfMonth() {
    var day = getDay();
    var mon = getMonth();
    return (mon < 7 && day == 31) || (mon > 6 && day == 30) || (mon == 12 && day == 29 && !isSolarLeapYear(getYear()));
  }

  @override
  int getLastDayOfMonthFor(int year, int month) {
    if (isSolarLeapYear(year)) {
      return solarMonthsLeap[month - 1];
    } else {
      return solarMonths[month - 1];
    }
  }

  @override
  SolarHijriDate getFirstOfMonth() {
    return SolarHijriDate.full(getYear(), getMonth(), 1, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  SolarHijriDate getEndOfMonth() {
    int d, m = getMonth();

    if (isLeapYear()) {
      d = solarMonthsLeap[m - 1];
    } else {
      d = solarMonths[m - 1];
    }

    return SolarHijriDate.full(getYear(), m, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  SolarHijriDate getEndOfNextMonth() {
    int d;
    var m = getMonth();
    var y = getYear();
    var nextM = m % 12;
    bool b;

    if (m < 12) {
      b = isLeapYear();
    } else {
      y++;
      b = isSolarLeapYear(y);
    }

    if (b) {
      d = solarMonthsLeap[nextM];
    } else {
      d = solarMonths[nextM];
    }

    return SolarHijriDate.full(y, nextM + 1, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  SolarHijriDate getEndOfPrevMonth() {
    int d;
    var m = getMonth();
    var y = getYear();
    var preM = (m + 10) % 12;

    bool b;

    if (m > 1) {
      b = isLeapYear();
    } else {
      y--;
      b = isSolarLeapYear(y);
    }

    if (b) {
      d = solarMonthsLeap[preM];
    } else {
      d = solarMonths[preM];
    }

    return SolarHijriDate.full(y, preM + 1, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  int getDayInYear() {
      return getDayAtYearFromDate(_value!);
  }

  @override
  bool isPastOf(int milSeconds) {
    ADateStructure now = SolarHijriDate();
    var dayDif = ADateStructure._getDateSection(now.getValue()) - ADateStructure._getDateSection(getValue());
    var secDif = ADateStructure._getTimeSection(now.getValue()) - ADateStructure._getTimeSection(getValue());

    return (ADateStructure.convertDayToMils(dayDif) + secDif) > milSeconds;
  }

  static int getDayAtYearFromDate(int inDate) {
    int day, leaps;
    var year = getYearFromDate(inDate);

    if (inDate > 0) {
      leaps = getSolarLeapYears(0, year).length;
      day = ADateStructure._getDateSection(inDate) - ((year - 1) * 365);
      day = day - leaps;
    } else {
      leaps = getSolarLeapYears(year, 0).length;

      day = (-year * 365) + 1 + leaps;
      day = day + ADateStructure._getDateSection(inDate);
    }

    return day;
  }

  @override
  SolarHijriDate moveDay(int days) {
    var thisDays = ADateStructure._getDateSection(_value!);
    var plus1 = true;
    var plus2 = true;

    if (thisDays < 0) {
      plus1 = false;
    }

    thisDays += days;

    if (thisDays < 1) {
      plus2 = false;
    }

    if (thisDays == 0 || (plus1 != plus2)) {
      if (days < 0) {
        thisDays--;
      } else {
        thisDays++;
      }
    }

    _value = (thisDays * ADateStructure._eightZero) + ADateStructure._getTimeSection(_value!);

    _reset();
    _checkLimitDate();
    return this;
  }

  @override
  SolarHijriDate moveDayClone(int days) {
    var res = clone();
    res.moveDay(days);

    return res as SolarHijriDate;
  }

  @override
  SolarHijriDate addMonth(int months) {
    var isMinus = false;

    if (months < 0) {
      months = months.abs();
      isMinus = true;
    }

    var days = 0;
    if (months > 11) {
      while (months > 11) {
        days += 365;
        months = months - 12;
      }
    }

    days += (months * 30.5).floor();

    if (isMinus) {
      days *= -1;
    }

    moveDay(days);

    return this;
  }

  @override
  SolarHijriDate moveMonth(int months, bool tallyEndMonth) {
    if (months == 0) {
      return this;
    }

    var thisMonth = getMonth();
    var thisYear = getYear();
    var thisDay = getDay();

    var days = 0;
    var isMinus = false, isPlus = true;

    if (thisYear < 1) {
      isPlus = false;
    }

    if (months < 0) {
      months = months.abs();
      isMinus = true;
    }

    if (months > 11) {
      var w = months ~/ 12;

      if (isMinus) {
        if (tallyEndMonth && (months % 12 == 0) && thisDay == 29 && thisMonth == 12) {
          var add = (isPlus && (thisYear - w) < 1) ? 1 : 0;

          if (!isLeapYearThis(thisYear) && isLeapYearThis(thisYear - w - add)) days--;
        }

        while (w > 0) {
          thisYear--;
          if (isPlus && thisYear < 1) {
            thisYear--;
            isPlus = false;
          }

          days += isSolarLeapYear(thisYear) ? 366 : 365;

          w--;
          months -= 12;
        }
      } else {
        if (tallyEndMonth && (months % 12 == 0) && thisDay == 29 && thisMonth == 12) {
          var add = (!isPlus && (thisYear + w) > -1) ? 1 : 0;

          if (isLeapYearThis(thisYear + w + add) && !isLeapYearThis(thisYear)) {
            days++;
          }
        }

        while (w > 0) {
          days += isSolarLeapYear(thisYear) ? 366 : 365;
          thisYear++;

          if (!isPlus && thisYear > -1) {
            thisYear++;
            isPlus = true;
          }

          w--;
          months -= 12;
        }
      }

      if (thisMonth == 12 && thisDay == 30 && !isSolarLeapYear(thisYear)){ // =: 1395/12/30 + 12 Mon > 1396/12/29
        if (isMinus) {
          days++;
        }
        else {
          days--;
        }
      }

      thisYear += w;
    }

    if (months > 0) {
      var across = false;
      int endOfThis, endOfSide;
      var mo = solarMonths;

      if (isSolarLeapYear(thisYear)) {
        mo = solarMonthsLeap;
      }

      for (var i = 0; i < months; i++) {
        if (isMinus) {
          if (!across && (thisMonth - i) <= 1) {
            across = true;
            thisYear--;

            if (isPlus && thisYear < 1) {
              thisYear--;
              isPlus = false;
            }

            if (isLeapYearThis(thisYear)) {
              mo = solarMonthsLeap;
            } else {
              mo = solarMonths;
            }
          }

          endOfSide = mo[((thisMonth + 10 - i) % 12)];

          if (thisDay < 30) {
            days += endOfSide;
          } else {
            endOfThis = mo[((thisMonth + 11 - i) % 12)];
            if (thisDay <= endOfSide) {
              if (endOfThis < endOfSide) {
                days += endOfThis;
                days += endOfSide - thisDay;

                if (endOfThis > thisDay) days--;
              } else {
                if (endOfThis > endOfSide) {
                  days += endOfSide;
                } else {
                  days += endOfThis;
                }
              }
            } else {
              if (thisDay <= endOfSide) {
                days += endOfSide;
              } else {
                days += endOfThis;
              }
            }
          }
        } else {
          if (!across && (thisMonth + i) > 12) {
            across = true;
            thisYear++;

            if (!isPlus && thisYear > -1) {
              thisYear++;
              isPlus = true;
            }

            if (isLeapYearThis(thisYear)) {
              mo = solarMonthsLeap;
            } else {
              mo = solarMonths;
            }
          }

          endOfThis = mo[((thisMonth - 1 + i) % 12)];

          if (thisDay < 30) {
            days += endOfThis;
          } else {
            endOfSide = mo[((thisMonth + i) % 12)];
            if (thisDay <= endOfSide) {
              if (endOfThis < thisDay) {
                days += thisDay;
              } else {
                days += endOfThis;
              }
            } else {
              if (endOfSide > thisDay) {
                days += thisDay;
              } else {
                days += endOfSide;
              }
            }
          }
        }
      }

      if (tallyEndMonth && isEndOfMonth() && thisDay < 31) {
        if (isMinus) {
          if (((thisMonth + 12 - months) % 12) != 0) days -= mo[((thisMonth + 11 - months) % 12)] - thisDay;
        } else {
          if (((thisMonth - 1 + months) % 12) != 11) days += mo[((thisMonth - 1 + months) % 12)] - thisDay;
        }
      }
    }

    if (isMinus) {
      moveDay(-days);
    } else {
      moveDay(days);
    }

    return this;
  }

  @override
  SolarHijriDate moveYear(int years, bool tallyEnd) {
    if (years == 0) {
      return this;
    }

    var thisYear = getYear();
    var day = getDay();
    var thisMonth = getMonth();
    var isMinus = false;

    if (years < 0) {
      years = years.abs();
      isMinus = true;
    }

    var days = years * 365;

    if (isMinus) {
      if (thisYear > 0 && (thisYear - years) < 1) years++;
      days += getSolarLeapYears(thisYear + (-years), thisYear).length;
    } else {
      if (thisYear < 0 && (thisYear + years) > -1) years++;
      days += getSolarLeapYears(thisYear, thisYear + years).length;
    }

    if (isMinus) {
      if (thisMonth == 12 && day == 30 && !isSolarLeapYear(thisYear + (-years))) days++;

      if (tallyEnd && isEndOfMonth() && day < 31 && isSolarLeapYear(thisYear + (-years)) && !isSolarLeapYear(thisYear)) days--;
    } else {
      if (thisMonth == 12 && day == 30 && !isSolarLeapYear(thisYear + years)) { // 1395/12/30 + 1 Year => 1396/12/29  =: 255 Days
        days--;
      }

      if (tallyEnd && isEndOfMonth() && day < 31 && isSolarLeapYear(thisYear + years) && !isSolarLeapYear(thisYear)) days++;
    }

    if (isMinus) {
      moveDay(-days);
    } else {
      moveDay(days);
    }

    return this;
  }

  @override
  ADateStructure moveWeek(int weeks) {
    if (weeks != 0) moveDay(weeks * 7);

    return this;
  }

  @override
  T clone<T extends ADateStructure>() {
    return SolarHijriDate.full(getYear(), getMonth(), getDay(), hoursOfToday(),
        minutesOfToday(), secondsOfToday(), milliSecondsOfToday()) as T;
  }

  @override
  SolarHijriDate changeTo(int year, int month, int day, int hour, int min, int sec, int mil, bool byDayLight) {
    _init(year, month, day, hour, min, sec, mil);
    _reset();
    return this;
  }

  String subStringByRegex(String src, String pattern, int group){
    var pat = RegExp(pattern);

    if(pat.hasMatch(src)) {
      return pat.firstMatch(src)!.group(group)!;
    }

    return '';
  }
}
