part of 'ADateStructure.dart';

class LunarHijriDate extends ADateStructure {
  static final List<String> weekDayNameInLatin = [' as-Sabt', 'al-Ahad', 'al-Ithnayn', 'ath-Thulāthā', 'al-Arba‘ā', 'al-Khamīs', 'al-Jum‘ah'];
  static final List<String> weekDayNameInArabic = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  static final List<String> monthNameInLatin = ['Muharram', 'Safar', 'Rabiul Awwal', 'Rabiul Akhir', 'Jumadal Ula', 'Jumadal Akhira', 'Rajab', 'Shaaban', 'Ramadhan', 'Shawwal', 'Dhulqaada', 'Dhulhijja'];
  static final List<String> monthNameInArabic = ['محرّم', 'صفر', 'ربيع الأول', 'ربيع الثّاني', 'جُمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوّال', 'ذو القعدة', 'ذو الحجة'];
  static final List<int> lunarMonths =     [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];
  static final List<int> lunarMonthsLeap = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30];
  static final List<int> leapsCyclePlus = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
  static final List<int> leapsCycleMinus = [1, 4, 6, 9, 12, 15, 17, 20, 23, 25, 28];

  LunarHijriDate() {
    var dt = DateTime.now();
    var days = _convertDateTimeToDays(dt);
    var date = _convertGregorianDaysToLunar(days).getValue();
    _setValue(date);
    changeTime(dt.hour, dt.minute, dt.second, dt.microsecond);
  }

  LunarHijriDate.by(int lunarHijriDate) {
    if (lunarHijriDate == 0 || (lunarHijriDate.abs() / ADateStructure._eightZero) < 1) {
      throw ArgumentError('Err: LunarHijriDate.by(), parameter is not correct.');
    }

    _setValue(lunarHijriDate);
  }

  LunarHijriDate.parse(String lunarHijriDate) {
    _setValue(LunarHijriDate.parseFrom(lunarHijriDate).getValue());
  }

  void _init(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    if (year == 0 || month < 1 || month > 12 || day < 1 || day > 31 || hrs < 0 || hrs > 23 || min < 0 || min > 59 || sec < 0 || sec > 59 || millSec < 0 || millSec > 999) {
      throw ArgumentError('Err: Parameters for LunarHijriDate() is invalid. (Y/M/D ,' + year.toString() + '/' + month.toString() + '/' + day.toString() + ' ' + hrs.toString() + ':' + min.toString() + ':' + sec.toString() + '). ');
    }

    //if(month > 30)
    //throw new ArgumentError("Err: parameters for LunarHijriDate() is invalid. Max day must be 30 for month. ");


    if (year > 0) {
      _setValue(_plusYear(year, month, day, hrs, min, sec, millSec));
    } else {
      _setValue(_minusYear(year, month, day, hrs, min, sec, millSec));
    }
  }

  int _plusYear(int year, int month, int day, int hrs, int min, int sec, int millSec) {
    var res = (year - 1) * 354; // 354.36
    var leaps = getLeapYearsCount(year);

    res += leaps;

    for (var i = 0; i < month - 1; i++) {
      res += lunarMonths[i];
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
    var all = (pYear - 1) * 354;
    var leaps = getLeapYearsCount(year + 1);
    all += leaps;
    all++;

    var days = 0;

    for (var i = 0; i < month - 1; i++) {
      days += lunarMonths[i];
    }

    days += day;
    var y = isLeapYearAs(year) ? 355 : 354;
    days = y - days;

    int time;
    time = hrs * ADateStructure.oneHourInSec;
    time += min * ADateStructure.oneMinInSec;
    time += sec * 1000;
    time += millSec;

    all = -(all + days);
    all *= ADateStructure._eightZero;

    return (all + time);
  }

  LunarHijriDate.full(int year, int month, int day, int hrs, int min, int sec, int milSec) {
    _init(year, month, day, hrs, min, sec, milSec);
  }

  LunarHijriDate.get3(int year, int month, int day, int hrs, int min, int sec) {
    _init(year, month, day, hrs, min, sec, 0);
  }

  LunarHijriDate.get4(int year, int month, int day, int hrs, int min, int sec) {
    _init(year, month, day, hrs, min, sec, 0);
  }

  LunarHijriDate.get5(int year, int month, int day, int hrs, int min) {
    _init(year, month, day, hrs, min, 0, 0);
  }

  LunarHijriDate.get6(int year, int month, int day, int hrs, int min) {
    _init(year, month, day, hrs, min, 0, 0);
  }

  LunarHijriDate.get7(int year, int month, int day) {
    _init(year, month, day, 0, 0, 0, 0);
  }

  @override
  bool getDaylightState() {
    return _useDST; //isAtDaylightRange();
  }

  @override
  bool isAtDaylightRange() {
    int month = getMonth(), day = getDay(), hour = hoursOfToday();

    if ((month < 7 && month > 1) || (month == 1 && ((day > 2) || (day == 2 && hour > 0)))) {
      return true;
    }

    return false;
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

    if ((days > 890000)) {
      throw ArgumentError('Err: this date is bigger than 2500 years  [is ' + days.toString() + ' days now]. ');
    }
  }

  @override
  bool isLeapYear() {
    return isLeapYearAs(getYear());
  }

  static bool isLeapYearAs(int year) {
    //return year != 0 && getLunarLeapYears(year - 4, year + 4).contains(year); last state,changed to below
    return isLunarLeapYear(year);
  }

  static bool isLunarLeapYear(int year) {
    if (year == 0) {
      return false;
    }

    var res = false;

    if (year < 0) {
      var c = -year ~/ 30;

      if (-year % 30 != 0) {
        year = year + (c * 30);

        for (var j = 0; j < 11; j++) {
          if (-year == leapsCycleMinus[j]) {
            res = true;
            break;
          }
        }
      }
    } else {
      var c = year ~/ 30;

      if (year % 30 != 0) {
        year = year - (c * 30);

        for (var j = 0; j < 11; j++) {
          if (year == leapsCyclePlus[j]) {
            res = true;
            break;
          }
        }
      }
    }
    return res;
  }

  static List<int> getLunarLeapYears(int start, int end) {
    var res = List<int>.empty(growable: true);

    if (end < start) {
      var t = start;
      start = end;
      end = t;
    }

    while (start < end) {
      if (isLunarLeapYear(start)) {
        res.add(start);
        start++;
      }
      start++;
    }

    return res;
  }

  static int getLeapYearsCount(int year) // [0, +year)  , [0, -year]
  {
    int res;

    if (year < 0) {
      var c = -year ~/ 30;
      res = c * 11;

      if (-year % 30 != 0) {
        year = year + (c * 30);

        for (var i = year; i < 0; i++) {
          for (var j = 0; j < 11; j++) {
            if (-i == leapsCycleMinus[j]) {
              res++;
              break;
            }
          }
        }
      }
    } else {
      var c = year ~/ 30;
      res = c * 11;

      if (year % 30 != 0) {
        year = year - (c * 30);

        for (var i = 1; i <= year; i++) {// updated: {i < year}  to  {i <= year}
          for (var j = 0; j < 11; j++) {
            if (i == leapsCyclePlus[j]) {
              res++;
              break;
            }
          }
        }
      }
    }

    return res;
  }

  static int getLeapYearsCountAs(int start, int end) {
    int res;

    if (end < start) {
      var t = start;
      start = end;
      end = t;
    }

    if (start > 0) {
      res = getLeapYearsCount(end) - getLeapYearsCount(start);
    } else if (start < 0 && end > 0) {
      res = getLeapYearsCount(start) + getLeapYearsCount(end);
    } else {
      res = (getLeapYearsCount(start) - getLeapYearsCount(end)).abs();
    }

    return res;
  }

  @override
  List<int> getLeapYears(int start, int end) {
    return getLunarLeapYears(start, end);
  }

  @override
  T getAsUTC<T extends ADateStructure>() {
    var res = LunarHijriDate.by(getValue());
    res.moveLocalToUTC();
    return res as T;
  }

  @override
  List<int> convertToGregorian() {
    var d = getDateAsDay();

    if (d > 0) {
      d += 227014;
    } else {
      d += 227015;
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

          year--;
        }

        year++;
      }

      year *= -1;
    }

    day = allDays;
    var mo = ADateStructure.gregorianMonths;

    if (ADateStructure.isGregorianLeapYear(year)) {
      mo = ADateStructure.gregorianMonthsLeap;
    }

    if (allDays > mo[m]) {
      do {
        monthDays += mo[m++];
      } while ((allDays - monthDays) > mo[m]);

      day = allDays - monthDays;
    }

    return [year, m, day]; // Month must sub -1
  }

  @override
  DateTime convertToSystemDate() {
    var ge = convertToGregorian();
    return DateTime(ge[0], ge[1], ge[2], hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  LunarHijriDate getFromSystemDate(DateTime date) {
    return _convertGregorianDaysToLunar(_convertSystemDateToDays(date));
  }

  static LunarHijriDate convertGregorianToLunar(int year, int month, int day) {
    var s = _convertGregorianDateToDays(year, month, day);
    return _convertGregorianDaysToLunar(s);
  }

  static LunarHijriDate _convertGregorianDaysToLunar(int days) {
    days -= 227014; //  {622/7/19} : (621*365)= 226665 + (150 Leap) + (31 + 28 + 31 + 30 + 31 + 30 + (16 or 19))

    if (days < 1) {
      days--;
    }

    return convertDaysToDate(days);
  }

  static int _convertGregorianDateToDays(int year, int month, int day) {
    int days = 0, inYear = year.abs();
    List<int> mo;

    if (ADateStructure.isGregorianLeapYear(year)) {
      mo = ADateStructure.gregorianMonthsLeap;
    } else {
      mo = ADateStructure.gregorianMonths;
    }

    for (int i = 0; i < (month - 1); i++) {
      days += mo[i];
    }

    days += day;

    int yearDays;
    yearDays = (inYear - 1) * 365;
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

  static LunarHijriDate convertDaysToDate(int days) {
    if (days == 0) {
      throw Exception('Err: convertDaysToDate(), days is 0. ');
    }

    int year = 1, leaps, leftDays;

    if (days > 0) {
      leftDays = days;

      if (leftDays > 354) {
        year = leftDays ~/ 354;
        leaps = getLeapYearsCount(year);

        year = (leftDays - leaps) ~/ 354;
        leaps = getLeapYearsCount(year +1); // updated: year  to {year +1}
        leftDays = leftDays - leaps - (year * 354);

        if (leftDays == 0) {
          leftDays = 354;
          if (isLunarLeapYear(year)) {
            leftDays++;
          }

          year--;
        }

        year++;
      }
    } else {
      leftDays = days.abs();
      leftDays--;

      if (leftDays > 354) {
        int temp = leftDays ~/ 354;
        leaps = getLeapYearsCount(-temp);

        year = (leftDays - leaps) ~/ 354;
        leaps = getLeapYearsCount(-(year + 1));
        leftDays = leftDays - leaps - (year * 354);

        year++;
      }

      year *= -1;

      int plu = isLunarLeapYear(year) ? 355 : 354;
      leftDays = plu - leftDays;
    }

    int day = leftDays, monthDays = 0, j = 0;
    List<int> mo = lunarMonthsLeap;

    if (day > mo[j]) {
      do {
        monthDays += mo[j++];
      } while ((leftDays - monthDays) > mo[j]);

      day = leftDays - monthDays;
    }

    return LunarHijriDate.get7(year, j + 1, day);
  }

  @override
  LunarHijriDate getFromDays(int days) {
    return convertDaysToDate(days);
  }

  static LunarHijriDate parseFrom(String? lunarHijriDate) {
    if (lunarHijriDate == null || lunarHijriDate.isEmpty) {
      throw ArgumentError('Err: parse(), LunarHijriDate can not parse ,parameter is invalid. ');
    }

    int y, m, d, h = 0, mi = 0, s = 0, ms = 0;
    late RegExpMatch match;
    var pat1 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})$');
    var pat2 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})$');
    var pat3 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})$');
    var pat4 = RegExp(r'([-]?\d{1,4})[/.-](\d{1,2})[/.-](\d{1,2})[tT\s_.-](\d{1,2})[:_-](\d{1,2})[:_-](\d{1,2})[.](\d{1,3})');

    var matched = false;

    if (pat1.hasMatch(lunarHijriDate)) {
      match = pat1.allMatches(lunarHijriDate).elementAt(0);
      matched = true;
    } else if (pat2.hasMatch(lunarHijriDate)) {
      matched = true;
      match = pat2.allMatches(lunarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
    } else if (pat3.hasMatch(lunarHijriDate)) {
      matched = true;
      match = pat3.allMatches(lunarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
    } else if (pat4.hasMatch(lunarHijriDate)) {
      matched = true;
      match = pat4.allMatches(lunarHijriDate).elementAt(0);
      h = int.parse(match.group(4)!);
      mi = int.parse(match.group(5)!);
      s = int.parse(match.group(6)!);
      ms = int.parse(match.group(7)!);
    }

    if (!matched) {
      throw ArgumentError('Err: parse(), can not parse lunar hijri date, parameter is not a valid date. ');
    }

    y = int.parse(match.group(1)!);
    m = int.parse(match.group(2)!);
    d = int.parse(match.group(3)!);

    return LunarHijriDate.full(y, m, d, h, mi, s, ms);
  }

  @override
  LunarHijriDate parse(String date) {
    return parseFrom(date);
  }

  @override
  int getYear() {
    _year ??= getYearFromDate(_value!);

    return _year!;
  }

  @override
  String getWeekDayName() {
    return weekDayNameInArabic[getWeekDay() - 1];
  }

  @override
  String getGregorianWeekDayName() {
    return GregorianDate.weekDayNameInLatin[getWeekDay() - 1];
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
  String getLocalWeekDayName(int day, String lang) // fa-IR
  {
    return weekDayNameInArabic[day - 1];
  }

  @override
  String getLatinWeekDayShortName(int day) {
    return getLatinWeekDayNameAs(day).substring(0, 3).toUpperCase();
  }

  @override
  String getLocalWeekDayShortName(int day, String lang) {
    return getLocalWeekDayName(day, lang).substring(0, 3);
  }

  @override
  String getLatinMonthName() {
    return monthNameInLatin[getMonth() - 1];
  }

  @override
  String getMonthName() {
    return monthNameInArabic[getMonth() - 1];
  }

  @override
  String getLocalMonthName(int month, String lang) {
    return monthNameInArabic[month - 1];
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
      year = days ~/ 354;

      if (year != 0) {
        leapYears = getLeapYearsCount(year);
      }

      leftDays = days - leapYears;
      year = leftDays ~/ 354;
      leftDays = leftDays - (year * 354);

      //if (leftDays == 0 || (leftDays == 1 && isLeapYearAs(year)))  updated: (1401,12,29) moveDay +1 was mistake
      if (leftDays == 0) {
        return year;
      } else {
        return ++year;
      }
    } else {
      days = (ADateStructure._getDateSection(date)).abs();
      year = days ~/ 354;

      if (year != 0) {
        leapYears = getLeapYearsCount(-year);
      }

      leftDays = days - leapYears;
      year = leftDays ~/ 354;
      leftDays = leftDays - (year * 354);

      if (leftDays == 0) {
        return (-1 * year);
      } else {
        return (-1 * ++year);
      }
    }
  }

  static int getMonthFromDate(int inDate) {
    int day, leaps;
    var years = getYearFromDate(inDate);

    if (inDate > 0) {
      leaps = getLeapYearsCount(years);
      day = ADateStructure._getDateSection(inDate) - ((years - 1) * 354);
      day = day - leaps;
    } else {
      leaps = getLeapYearsCountAs(years + 1, 0);
      day = (-years * 354) + 1 + ADateStructure._getDateSection(inDate);
      day = day + leaps;
    }

    if (day < 31) return 1;

    var i = 0;
    for (; i < lunarMonths.length; i++) {
      day -= lunarMonthsLeap[i];

      if (i < 11 && day <= lunarMonthsLeap[i + 1]) {
        break;
      }
    }

    return (i + 2);
  }

  @override
  int getMonth() {
    _month ??= getMonthFromDate(_value!);

    return _month!;
  }

  @override //dayInMonth$
  int getDay() {
    var days = getDayInYear();

    if (days > 30) {
      for (var i = 0; i < lunarMonths.length; i++) {
        days -= lunarMonthsLeap[i];

        if (i < 11 && days <= lunarMonthsLeap[i + 1]) {
          break;
        }
      }
    }

    return days;
  }

  @override
  int getLastDayOfMonth() {
    var mon = getMonth();

    if (isLeapYear()) {
      return lunarMonthsLeap[mon];
    }
    return lunarMonths[mon];
  }

  @override
  bool isEndOfMonth() {
    var day = getDay();
    var mon = getMonth();

    if (isLeapYear()) {
      return day == lunarMonthsLeap[mon - 1];
    }
    return day == lunarMonths[mon - 1];
  }

  @override
  int getLastDayOfMonthFor(int year, int month) {
    if (isLunarLeapYear(year)) {
      return lunarMonthsLeap[month - 1];
    } else {
      return lunarMonths[month - 1];
    }
  }

  @override
  LunarHijriDate getFirstOfMonth() {
    return LunarHijriDate.full(getYear(), getMonth(), 1, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  LunarHijriDate getEndOfMonth() {
    int d, m = getMonth();

    if (isLeapYear()) {
      d = lunarMonthsLeap[m - 1];
    } else {
      d = lunarMonths[m - 1];
    }

    return LunarHijriDate.full(getYear(), m, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  LunarHijriDate getEndOfNextMonth() {
    int day;
    var m = getMonth();
    var y = getYear();
    var nextM = m % 12;
    /*var isLeap;

    if (m < 12) {
      isLeap = isLeapYear();
    } else {
      y++;
      isLeap = isLeapYearAs(y);
    }*/

    /*if (isLeap)
      day = lunarMonthsLeap[nextM];
    else*/ // updated, mistake
    day = lunarMonths[nextM];

    return LunarHijriDate.full(y, nextM + 1, day, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override
  LunarHijriDate getEndOfPrevMonth() {
    int d;
    var m = getMonth();
    var y = getYear();
    var preM = (m + 10) % 12;

    bool b;

    if (m > 1) {
      b = isLeapYear();
    } else {
      y--;
      b = isLeapYearAs(y);
    }

    if (b) {
      d = lunarMonthsLeap[preM];
    } else {
      d = lunarMonths[preM];
    }

    return LunarHijriDate.full(y, preM + 1, d, hoursOfToday(), minutesOfToday(), secondsOfToday(), milliSecondsOfToday());
  }

  @override // dayInYear$
  int getDayInYear() {
    return getDayInYearFromDate(_value!);
  }

  @override
  bool isPastOf(int milSeconds) {
    ADateStructure now = LunarHijriDate();
    var dayDif = ADateStructure._getDateSection(now.getValue()) - ADateStructure._getDateSection(getValue());
    var secDif = ADateStructure._getTimeSection(now.getValue()) - ADateStructure._getTimeSection(getValue());

    return (ADateStructure.convertDayToMils(dayDif) + secDif) > milSeconds;
  }

  static int getDayInYearFromDate(int inDate) {
    int day, leaps;
    var year = getYearFromDate(inDate);

    if (inDate > 0) {
      leaps = getLeapYearsCount(year);
      day = ADateStructure._getDateSection(inDate) - ((year - 1) * 354);
      day = day - leaps;
    } else {
      leaps = getLeapYearsCount(year);
      day = (-year * 354) + 1 + leaps;
      day = day + ADateStructure._getDateSection(inDate);
    }

    return day;
  }

  @override
  LunarHijriDate moveDay(int days) {
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
  LunarHijriDate moveDayClone(int days) {
    var res = clone();
    res.moveDay(days);

    return res as LunarHijriDate;
  }

  @override
  LunarHijriDate addMonth(int months) {
    var isMinus = false;
    if (months < 0) {
      months = months.abs();
      isMinus = true;
    }

    var days = 0;
    if (months > 11) {
      while (months > 11) {
        days += 354;
        months = months - 12;
      }
    }

    days += (months * 29.53).floor();

    if (isMinus) {
      days *= -1;
    }

    moveDay(days);

    return this;
  }

  @override
  LunarHijriDate moveMonth(int months, bool tallyEndMonth) {
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

          if (!isLeapYearAs(thisYear) && isLeapYearAs(thisYear - w - add)) days--;
        }

        while (w > 0) {
          thisYear--;
          if (isPlus && thisYear < 1) {
            thisYear--;
            isPlus = false;
          }

          days += isLeapYearAs(thisYear) ? 355 : 354;

          w--;
          months -= 12;
        }
      } else {
        if (tallyEndMonth && (months % 12 == 0) && thisDay == 29 && thisMonth == 12) {
          var add = (!isPlus && (thisYear + w) > -1) ? 1 : 0;

          if (isLeapYearAs(thisYear + w + add) && !isLeapYearAs(thisYear)) days++;
        }

        while (w > 0) {
          days += isLeapYearAs(thisYear) ? 355 : 354;
          thisYear++;

          if (!isPlus && thisYear > -1) {
            thisYear++;
            isPlus = true;
          }

          w--;
          months -= 12;
        }
      }

      if (thisMonth == 12 && thisDay == 30 && !isLeapYearAs(thisYear)) {
        if (isMinus) {
          days++;
        } else {
          days--;
        }
      }

      thisYear += w;
    }

    if (months > 0) {
      var across = false;
      int endOfThis, endOfSide;
      var mo = lunarMonths;

      if (isLeapYearAs(thisYear)) mo = lunarMonthsLeap;

      for (var i = 0; i < months; i++) {
        if (isMinus) {
          if (!across && (thisMonth - i) <= 1) {
            across = true;
            thisYear--;

            if (isPlus && thisYear < 1) {
              thisYear--;
              isPlus = false;
            }

            if (isLeapYearAs(thisYear)) {
              mo = lunarMonthsLeap;
            } else {
              mo = lunarMonths;
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

            if (isLeapYearAs(thisYear)) {
              mo = lunarMonthsLeap;
            } else {
              mo = lunarMonths;
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
  LunarHijriDate moveYear(int years, bool tallyEndMonth) {
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

    var days = years * 354;

    if (isMinus) {
      if (thisYear > 0 && (thisYear - years) < 1) years++;

      days += getLeapYearsCountAs(thisYear + (-years), thisYear);
    } else {
      if (thisYear < 0 && (thisYear + years) > -1) years++;

      days += getLeapYearsCountAs(thisYear, thisYear + years);
    }

    if (isMinus) {
      if (thisMonth == 12 && thisDay == 30 && !isLeapYearAs(thisYear + (-years))) days++;

      if (tallyEndMonth && isEndOfMonth() && thisDay < 30 && isLeapYearAs(thisYear + (-years)) && !isLeapYearAs(thisYear)) days--;
    } else {
      if (thisMonth == 12 && thisDay == 30 && !isLeapYearAs(thisYear + years)) days--;

      if (tallyEndMonth && isEndOfMonth() && thisDay < 30 && isLeapYearAs(thisYear + years) && !isLeapYearAs(thisYear)) days++;
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
    return LunarHijriDate.full(getYear(), getMonth(), getDay(), hoursOfToday(),
        minutesOfToday(), secondsOfToday(), milliSecondsOfToday()) as T;
  }

  @override
  LunarHijriDate changeTo(int year, int month, int day, int hour, int min, int sec, int mil, bool dayLight) {
    _init(year, month, day, hour, min, sec, mil);
    _reset();
    return this;
  }
}
///==================================================================================================

