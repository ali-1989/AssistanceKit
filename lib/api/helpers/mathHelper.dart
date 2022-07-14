import 'dart:math' ;

import 'package:assistance_kit/api/helpers/LocaleHelper.dart';

// BigInt.from(5);

class MathHelper {
	MathHelper._();

	static int clearToInt(dynamic inp, {int def = 0}){
		if(inp == null){
			return def;
		}

		var v = inp.toString().trim();

		v = LocaleHelper.numberToEnglish(v)!;
		v = LocaleHelper.removeMarks(v)!;

		v = v.replaceFirst(RegExp(r'$0+(?=(-|\+|[1-9]))'), '');
		v = v.replaceAll(RegExp('[^0-9-]'), '');

		if(v == '-') {
			v = '-0';
		}

		return int.tryParse(v)?? def;
	}

	static double clearToDouble(dynamic inp, {double def = 0.0}){
		if(inp == null){
			return def;
		}

		var v = inp.toString().trim();

		v = LocaleHelper.numberToEnglish(v)!;
		v = LocaleHelper.removeMarks(v)!;

		v = v.replaceFirst(RegExp(r'$0+(?=(-|\+|[1-9]))'), '');
		v = v.replaceAll(RegExp('[^-.0-9]'), '');

		if(v == '-') {
			v = '-0';
		}

		return double.tryParse(v)?? def;
	}

	static int toInt(String inp, {int def = 0}){
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

	static double minDouble(double a, double b){
		return min(a, b);
	}

	static double maxDouble(double a, double b){
		return max(a, b);
	}

	static double percent(double whole, int per){
		return per * 100 / whole;
	}

	static double percentFix(double whole, int per){
		final res = per * 100 / whole;
		return fixPrecisionRound(res, 1);
	}

	static int percentInt(int whole, int per){
		return per * 100 ~/ whole;
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

	static int backwardStepInRing(int current, int step, int allCount, bool baseIsOne ){
		int def, r;

		if(baseIsOne)
		{
			if(current < 1) {
			  current = 1;
			}

			def = current - step.abs();
			r = def + allCount;
			var x = r % allCount;

			if(x == 0) {
			  x = allCount;
			}

			return x;
		}
		else
		{
			if(current > allCount) {
			  current = allCount;
			}

			def = current - step.abs();
			r = def + allCount;
			return r % allCount;
		}
	}
}