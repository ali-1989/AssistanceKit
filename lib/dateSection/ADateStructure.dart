import 'dart:core';
import 'package:assistance_kit/dateSection/timeZone.dart';

part 'ADateStructureP1.dart';
part 'ADateStructureP2.dart';
part 'ADateStructureP3.dart';

abstract class ADateStructure implements Comparable<ADateStructure> {
  static final int oneHourInSec = 60 * 60 * 1000;
  static final int oneMinInSec = 60 * 1000;
  static final int _eightZero = 100000000;

  int? _value;
  int? _year;
  int? _month;
  int? _hours;
  int? _minutes;
  int? _seconds;
  int? _allDaysOfDate;
  int startOfWeekDay = 1;
  String _timeZone = TimeZone.getCurrentTimezone();
  bool _useDST = true;

  static final List<int> gregorianMonths = [
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  static final List<int> gregorianMonthsLeap = [
    31,
    29,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];


  static bool isGregorianLeapYear(int year) {
    if (year == 0) {
      return false;
    }

    if (year < 0) {
      year *= -1;
    }

    var x = false;

    if (year % 4 == 0) {
      x = true;
      if (year % 100 == 0 && year % 400 != 0) {
        x = false;
      }
    }

    return x;
  }

  static List<int> getGregorianLeapYears(int start, int end) { //  := [start, end)
    var res = List<int>.empty(growable: true);

    if (end < start) {
      var t = start;
      start = end;
      end = t;
    }

    while (start < end) {
      if (isGregorianLeapYear(start)) {
        res.add(start);
        start += 3;
      }

      start++;
    }

    return res;
  }

  bool useDST(){
    return _useDST;
  }

  void stUseDST(bool state){
    _useDST = state;
  }

  bool isAtDaylightRange(){
    /// این به کشور جاری مربوط می شود پس باید کشور دریافت شود و بر مبنای تاریخ میلادی چک شود ایا در بازه هست یا خیر

    if(isCountryDayLightActive()){
      final dt = convertToSystemDate();

      final base = DateTime(dt.year, dt.month, dt.day);
      final baseUtc = DateTime.utc(dt.year, dt.month, dt.day);

      final moveTemp = base.add(Duration(days: 190));

      final move = DateTime(moveTemp.year, moveTemp.month, moveTemp.day);
      final moveUtc = DateTime.utc(moveTemp.year, moveTemp.month, moveTemp.day);

      final dif1 = base.difference(baseUtc);
      final dif2 = move.difference(moveUtc);

      if(dif1 == dif2){
        return false;
      }

      return dif1 < dif2;
    }

    return false;
  }

  bool isValidDate();
  bool isLeapYear();
  List<int> getLeapYears(int start, int end); //  := [start, end)

  List<int> dateLeapYears() {
    return getLeapYears(0, getYear());
  }

  bool getDaylightState();

  void _reset() {
    _allDaysOfDate = null;
    _year = null;
    _month = null;
    _hours = null;
    _minutes = null;
    _seconds = null;
  }

  void _setValue(int date) {
    _value = date;
  }

  int getValue() {
    return _value!;
  }

  String getTimeZone() {
    return _timeZone;
  }

  void attachTimeZone(String tz) {
    _timeZone = tz;
  }

  T getAsUTC<T extends ADateStructure>();

  List<int> convertToGregorian();
  DateTime convertToSystemDate();
  ADateStructure getFromSystemDate(DateTime date);
  ADateStructure getFromDays(int days);
  ADateStructure parse(String date);
  int getYear();
  int getMonth();
  int getWeekDay();
  String getLatinWeekDayNameAs(int day);
  String getLatinWeekDayShortName(int day);
  String getLocalWeekDayName(int day, String lang);
  String getLocalWeekDayShortName(int day, String lang);
  String getGregorianWeekDayName();
  String getLatinWeekDayName();
  String getWeekDayName();
  String getMonthName();
  String getLatinMonthName();
  String getLocalMonthName(int month, String lang);
  bool isEndOfMonth();
  int getLastDayOfMonth();
  ADateStructure getFirstOfMonth();
  int getLastDayOfMonthFor(int year, int month);
  ADateStructure getEndOfMonth();
  ADateStructure getEndOfNextMonth();
  ADateStructure getEndOfPrevMonth();
  int getDay();

  bool isPM() {
    return (hoursOfToday() > 11);
  }

  int startOfWeek() {
    return startOfWeekDay;
  }

  void setStartOfWeek(int day) {
    if (day < 1 || day > 7) {
      return;
    }

    startOfWeekDay = day;
  }

  int getWeekAtYear() {
    var d = getDayInYear();

    if (d < 7) {
      return 1;
    }

    var r = d ~/ 7;

    if ((d % 7) == 0) {
      return r;
    } else {
      return r + 1;
    }
  }

  int getWeekAtMonth() {
    var d = getDay();

    if (d < 7) {
      return 1;
    }

    var r = d ~/ 7;

    if ((d % 7) == 0) {
      return r;
    } else {
      return r + 1;
    }
  }

  int getDateAsDay() {
    _allDaysOfDate ??= _getDateSection(_value!);

    return _allDaysOfDate!;
  }

  int getDayInYear();

  static int _getTimeSection(int inDate) {
    var d = inDate.abs();
    var x = d.toString();

    var L = x.length;
    var res = x.substring(L - 8, L);

    return int.parse(res);
  }

  static int _getDateSection(int inDate) {
    var d = inDate.abs();
    var x = d.toString();

    var L = x.length;
    var res = x.substring(0, L - 8);

    if (inDate > 0) {
      return int.parse(res);
    } else {
      return -1 * int.parse(res);
    }
  }

  static int hoursOfTodayFrom(int value) {
    return _getTimeSection(value) ~/ oneHourInSec;
  }

  int hoursOfToday() {
    if (_hours != null) {
      return _hours!;
    }

    return _hours = _getTimeSection(_value!) ~/ oneHourInSec;
  }

  static int minutesOfTodayFrom(int value) {
    return (_getTimeSection(value) - (hoursOfTodayFrom(value) * oneHourInSec)) ~/ oneMinInSec;
  }

  int minutesOfToday() {
    if (_minutes != null) {
      return _minutes!;
    }

    return _minutes = (_getTimeSection(_value!) - (hoursOfToday() * oneHourInSec)) ~/ oneMinInSec;
  }

  int secondsOfToday() {
    if (_seconds != null) {
      return _seconds!;
    }

    return _seconds = (_getTimeSection(_value!) - ((hoursOfToday() * oneHourInSec) + (minutesOfToday() * oneMinInSec))) ~/ 1000;
  }

  int secondsOfTodayFrom(int inDate) {
    return (_getTimeSection(inDate) -
            ((hoursOfTodayFrom(inDate) * oneHourInSec) +
                (minutesOfTodayFrom(inDate) * oneMinInSec))) ~/ 1000;
  }

  int milliSecondsOfToday() {
    return _getTimeSection(_value!) -
        ((hoursOfToday() * oneHourInSec) + (minutesOfToday() * oneMinInSec) + (secondsOfToday() * 1000));
  }

  ADateStructure moveDay(int days);
  ADateStructure moveDayClone(int days);
  ADateStructure addMonth(int months);
  ADateStructure moveMonth(int months, bool tallyEndMonth);
  ADateStructure moveYear(int years, bool tallyEndMonth);
  ADateStructure moveWeek(int weeks);

  void changeTime(int hour, int min, int sec, int mil) {
    if (hour < 0 ||
        hour > 23 ||
        min < 0 ||
        min > 59 ||
        sec < 0 ||
        sec > 59 ||
        mil < 0 ||
        mil > 999) {
      throw Exception('Err: changeTime(), parameters are invalid ($hour:$min:$sec). ');
    }

    var time = 0;

    time += hour * oneHourInSec;
    time += min * oneMinInSec;
    time += sec * 1000;
    time += mil;

    var res = _value! ~/ _eightZero;
    res *= _eightZero;

    _setValue(res + time);

    _reset();
  }

  bool isCountryDayLightActive(){
    Duration? dif;
    var dl = false;
    final today = DateTime.now();

    for(int i=1; i <= 12; i++){
      var d1 = DateTime(today.year, i, 1);
      final d12 = DateTime.utc(today.year, i, 1);

      if(dif == null) {
        dif = d1.difference(d12);
        continue;
      }

      if(dif != d1.difference(d12)){
        dl = true;
        break;
      }
    }

    return dl;
  }

  void changeTimezone(String tz){
    _timeZone = tz;
  }

  T moveHour<T extends ADateStructure>(int addHor) {
    var days = 0;
    var curHours = hoursOfToday();
    var allHours = curHours + addHor;

    if (allHours > 23) {
      days = allHours ~/ 24;
      addHor = allHours - (days * 24);
    } else if (allHours < 0) {
      addHor = addHor.abs();
      days = addHor ~/ 24;
      var leftHor = addHor - (days * 24);
      var newHor = curHours - leftHor;
      days = days * -1;

      if (newHor < 0) {
        days--;
        newHor = 24 + newHor;
      }

      addHor = newHor;
    } else {
      addHor = allHours;
    }

    changeTime(addHor, minutesOfToday(), secondsOfToday(), milliSecondsOfToday());

    if (days != 0) moveDay(days);

    return this as T;
  }

  T moveMinute<T extends ADateStructure>(int addMins) {
    var hours = 0;
    var curMinutes = minutesOfToday();
    var allMinutes = curMinutes + addMins;

    if (allMinutes > 59) {
      hours = allMinutes ~/ 60;
      addMins = allMinutes - (hours * 60);
    } else if (allMinutes < 0) {
      addMins = addMins.abs();
      hours = addMins ~/ 60;
      var leftMin = addMins - (hours * 60);
      var newMin = curMinutes - leftMin;
      hours = hours * -1;

      if (newMin < 0) {
        hours--;
        newMin = 60 + newMin;
      }

      addMins = newMin;
    } else {
      addMins = allMinutes;
    }

    changeTime(hoursOfToday(), addMins, secondsOfToday(), milliSecondsOfToday());

    if (hours != 0) {
      moveHour(hours);
    }

    _reset();
    return this as T;
  }

  T moveSecond<T extends ADateStructure>(int addSec) {
    var minutes = 0;
    var curSeconds = secondsOfToday();
    var allSeconds = curSeconds + addSec;

    if (allSeconds > 59) {
      minutes = allSeconds ~/ 60;
      addSec = allSeconds - (minutes * 60);
    } else if (allSeconds < 0) {
      addSec = addSec.abs();
      minutes = addSec ~/ 60;
      var leftSec = addSec - (minutes * 60);
      var newSec = curSeconds - leftSec;
      minutes = minutes * -1;

      if (newSec < 0) {
        minutes--;
        newSec = 60 + newSec;
      }

      addSec = newSec;
    } else {
      addSec = allSeconds;
    }

    changeTime(hoursOfToday(), minutesOfToday(), addSec, milliSecondsOfToday());

    if (minutes != 0) {
      moveMinute(minutes);
    }

    _reset();
    return this as T;
  }

  T moveMillSecond<T extends ADateStructure>(int addMils) {
    var seconds = 0;
    var curMills = milliSecondsOfToday();
    var allMils = curMills + addMils;

    if (allMils > 999) {
      seconds = allMils ~/ 1000;
      addMils = allMils - (seconds * 1000);
    } else if (allMils < 0) {
      addMils = addMils.abs();
      seconds = addMils ~/ 1000;
      var leftMil = addMils - (seconds * 1000);
      var newMil = curMills - leftMil;
      seconds *= -1;

      if (newMil < 0) {
        seconds--;
        newMil = 1000 + newMil;
      }

      addMils = newMil;
    } else {
      addMils = allMils;
    }

    changeTime(hoursOfToday(), minutesOfToday(), secondsOfToday(), addMils);

    if (seconds != 0) {
      moveSecond(seconds);
    }

    _reset();
    return this as T;
  }

  int _getTimeZoneOffset(){
    final res = TimeZone.getOffsetAsMillis(_timeZone)!;
    return  getDaylightState()? res.dayLight : res.nonDayLight;
  }

  /*void moveUtcToLocal<T extends ADateStructure>() {
    final temp = DateTime.now();
    //var dt = DateTime(2021,4,4); error for dayLight
    var localOffset = temp.timeZoneOffset.inMilliseconds;

    *//*if(!getDaylightState()){
      localOffset -= 60*60*1000;
    }*//*

    if (_getTimeZoneOffset() == localOffset) {
      return;
    }

    moveMillSecond(localOffset);

    //final now = GregorianDate();
    _timeZone = TimeZone.getFirstTimeZoneByOffset(localOffset);//dayLight: getDaylightState()
    //return this as T;
  }*/

  void moveUtcToLocal<T extends ADateStructure>() {
    final temp = convertToSystemDate();//DateTime.now();
    final localOffset = temp.timeZoneOffset.inMilliseconds;

    if (_getTimeZoneOffset() == localOffset) {
      return;
    }

    moveMillSecond(localOffset);

    if(getDaylightState()) {
      _timeZone = TimeZone.getFirstTimeZoneByOffsetInDayLightPeriod(localOffset);
    }
    else {
      _timeZone = TimeZone.getFirstTimeZoneByOffset(localOffset);
    }
  }

  void moveLocalToUTC<T extends ADateStructure>() {
    var temp = DateTime.now().toUtc();
    var localOffset = _getTimeZoneOffset();

    if (temp.timeZoneOffset.inMilliseconds == localOffset) {
      return;
    }

    moveMillSecond(-localOffset);
    _timeZone = 'utc';
  }

  int getUtcDistanceInSecond() {
    //var format = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]);
    //var dDay = DateTime.parse(format);
    //return dDay.timeZoneOffset.inSeconds;

    return _getTimeZoneOffset() ~/ 1000;
  }

  List<int> splitDateAndTime() {
    return [_getDateSection(_value!), _getTimeSection(_value!)];
  }

  @override
  int compareTo(ADateStructure inDate) {
    if (runtimeType != inDate.runtimeType) {
      throw Exception('Err: compareTo(), dates are not in same type. ');
    }

    if (_value == inDate.getValue()) {
      return 0;
    }

    if (_value! > inDate.getValue()) {
      return 1;
    }

    return -1;
  }

  int compareDateOnly(ADateStructure inDate) {
    if (runtimeType != inDate.runtimeType) {
      throw Exception('Err: compareDate(), dates are not in same type. ');
    }

    if (getDateAsDay() == inDate.getDateAsDay()) {
      return 0;
    }

    if (getDateAsDay() > inDate.getDateAsDay()) {
      return 1;
    }

    return -1;
  }

  bool isPastOf(int milSeconds);

  static int convertDayToMils(int day) {
    return day * 24 * 60 * 60 * 1000;
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ADateStructure && compareTo(other) == 0;
  }

  bool isBefore(ADateStructure compDate) {
    return compareTo(compDate) == -1;
  }

  bool isBeforeDate(ADateStructure compDate) {
    return compareDateOnly(compDate) == -1;
  }

  bool isBeforeEqual(ADateStructure compDate) {
    return compareTo(compDate) == -1 || compareTo(compDate) == 0;
  }

  bool isAfter(ADateStructure compDate) {
    return compareTo(compDate) == 1;
  }

  bool isAfterEqual(ADateStructure compDate) {
    return compareTo(compDate) == 1 || compareTo(compDate) == 0;
  }

  String getCommonFormat() {
    return format('YYYY/MM/DD HH:TT:SS:ZZ', 'en');
  }

  // 'YYYY/MM/DD HH:TT:SS:ZZ'
  String format(String format, String langCode) {
    String res = format, rep;

    var patYY = RegExp(r'(^|[^Y]+)(YYYY)((?!Y).*?Y*|$)',
        caseSensitive: false, multiLine: true);
    var patY = RegExp(r'(^|[^Y]+)(YY)((?!Y).*?Y*|$)',
        caseSensitive: false, multiLine: true);
    var patM = RegExp(r'(^|[^M]+)(M)((?!M).*?M*|$)',
        caseSensitive: true, multiLine: true); // Month
    var patMM = RegExp(r'(^|[^M]+)(MM)((?!M).*?M*|$)',
        caseSensitive: true, multiLine: true); // Month 2 Digit
    var patD = RegExp(r'(^|[^D]+)(D)((?!D).*?D*|$)',
        caseSensitive: false, multiLine: true); // Day
    var patDD = RegExp(r'(^|[^D]+)(DD)((?!D).*?D*|$)',
        caseSensitive: false, multiLine: true); // Day 2 Digit
    var patHH = RegExp(r'(^|[^H]+)(HH)((?!H).*?H*|$)',
        caseSensitive: true, multiLine: true); // Hour
    var pat$h = RegExp(r'(^|[^h]+)(hh)((?!h).*?h*|$)',
        caseSensitive: true, multiLine: true); // hour
    var patMin2 = RegExp(r'(^|[^m]+)(mm)((?!m).*?m*|$)',
        caseSensitive: true, multiLine: true); // Minutes
    var patMin1 = RegExp(r'(^|[^m]+)(m)((?!m).*?m*|$)',
        caseSensitive: true, multiLine: true); // Minutes
    var patS1 = RegExp(r'(^|[^S]+)(SS)((?!S).*?S*|$)',
        caseSensitive: false, multiLine: true); // Seconds
    var patS2 = RegExp(r'(^|[^S]+)(S)((?!S).*?S*|$)',
        caseSensitive: false, multiLine: true); // Seconds
    var patZ = RegExp(r'(^|[^Z]+)(ZZ)((?!Z).*?Z*|$)',
        caseSensitive: false, multiLine: true); // Milli Seconds
    var patA = RegExp(r'(^|[^A]+)(AA)((?!A).*?A*|$)',
        caseSensitive: false, multiLine: true); // PM/AM
    var patW = RegExp(r'(^|[^W]+)(WW)((?!W).*?W*|$)',
        caseSensitive: false, multiLine: true); // Local WeekDay ShortName
    var patN = RegExp(r'(^|[^N]+)(NN)((?!N).*?N*|$)',
        caseSensitive: false, multiLine: true); // Local Month Name
    var patE = RegExp(r'(^|[^E]+)(EEE)((?!E).*?E*|$)',
        caseSensitive: false, multiLine: true); // Local WeekDay Name

    int gStart(String res, RegExpMatch match, int group) {
      return res.indexOf(match.group(2)!, match.start);
    }

    int gEnd(String res, RegExpMatch match, int group) {
      return res.indexOf(match.group(group)!, match.start) + match.group(group)!.length;
    }

    /*String wrapByLtr(String inp){
      return '\u202A' + inp + '\u202C';
    }*/

    String wrapByRtl(String inp){
      return '\u202B$inp\u202C';
    }

    RegExpMatch match;

    if (patYY.hasMatch(res)) {
      match = patYY.allMatches(res).elementAt(0);
      rep = getYear().toString();
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = getYear().toString();
    var L = rep.length;
    rep = rep.substring(0, L);

    if (L == 3) {
      rep = rep.substring(L - 1, L);
    } else if (L == 4) {
      rep = rep.substring(L - 2, L);
    }

    while (patY.hasMatch(res)) {
      match = patY.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = getMonth().toString();
    while (patM.hasMatch(res)) {
      match = patM.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = getMonth().toString();

    if (rep.length < 2) rep = '0$rep';

    while (patMM.hasMatch(res)) {
      match = patMM.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = getDay().toString();
    while (patD.hasMatch(res)) {
      match = patD.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = getDay().toString();

    if (rep.length < 2) rep = '0$rep';

    while (patDD.hasMatch(res)) {
      match = patDD.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = hoursOfToday().toString();
    if (rep.length < 2) rep = '0$rep';

    while (patHH.hasMatch(res)) {
      match = patHH.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = minutesOfToday().toString();
    while (patMin1.hasMatch(res)) {
      match = patMin1.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = minutesOfToday().toString();
    if (rep.length < 2) rep = '0$rep';

    while (patMin2.hasMatch(res)) {
      match = patMin2.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = secondsOfToday().toString();
    while (patS1.hasMatch(res)) {
      match = patS1.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = secondsOfToday().toString();
    while (patS2.hasMatch(res)) {
      match = patS2.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = milliSecondsOfToday().toString();
    while (patZ.hasMatch(res)) {
      match = patZ.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    rep = hoursOfToday() > 11 ? 'PM' : 'AM';
    while (patA.hasMatch(res)) {
      match = patA.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    var h = hoursOfToday();
    h = h > 12 ? h - 12 : h;

    if (h == 0) h = 12;

    rep = h.toString();

    while (pat$h.hasMatch(res)) {
      match = pat$h.allMatches(res).elementAt(0);
      res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
    }

    if (patN.hasMatch(res)) {
      rep = getLocalMonthName(getMonth(), langCode);

      if(_hasRtlChar(rep)) {
        rep = wrapByRtl(rep);
      }

      while (patN.hasMatch(res)) {
        match = patN.allMatches(res).elementAt(0);
        res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
      }
    }

    if (patW.hasMatch(res)) {
      rep = getLocalWeekDayShortName(getWeekDay(), langCode);

      if(_hasRtlChar(rep)) {
        rep = wrapByRtl(rep);
      }

      while (patW.hasMatch(res)) {
        match = patW.allMatches(res).elementAt(0);
        res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
      }
    }

    if (patE.hasMatch(res)) {
      rep = getLocalWeekDayName(getWeekDay(), langCode);

      if(_hasRtlChar(rep)) {
        rep = wrapByRtl(rep);
      }

      while (patE.hasMatch(res)) {
        match = patE.allMatches(res).elementAt(0);
        res = _insertText(res, rep, gStart(res, match, 2), gEnd(res, match, 2));
      }
    }

    return res;
  }

  String _insertText(String content, String text, int start, int end) {
    var sec1 = content.substring(0, start);
    var sec2 = content.substring(end, content.length);
    return sec1 + text + sec2;
  }

  bool _hasRtlChar(String inp){
    var arabicPersian = RegExp('[\u0600-\u06FF\u0750-\u077F\u08A0–\u08FF\uFB50–\uFBC1\uFBD3-\uFD3F\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFD\uFE70-\uFEFC\u0660-\u0669\u06F0-\u06F9]+', caseSensitive: false, multiLine: true);
    return arabicPersian.hasMatch(inp);

    // https://en.wikipedia.org/wiki/List_of_Unicode_characters
    // https://en.wikipedia.org/wiki/Arabic_script_in_Unicode
    // https://en.wikipedia.org/wiki/Persian_alphabet
    // arabic Number: \u0660-\u0669
    // persian Number: \u06F0-\u06F9
  }

  T clone<T extends ADateStructure>();

  ADateStructure changeTo(int year, int month, int day, int hour, int min, int sec, int mil, bool dayLight);

  bool isSame(ADateStructure other) {
    return getValue() == other.getValue();
  }

  bool isSameDateOnly(ADateStructure other) {
    return (getYear() == other.getYear() &&
        getMonth() == other.getMonth() &&
        getDay() == other.getDay());
  }

  bool isSameYearAndMonth(ADateStructure other) {
    return (getYear() == other.getYear() && getMonth() == other.getMonth());
  }

  bool isBiggerMonth(ADateStructure other) {
    return (getYear() == other.getYear() && getMonth() > other.getMonth());
  }

  bool isLittleMonth(ADateStructure other) {
    return (getYear() == other.getYear() && getMonth() < other.getMonth());
  }

  bool isSameYear(ADateStructure other) {
    return getYear() == other.getYear();
  }

  @override
  String toString() {
    return '${getYear()}/${getMonth()}/${getDay()}' ' ${hoursOfToday()}:${minutesOfToday()}:${secondsOfToday()},${milliSecondsOfToday()}';
  }

  String logDate() {
    return '${getYear()}/${getMonth()}/${getDay()}';
  }
  ///------------------------------------------------------------------------------------------
  int backwardStepInRing(int current, int step, int allCount, bool baseIsOne) {
    int def, r;

    if (baseIsOne) {
      if (current < 1) {
        current = 1;
      }

      def = current - step.abs();
      r = def + allCount;
      var x = r % allCount;

      if (x == 0) {
        x = allCount;
      }

      return x;
    }
    else {
      if (current > allCount) {
        current = allCount;
      }

      def = current - step.abs();
      r = def + allCount;
      return r % allCount;
    }
  }
}
