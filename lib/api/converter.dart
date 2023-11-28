import 'dart:convert';
import 'dart:typed_data';
import 'package:assistance_kit/api/helpers/boolHelper.dart';


class Converter {
  Converter._();

  static var sqlEscape = RegExp(r'(\n|\r\n|\r)', unicode: true, multiLine: true,);
  // + space and tab
  static var sqlEscapeWt = RegExp(r'(\n|\r\n|\r)(\s*|\t*)', unicode: true, multiLine: true, dotAll: false);

  static String? multiLineToSql(String str) {
    try {
      return str.replaceAll(sqlEscape, r'\n');
    }
    catch (e) { //FormatException
      return null;
    }
  }

  /// use
  static String? multiLineToSqlWt(String? str) {
    try {
      return str?.replaceAll(sqlEscapeWt, r'\n');
    }
    catch (e) { //FormatException
      return null;
    }
  }

  static List<int> stringToBytes(String data) {
    return data.codeUnits;
  }

  static String bytesToStringUtf8(List<int> data) {
    return utf8.decode(data);
  }

  static String bytesToString(List<int> data) {
    return String.fromCharCodes(data);
  }

  static int bytesToInt(List<int> data, {Endian endian = Endian.big}) {
    return Int8List.fromList(data).buffer.asByteData().getInt32(0, endian);
  }

  static int bytesToLong(List<int> data, {Endian endian = Endian.big}) {
    return Int8List.fromList(data).buffer.asByteData().getInt64(0, endian);
  }

  static double bytesToFloat(List<int> data, {Endian endian = Endian.big}) {
    return Int8List.fromList(data).buffer.asByteData().getFloat32(0, endian);
  }

  static int? dynamicToIntNull(dynamic val) {
    if (val == null) {
      return null;
    }

    if (val is String) {
      return int.parse(val);
    }

    return val;
  }

  static int dynamicToIntUnNull(dynamic val, int def) {
    if (val == null) {
      return def;
    }

    if (val is String) {
      try {
        return int.parse(val);
      }
      catch (E){
        return def;
      }
    }

    return val;
  }

  static dynamic unNull(dynamic val, dynamic def) {
    if (val == null) {
      return def;
    }

    return val;
  }

  static String unNullString(dynamic val, String def) {
    if (val == null || val.toString().toLowerCase() == 'null') {
      return def;
    }

    return val.toString();
  }

  ///---------------------------------------------------------------------------
  static String? millsToTime(dynamic input, {withSec = true, withMill = false}) {
    if (input == null) {
      return null;
    }

    String twoDigit(num n) {
      if (n > 9) {
        return '$n';
      }

      return '0$n';
    }

    String threeDigit(num n) {
      if (n > 99) {
        return '$n';
      } else if (n > 9) {
        return '0$n';
      } else {
        return '00$n';
      }
    }

    var text = input.toString();
    var number = num.parse(text);

    if (number < 1000) {
      return '$number mill';
    }

    num s = number ~/ 1000;

    if (s <= 120) {
      return '$s sec';
    }

    /*num m = number ~/ (60 * 1000);

		if(m < 60) {
			s = (number - (m * 60 * 1000)) ~/ 1000;
			num mill = number - (m * 60 * 1000);

			if(s < 1 && mill < 1)
				return '$m min';
			else if(s < 1 && mill > 0)
				return '${twoDigit(m)}:00.${threeDigit(mill)} mill';
			else if(s > 0 && mill < 1)
				return '${twoDigit(m)}:${twoDigit(s)} sec';
			else
				return '${twoDigit(m)}:${twoDigit(s)}:${threeDigit(mill)} mill';
		}*/

    num h = number ~/ (60 * 60 * 1000);
    num m = (number - (h * 60 * 60 * 1000)) ~/ (60 * 1000);
    s = (number - (h * 60 * 60 * 1000) - (m * 60 * 1000)) ~/ 1000;
    var mill = number - (h * 60 * 60 * 1000) - (m * 60 * 1000) - (s * 1000);

    var hh = '$h';
    var mm = m > 0 ? ':${twoDigit(m)}' : ':00';
    var ss = s > 0 ? ':${twoDigit(s)}' : ':00';
    var mil = mill > 0 ? '.${threeDigit(mill)}' : '';

    if (withMill) {
      return '$hh$mm$ss$mil';
    } else if (withSec) {
      return '$hh$mm$ss';
    } else {
      return '$hh$mm';
    }
  }

  static bool isSameType(Type t1, Type t2){
    return t1.hashCode == t2.hashCode;
    // T.hashCode == ((int).hashCode)
  }

  static T? correctType<T>(dynamic input){
    if(input == null){
      return null;
    }

    if(input.runtimeType == T){
      return input as T;
    }

    if(isSameType(T, String)){
      // bool, int, double,
      return input.toString() as T;
    }

    if(isSameType(T, int)){
      if(input is num){
        return input.toInt() as T;
      }

      if(input is bool){
        return (input == true? 1 : 0) as T;
      }

      return int.tryParse(input.toString()) as T;
    }

    if(isSameType(T, double)){
      if(input is num){
        return input.toDouble() as T;
      }

      if(input is bool){
        return (input == true? 1.0 : 0.0) as T;
      }

      return double.tryParse(input.toString()) as T;
    }

    if(isSameType(T, bool)){
      return BoolHelper.itemToBool(input) as T;
    }

    return null;
  }

  // List<int>? allIdsMap = Converter.correctList<int>(js['all_ticket_ids']);
  static List<T>? correctList<T>(dynamic inp) { //, T sample
    if(inp is List<T> || inp == null){
      return inp;
    }

    final list = inp as List;
    return list.map((e) => e as T).toList();
  }

  static String? resolveMobile(String? value) {
    if(value == null) {
      return null;
    }

    value = value.replaceAll('-', '');
    value = value.replaceAll(' ', '');
    value = _numberToEnglish(value);

    return value;
  }

  static String? _numberToEnglish(String? input) {
    if (input == null) {
      return null;
    }

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (var i = 0; i < farsi.length; i++) {
      input = input!.replaceAll(farsi[i], english[i]);
    }

    for (var i = 0; i < arabic.length; i++) {
      input = input!.replaceAll(arabic[i], english[i]);
    }

    return input;
  }
}