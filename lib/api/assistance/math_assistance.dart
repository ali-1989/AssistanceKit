// Dart imports:
import 'dart:math' ;

// Project imports:
import 'package:assistance_kit/api/assistance/converter_assistance.dart';

// BigInt.from(5);

class MathAssistance {
  MathAssistance._();

  static int clearToInt(dynamic inp, {int def = 0}){
    if(inp == null){
      return def;
    }

    if(inp is double){
      return inp.toInt();
    }

    var v = inp.toString().trim();

    v = ConverterAssistance.numberToEnglish(v)!;
    v = ConverterAssistance.removeMarks(v)!;
    v = v.replaceFirst(RegExp(r'$0+(?=(-|\+|[1-9]))'), '');
    v = v.replaceAll(RegExp(r'(?<!^)-|[^\d-]'), '');

    if(v == '-') {
      v = '-0';
    }

    return int.tryParse(v)?? def;
  }

  static double clearToDouble(dynamic inp, {double def = 0.0, int precisionRound = 0}){
    if(inp == null){
      return def;
    }

    var v = inp.toString().trim();

    v = ConverterAssistance.numberToEnglish(v)!;
    v = ConverterAssistance.removeMarks(v)!;

    v = v.replaceFirst(RegExp('\\\$0+(?=(-|\\+|[1-9]))'), '');
    v = v.replaceAll(RegExp(r'(?<!^)-|[^\d.-]'), '');

    if(v == '-') {
      v = '-0';
    }

    var result = double.tryParse(v)?? def;

    if(precisionRound > 0){
      result = fixPrecisionRound(result, precisionRound);
    }

    return result;
  }

  static int toInt(String inp, {int def = 0}){
    return int.tryParse(inp)?? def;
  }

  static int? toIntNullable(String inp, {int? def}){
    return int.tryParse(inp)?? def;
  }

  static double toDouble(dynamic inp, {double def = 0.0}){
    if(inp == null) {
      return def;
    }

    return double.tryParse(inp)?? def;
  }

  static int minInt(int a, int b){
    return min(a, b);
  }

  static int maxInt(int a, int b){
    return max(a, b);
  }

  static double minDouble(double? a, double? b){
    return min(a?? 0, b?? 0);
  }

  static double maxDouble(double a, double b){
    return max(a, b);
  }

  static double percent(num whole, num per){
    return (per * whole) / 100; // 25% of 500 => [25 * 500 / 100] = 12500/100 = 125    (4 * 125 = 500)
  }

  static double whatPercent(double whole, int num){
    return num * 100 / whole; // 125 of 500 => [125 * 100 / 500] = 12500/800 = 25%
  }

  double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  /// 12.34567 => 12.35
  static double percentFixPrecision(double whole, int per){
    return fixPrecisionRound(percent(whole, per), 1);
  }

  static int percentInt(num whole, num per){
    return (per * whole) ~/ 100; //  40% of 200x => 40*200/100 = 80        1402/02/17
  }

  static int whatPercentInt(int whole, int num){
    return num * 100 ~/ whole;
  }

  static double degreesToRadian(double deg) {
    return deg * pi / 180;
  }

  static double abs(double num) {
    return num.abs();
  }

  static int absInt(int num) {
    return num.abs();
  }

  // toPrecision(2.3456789, 2); >>  2.35
  static double fixPrecisionRound(double d, int n) {
    return double.parse(d.toStringAsFixed(n));
  }

  // toPrecision(2.3456789, 2); >>  2.34
  static double fixPrecision(double val, int count){
    var mod = pow(10.0, count).toDouble();
    return ((val * mod).roundToDouble() / mod);
  }

  //  getDegrees(3.34);    >> 0.3400000000
  static double getDegrees(double d) {
    return (d % 1);
  }

  //  getDecimal(3.34);    >> 3
  static int getDecimal(double d) {
    return d.truncate();
  }

  static double getDecimalDouble(double d) {
    return d.truncateToDouble();
  }

  //  getFraction(3.34, 2);    >> 0.34
  static double getFraction(double d, int count) {
    return double.parse((d % 1).toStringAsFixed(count));
  }

  static int fractionCount(double d) {
    var s = d.toString();
    var sp = s.split('.');

    return sp.length < 2? 0 : sp[1].length;
  }

  //  getFractionAsInt(3.4108);    >> 4108
  //  getFractionAsInt(3.0490);    >> 48
  static int getFractionAsInt(double d) {
    //return ((d - d.truncate()) * math.pow(10, count)).truncate();
    return ((d - d.truncate()) * pow(10, fractionCount(d))).truncate();
  }

  //  getFractionAsIntUp(3.4108, 4);    >> 4108
  //  getFractionAsIntUp(3.4108, 3);    >> 411
  static int getFractionAsIntUp(double d, int count) {
    return ((d % 1) * pow(10, count)).round();
  }

  //  getFractionAsIntDown(3.4108, 3);    >> 410
  //  getFractionAsIntDown(3.4199, 3);    >> 419
  static int getFractionAsIntDown(double d, int count) {
    return ((d - d.floor()) * pow(10, count)).floor();
  }

  static int randomInt(int max, int min){
    return (Random().nextInt(max-min) + min).toInt();
  }

  static num randomDouble(num max, num min){
    return Random().nextDouble() * (max-min) + min;
  }

  static double percentTop1(num per){
    return per / 100;
  }

  static int limit(int min, int max, int val){
    if(val >= min && val <= max){
      return val;
    }

    if(val < min){
      return min;
    }

    return max;
  }

  static double limitDouble(double min, double max, double val){
    if(val >= min && val <= max){
      return val;
    }

    if(val < min){
      return min;
    }

    return max;
  }

  static int forewardStepInRing(int current, int step, int max){
    int c = current;

    c += step;

    if(c >= max){
      c = 0;
    }

    return c;
  }

  static int moveInRing(int current, int step, int max, {bool canReturnMax = false}){
    int c = (current + step) % (max + (canReturnMax? 1 : 0));

    if (c < 0) {
      c += max + (canReturnMax? 1 : 0);
    }

    if (c >= max) {
      c = max-1;
    }

    return c;
  }

  static double betweenRange({
    required double maxReturn, required double maxRang,
    required double minReturn, required double minRang,
    required double rangeNum, bool symmetry = false
  }){
    if(symmetry){
      double temp = maxReturn;
      maxReturn = minReturn;
      minReturn = temp;
    }

    if(rangeNum >= maxRang){
      return maxReturn;
    }

    if(rangeNum <= minRang){
      return minReturn;
    }

    double difResult = maxReturn - minReturn;
    double difRange = maxRang - minRang;

    double percent = 100 * (rangeNum - minRang) / difRange;
    double wPer = difResult * percent / 100;
    double res = wPer + minReturn;

    return res;
  }

  /// relativeOf(10, 10, 1, 0.1)  $return : 1
  /// relativeOf(20, 10, 1, 0.1)  $return : 2
  /// relativeOf(620, 570, 10, 0.1)  $return : 1.5
  static double relativeOf(double num, double minNum, double numStep, double unitStep){
    if(num <= minNum){
      return 1.0;
    }

    final dif = num - minNum;
    final c = dif / numStep;

    return 1 + c * unitStep;
  }
}
