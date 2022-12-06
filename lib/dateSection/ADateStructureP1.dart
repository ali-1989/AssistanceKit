part of 'ADateStructure.dart';

class GregorianDate extends ADateStructure {
  static final List<String> monthNameInLatin = ['',
    'January', 'February', 'March',
    'April', 'May', 'June',
    'July', 'August', 'September',
    'October', 'November', 'December'
  ];
  static final List<String> weekDayNameInLatin = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday' /*1/1/1*/, 'Sunday'];

  GregorianDate() {
    var dt = DateTime.now();
    _init(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond);
  }

  GregorianDate.by(int gregorianDateValue){
    if (gregorianDateValue == 0 || ( gregorianDateValue.abs() / ADateStructure._eightZero) < 1) {
      throw ArgumentError('Err: GregorianDate.by(), parameter is not correct.');
    }

    _setValue(gregorianDateValue);
  }

  GregorianDate.from(DateTime systemDate){
    _setValue(getFromSystemDate(systemDate).getValue());
    changeTime(systemDate.hour, systemDate.minute, systemDate.second, systemDate.microsecond);
  }

  GregorianDate.parse(String gregorianDate){
    _setValue(GregorianDate.parseFrom(gregorianDate).getValue());
  }

  void _init(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    if (year == 0 || month < 1 || month > 12 ||
        day < 1 || day > 31 ||
        hrs < 0 || hrs > 23 || min < 0 || min > 59 || sec < 0 || sec > 59
        || millSec < 0 || millSec > 999) {
      throw ArgumentError('Err: Parameters for GregorianDate() is invalid. (Y/M/D ,'
          '$year/$month/$day $hrs:$min:$sec).');
    }

    if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
      throw ArgumentError('Err: parameters for GregorianDate() is invalid. Max day must be 30 for this month.');
    }

    if (month == 2 && day > 28 && !isLeapYearThis(year)) {
      throw ArgumentError('Err: parameters for GregorianDate() is invalid. Year (' + year.toString() + ') is not the leap. ');
    }

    if (year > 0) {
      _setValue(_plusYear(year, month, day, hrs, min, sec, millSec));
    } else {
      _setValue(_minusYear(year, month, day, hrs, min, sec, millSec));
    }
  }

  int _plusYear(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    var days = (year - 1) * 365;
    var leaps = getLeapYears(0, year).length;
    days += leaps;

    var add = 0;

    for (var i = 0; i < month - 1; i++) {
      add += ADateStructure.gregorianMonths[i];
    }

    days += add;
    if (month > 2 && isLeapYearThis(year)) {
      days++;
    }

    days += day;

    int time;
    time = hrs * ADateStructure.oneHourInSec;
    time += min * ADateStructure.oneMinInSec;
    time += sec * 1000;
    time += millSec;

    days *= ADateStructure._eightZero;

    return (days + time);
  }

  int _minusYear(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    var pYear = year.abs();
    var all = (pYear - 1) * 365;
    var leaps = getLeapYears(0, year + 1).length;
    all += leaps;
    all++; // 1 is for different    1/1/1 (1) ~~  (0)  ~~  -1/12/29 (-1)

    var days = 0;

    for (var i = 0; i < month - 1; i++) {
      days += ADateStructure.gregorianMonths[i];
    }

    if (month > 2 && isLeapYearThis(year)) {
      days++;
    }

    days += day;
    var thisYear = ADateStructure.isGregorianLeapYear(year) ? 366 : 365;
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

  GregorianDate.full(int year, int month, int day, int hrs, int min, int sec, int milSec){
    _init(year, month, day, hrs, min, sec, milSec);
  }

  GregorianDate.hm(int year, int month, int day, int hrs, int min){
    _init(year, month, day, hrs, min, 0, 0);
  }

  GregorianDate.date(int year, int month, int day){
    _init(year, month, day, 0, 0, 0, 0);
  }

  GregorianDate.year(int year){
    _init(year, 0, 0, 0, 0, 0, 0);
  }

  @override
  bool getDaylightState() {
    return useDST() && isAtDaylightRange();
  }

  @override
  bool isValidDate() {
    var month = getMonth(),
        day = getDay(),
        hour = hoursOfToday();

    if (getDaylightState()) {
      if (month == 1 && day == 2 && hour == 0) {
        return false;
      }
    }

    return true;
  }

  void _checkLimitDate() {
    final days = ADateStructure._getDateSection(_value!);

    if (days > 1099000) {
      throw ArgumentError('Err: moveDay(), this date is bigger than 2500 years  [is ' + days.toString() + ' days now]. ');
    }
  }

  @override
  bool isLeapYear() {
    return isLeapYearThis(getYear());
  }

  static bool isLeapYearThis(int year) {
    return year != 0 && ADateStructure.getGregorianLeapYears(year - 5, year + 5).contains(year);
  }

  @override
  List<int> getLeapYears(int start, int end) {
    return ADateStructure.getGregorianLeapYears(start, end);
  }

  @override
  List<int> convertToGregorian() {
    return [getYear(), backwardStepInRing(getMonth(), 1, 12, true), getDay()];
  }

  @override
  DateTime convertToSystemDate() {
    return DateTime(getYear(), getMonth(), getDay(), hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  GregorianDate getFromSystemDate(DateTime date) {
    return GregorianDate.full(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond);
  }

  @override
  T getAsUTC<T extends ADateStructure>() {
    var res = GregorianDate.by(getValue());
    res.moveLocalToUTC();
    return res as T;
  }

  /*static int _convertGregorianDateToDays(int year, int month, int day) {
		int days = 0,
				inYear = year.abs();
		List<int> mo;

		if (ADateStructure.isGregorianLeapYear(year))
			mo = ADateStructure.gregorianMonthsLeap;
		else
			mo = ADateStructure.gregorianMonths;

		for (int i = 0; i < (month - 1); i++) {
			days += mo[i];
		}

		days += day;

		int yearDays;
		yearDays = (inYear - 1) * 365;
		yearDays += ADateStructure.getGregorianLeapYears(0, year).length;
		days += yearDays;

		if (year < 0)
			days *= -1;

		return days;
	}*/

  static GregorianDate convertDaysToDate(int days) {
    if (days == 0) {
      throw Exception('Err: convertDaysToDate(), days is 0.');
    }

    int year = 1,
        leaps,
        leftDays;

    if (days > 0) {
      leftDays = days;

      if (leftDays > 365) {
        year = leftDays ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(0, year).length;

        year = (leftDays - leaps) ~/ 365;
        leaps = ADateStructure.getGregorianLeapYears(0, year + 1).length;
        leftDays = leftDays - leaps - (year * 365);

        if (leftDays == 0) {
          leftDays = 365;
          if (ADateStructure.isGregorianLeapYear(year)) {
            leftDays++;
          }

          year--;
        }

        year++;
      }
    }
    else {
      leftDays = days.abs();
      leftDays--;

      if (leftDays > 365) {
        var temp = leftDays ~/ 365;
        leaps = ADateStructure
            .getGregorianLeapYears(-temp, 0)
            .length;

        year = (leftDays - leaps) ~/ 365;
        leaps = ADateStructure
            .getGregorianLeapYears(-(year + 1), 0)
            .length;
        leftDays = leftDays - leaps - (year * 365);

        year++;
      }

      year *= -1;

      var plu = ADateStructure.isGregorianLeapYear(year) ? 366 : 365;

      leftDays = plu - leftDays;
    }

    var day = leftDays,
        monthDays = 0,
        j = 0;
    var mo = ADateStructure.gregorianMonths;

    if (isLeapYearThis(year)) {
      mo = ADateStructure.gregorianMonthsLeap;
    }

    if (day > mo[j]) {
      do {
        monthDays += mo[j++];
      }
      while ((leftDays - monthDays) > mo[j]);

      day = leftDays - monthDays;
    }

    return GregorianDate.date(year, j + 1, day);
  }

  @override
  GregorianDate getFromDays(int days) {
    return convertDaysToDate(days);
  }

  static GregorianDate parseFrom(String? gregorianDate) {
    if (gregorianDate == null || gregorianDate.isEmpty) {
      throw ArgumentError('Err: parse(), GregorianDate can not parse ,parameter is invalid. ');
    }

    int y, m, d, h = 0, mi = 0, s = 0, ms = 0;
    late RegExpMatch match;
    var pat1 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})$');
    var pat2 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})$');
    var pat3 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})$');
    var pat4 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})[.](\d{1,3})');

    var matched = false;

    if (pat1.hasMatch(gregorianDate)) {
      match = pat1.allMatches(gregorianDate).elementAt(0);
      matched = true;
    }
    else if (pat2.hasMatch(gregorianDate)) {
      matched = true;
      match = pat2.allMatches(gregorianDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
    }
    else if (pat3.hasMatch(gregorianDate)) {
      matched = true;
      match = pat3.allMatches(gregorianDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
    }
    else if (pat4.hasMatch(gregorianDate)) {
      matched = true;
      match = pat4.allMatches(gregorianDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
      ms = int.parse(match.group(7)!);
    }

    if (!matched) {
      throw ArgumentError('Err: parse(), can not parse gregorian date,parameter is not a valid date. ');
    }

    y = int.parse(match.group(1)!);
    m = int.parse(match.group(2)!);
    d = int.parse(match.group(3)!);

    return GregorianDate.full(y, m, d, h, mi, s, ms);
  }

  @override
  GregorianDate parse(String gregorianDate) {
    return parseFrom(gregorianDate);
  }

  @override
  String getLatinWeekDayNameAs(int d) {
    return weekDayNameInLatin[d - 1];
  }

  @override
  String getLatinWeekDayName() {
    return weekDayNameInLatin[getWeekDay() - 1];
  }

  @override
  String getGregorianWeekDayName() {
    return weekDayNameInLatin[getWeekDay() - 1];
  }

  @override
  String getLatinWeekDayShortName(int d) {
    return getLatinWeekDayNameAs(d).substring(0, 3).toUpperCase();
  }

  @override
  String getLocalWeekDayName(int day, String lang) {
    return weekDayNameInLatin[day-1];
  }

  @override
  String getLocalWeekDayShortName(int d, String lang) {
    return getLatinWeekDayNameAs(d).substring(0, 3).toUpperCase();
  }

  @override
  String getWeekDayName() {
    return weekDayNameInLatin[getWeekDay() - 1];
  }

  @override
  String getLatinMonthName() {
    return monthNameInLatin[getMonth() - 1];
  }

  @override
  String getMonthName() {
    return monthNameInLatin[getMonth() - 1];
  }

  @override
  String getLocalMonthName(int m, String lang) {
    return monthNameInLatin[m-1];
  }

  @override
  int getWeekDay() {
    var w = getDateAsDay();

    if (w > 0) {
      return ((w + 6) % 7) + 1;
    } else {
      return ((w + 7) % 7).abs() + 1;
    }
  }

  static int getYearFromDate(int value) {
    int days,
        year,
        leapYears = 0,
        leftDays;

    if (value > 0) {
      days = ADateStructure._getDateSection(value);
      year = days ~/ 365;

      if (year != 0) {
        leapYears = ADateStructure.getGregorianLeapYears(0, year).length;
      }

      leftDays = days - leapYears;
      var newYear = leftDays ~/ 365;
      leftDays = leftDays - (newYear * 365);

      //if (leftDays == 1 && year == newYear && ADateStructure.isGregorianLeapYear(year))
      if (leftDays == 1 && year == newYear && ADateStructure.isGregorianLeapYear(newYear)) {
        return newYear;
      }

      if (leftDays == 0) {
        return newYear;
      } else {
        return ++newYear;
      }
    }
    else {
      days = ADateStructure._getDateSection(value).abs();
      year = days ~/ 365;

      if (year != 0) {
        leapYears = ADateStructure
            .getGregorianLeapYears(0, (-year + 1))
            .length;
      }

      leftDays = days - leapYears;
      year = leftDays ~/ 365;
      leftDays = leftDays - (year * 365);

      if (leftDays == 0 || (leftDays == 1 && ADateStructure.isGregorianLeapYear(-year))) {
        return (-1 * year);
      } else {
        return (-1 * ++year);
      }
    }
  }

  static int getMonthFromDate(int value) {
    int day, leaps;
    var years = getYearFromDate(value);

    if (value > 0) {
      leaps = ADateStructure
          .getGregorianLeapYears(0, years)
          .length;
      day = ADateStructure._getDateSection(value) - ((years - 1) * 365);
      day = day - leaps;
    }
    else {
      leaps = ADateStructure
          .getGregorianLeapYears(years + 1, 0)
          .length;
      day = (-years * 365) + 1 + ADateStructure._getDateSection(value);
      day = day + leaps;
    }

    //years = years + (leaps/365);
    var m = ADateStructure.gregorianMonths;

    if (ADateStructure.isGregorianLeapYear(years)) {
      m = ADateStructure.gregorianMonthsLeap;
    }

    if (day <= m[0]) {
      return 1;
    }

    for (var i = 0; i < 11; i++) {
      day = day - m[i];

      if (i < 11 && day <= m[i + 1]) {
        return (i + 2);
      }
    }

    return 12;
  }

  @override
  int getYear() {
    _year ??= getYearFromDate(_value!);

    return _year!;
  }

  @override
  int getMonth() {
    _month ??= getMonthFromDate(_value!);

    return _month!;
  }

  @override
  int getDay() {
    var days = getDayInYear();

    var m = ADateStructure.gregorianMonths;

    if (isLeapYear()) {
      m = ADateStructure.gregorianMonthsLeap;
    }

    if (days <= m[0]) {
      return days;
    }

    for (var i = 0; i < 11; i++) {
      days = days - m[i];

      if (i < 11 && days <= m[i + 1]) {
        return days;
      }
    }
    
    return  (days - m[11]);
  }

  @override
  int getLastDayOfMonth() {
    var mon = getMonth();

    if (isLeapYear()) {
      return ADateStructure.gregorianMonthsLeap[mon];
    }
    return ADateStructure.gregorianMonths[mon];
  }

  @override
  bool isEndOfMonth() {
    var day = getDay();
    var mon = getMonth();

    if (mon != 2 && ADateStructure.gregorianMonths[mon - 1] == day) {
      return true;
    }

    if (mon == 2) {
      if ((isLeapYear() && day == 29) || (!isLeapYear() && day == 28)) {
        return true;
      }
    }

    return false;
  }

  @override
  int getLastDayOfMonthFor(int year, int mon) {
    if (ADateStructure.isGregorianLeapYear(year)) {
      return ADateStructure.gregorianMonthsLeap[mon - 1];
    } else {
      return ADateStructure.gregorianMonths[mon - 1];
    }
  }

  @override
  GregorianDate getFirstOfMonth() {
    return GregorianDate.full(getYear(), getMonth(), 1, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  GregorianDate getEndOfMonth() {
    int d, m = getMonth();

    if (isLeapYear()) {
      d = ADateStructure.gregorianMonthsLeap[m - 1];
    } else {
      d = ADateStructure.gregorianMonths[m - 1];
    }

    return GregorianDate.full(getYear(), m, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  GregorianDate getEndOfNextMonth() {
    int d;
    var m = getMonth();
    var y = getYear();
    var nextM = m % 12;
    bool b;

    if (m < 12) {
      b = isLeapYear();
    }
    else {
      y++;
      b = isLeapYearThis(y);
    }

    if (b) {
      d = ADateStructure.gregorianMonthsLeap[nextM];
    } else {
      d = ADateStructure.gregorianMonths[nextM];
    }

    return GregorianDate.full(y, nextM + 1, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  GregorianDate getEndOfPrevMonth() {
    int d;
    var m = getMonth();
    var y = getYear();
    var preM = (m + 10) % 12;

    bool b;

    if (m > 1) {
      b = isLeapYear();
    }
    else {
      y--;
      b = isLeapYearThis(y);
    }

    if (b) {
      d = ADateStructure.gregorianMonthsLeap[preM];
    } else {
      d = ADateStructure.gregorianMonths[preM];
    }

    return GregorianDate.full(y, preM + 1, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  int getDayInYear() {
    return getDayInYearFor(_value!);
  }

  @override
  bool isPastOf(int milSeconds) {
    ADateStructure now = GregorianDate();
    var dayDif = ADateStructure._getDateSection(now.getValue()) - ADateStructure._getDateSection(getValue());
    var secDif = ADateStructure._getTimeSection(now.getValue()) - ADateStructure._getTimeSection(getValue());

    return ( ADateStructure.convertDayToMils(dayDif) + secDif) > milSeconds;
  }

  static int getDayInYearFor(int inDate) {
    int day, leaps;
    var year = getYearFromDate(inDate);

    if (inDate > 0) {
      leaps = ADateStructure
          .getGregorianLeapYears(0, year)
          .length;
      day = ADateStructure._getDateSection(inDate) - ((year - 1) * 365);
      day = day - leaps;
    }
    else {
      leaps = ADateStructure
          .getGregorianLeapYears(year + 1, 0)
          .length;
      day = (-year * 365) + 1 + leaps;
      day = day + ADateStructure._getDateSection(inDate);
    }

    return day;
  }

  @override
  GregorianDate moveDay(int days) {
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

    if (thisDays == 0 || plus1 != plus2) {
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
  GregorianDate moveDayClone(int days) {
    var res = clone();
    res.moveDay(days);

    return res as GregorianDate;
  }

  @override
  GregorianDate addMonth(int months) {
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
  GregorianDate moveMonth(int months, bool tallyEndMonth) {
    // Help: tallyEndMonth if true , 4/30 +1 month => 5/31
    //  if its be false  4/30 +1 month => 5/30
    if (months == 0) {
      return this;
    }

    var thisMonth = getMonth();
    var thisYear = getYear();
    var thisDay = getDay();

    var days = 0,
        c = 0;
    var isMinus = false;

    if (months < 0) {
      months = months.abs();
      isMinus = true;
    }

    if (months > 11) {
      var w = months ~/ 12;
      months -= (12 * w);
      days += (365 * w);

      if (isMinus) {
        if (isLeapYearThis(thisYear)) {
          if (thisMonth == 2 && (thisDay == 28 || thisDay == 29)) {
            days++;

            if (thisDay == 28 && !isLeapYearThis(thisYear + w)) {
              days--;
            }
          }
          else {
            if (thisMonth > 2) {
              days++;
            }
          }
        }

        if (isLeapYearThis(thisYear - w)) {
          if (thisMonth == 2 && (thisDay == 28 || thisDay == 29)) {
            if (!isLeapYearThis(thisYear)) {
              days++;
            }
          }
          else {
            if (thisMonth < 3) {
              days++;
            }
          }
        }


        if (tallyEndMonth && months == 0 && thisMonth == 2 && thisDay == 28) {
          if (isLeapYearThis(thisYear - w) && !isLeapYearThis(thisYear)) {
            days--;
          }
        }

        if (w > 1) {
          c += getLeapYears(thisYear - w + 1, thisYear).length;
        }

        days += c;
        thisYear -= w;
      }
      else {
        if (thisMonth < 3) {
          if (isLeapYearThis(thisYear) && !(thisMonth == 2 && thisDay == 29)) {
            days++;
          }
        }
        else {
          if (isLeapYearThis(thisYear + w)) {
            days++;
          }
        }

        if (isLeapYearThis(thisYear + w)) {
          if (thisDay == 29 && thisMonth == 2) {
            days++;
          }
        }

        if (tallyEndMonth && months == 0 && thisDay == 28 && thisMonth == 2) {
          if (isLeapYearThis(thisYear + w) && !isLeapYearThis(thisYear)) {
            days++;
          }
        }

        if (w > 1) {
          days += getLeapYears(thisYear + 1, thisYear + w).length;
        }

        thisYear += w;
      }
    }

    if (months > 0) {
      var across = false;
      int endOfThis, endOfSide;
      var mo = ADateStructure.gregorianMonths;

      if (isLeapYearThis(thisYear)) {
        mo = ADateStructure.gregorianMonthsLeap;
      }

      for (var i = 0; i < months; i++) {
        if (isMinus) {
          if (!across && (thisMonth - i) <= 1) {
            across = true;
            thisYear--;
            if (isLeapYearThis(thisYear)) {
              mo = ADateStructure.gregorianMonthsLeap;
            } else {
              mo = ADateStructure.gregorianMonths;
            }
          }

          endOfSide = mo[((thisMonth + 10 - i) % 12)];

          if (thisDay < 29) {
            days += endOfSide;
          }
          else {
            endOfThis = mo[((thisMonth + 11 - i) % 12)];
            if (thisDay <= endOfSide) {
              if (endOfThis < endOfSide) {
                days += endOfThis;
                days += endOfSide - thisDay;

                if (endOfThis > thisDay) {
                  days--;
                }
              }
              else {
                if (endOfThis > endOfSide) {
                  days += endOfSide;
                } else {
                  days += endOfThis;
                }
              }
            }
            else {
              if (thisDay <= endOfSide) {
                days += endOfSide;
              } else {
                days += thisDay;
              }
            }
          }
        }
        else {
          if (!across && (thisMonth + i) > 12) {
            across = true;
            thisYear++;
            if (isLeapYearThis(thisYear)) {
              mo = ADateStructure.gregorianMonthsLeap;
            } else {
              mo = ADateStructure.gregorianMonths;
            }
          }

          endOfThis = mo[((thisMonth - 1 + i) % 12)];

          if (thisDay < 29) {
            days += endOfThis;
          }
          else {
            endOfSide = mo[((thisMonth + i) % 12)];
            if (thisDay <= endOfSide) {
              if (endOfThis < thisDay) {
                days += thisDay;
              } else {
                days += endOfThis;
              }
            }
            else {
              days += (endOfThis - thisDay) + endOfSide;
            }
          }
        }
      }

      if (tallyEndMonth && isEndOfMonth() && thisDay < 31) {
        if (isMinus) {
          if (((thisMonth + 12 - months) % 12) != 2) {
            days -= mo[((thisMonth + 11 - months) % 12)] - thisDay;
          }
        }
        else {
          if (((thisMonth - 1 + months) % 12) != 1) {
            days += mo[((thisMonth - 1 + months) % 12)] - thisDay;
          }
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
  GregorianDate moveYear(int years, bool tallyEnd) {
    if (years == 0) {
      return this;
    }

    var thisYear = getYear();
    var thisDay = getDay();
    var thisMonth = getMonth();
    var isMinus = false;

    if (years < 0) {
      years = years.abs();
      isMinus = true;
    }

    var days = years * 365;

    if (isMinus) {
      if (isLeapYearThis(thisYear)) {
        if (thisMonth == 2 && (thisDay == 28 || thisDay == 29)) {
          days++;

          if (thisDay == 28 && !isLeapYearThis(thisYear + (-years))) {
            days--;
          }
        }
        else {
          if (thisMonth > 2) {
            days++;
          }
        }

        if (tallyEnd && isEndOfMonth() && thisDay < 31 && isLeapYearThis(thisYear + (-years)) && !isLeapYearThis(thisYear)) {
          days--;
        }
      }

      if (isLeapYearThis(thisYear - years)) {
        if (thisMonth == 2 && (thisDay == 28 || thisDay == 29)) {
          if (!isLeapYearThis(thisYear)) {
            days++;
          }
        }
        else {
          if (thisMonth < 3) {
            days++;
          }
        }
      }

      if (years > 1) {
        days += getLeapYears(thisYear - years + 1, thisYear).length;
      }
    }
    else {
      if (thisMonth < 3) {
        if (isLeapYearThis(thisYear) && !(thisMonth == 2 && thisDay == 29)) {
          days++;
        }
      }
      else {
        if (isLeapYearThis(thisYear + years)) {
          days++;
        }
      }

      if (isLeapYearThis(thisYear + years)) {
        if (thisDay == 29 && thisMonth == 2) {
          days++;
        }
      }

      if (years > 1) {
        days += getLeapYears(thisYear + 1, thisYear + years).length;
      }

      if (tallyEnd && isEndOfMonth() && thisDay < 31 && isLeapYearThis(thisYear + years) && !isLeapYearThis(thisYear)) {
        days++;
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
  ADateStructure moveWeek(int weeks) {
    if (weeks != 0) {
      moveDay(weeks * 7);
    }

    return this;
  }

  @override
  T clone<T extends ADateStructure>(){
    return GregorianDate.full(getYear(), getMonth(), getDay(), hoursOfToday(),
        minutesOfToday(), secondsOfToday(), milliSecondsOfToday()) as T;
  }

  @override
  GregorianDate changeTo(int year, int month, int day, int hour, int min, int sec, int mil, bool dayLight) {
    _init(year, month, day, hour, min, sec, mil);
    _reset();

    return this;
  }
}
