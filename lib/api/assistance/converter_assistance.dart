// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Project imports:
import 'package:assistance_kit/api/assistance/bool_assistance.dart';
import 'package:assistance_kit/api/assistance/math_assistance.dart';
import 'package:assistance_kit/api/assistance/text_assistance.dart';
import 'package:assistance_kit/api/valid_checker.dart';

class ConverterAssistance {
  ConverterAssistance._();

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
  
  static T? correctType<T>(dynamic input){
    if(input == null){
      return null;
    }

    if(input.runtimeType == T){
      return input as T;
    }

    if(ValidChecker.isSameType(T, String)){
      // bool, int, double,
      return input.toString() as T;
    }

    if(ValidChecker.isSameType(T, int)){
      if(input is num){
        return input.toInt() as T;
      }

      if(input is bool){
        return (input == true? 1 : 0) as T;
      }

      return int.tryParse(input.toString()) as T;
    }

    if(ValidChecker.isSameType(T, double)){
      if(input is num){
        return input.toDouble() as T;
      }

      if(input is bool){
        return (input == true? 1.0 : 0.0) as T;
      }

      return double.tryParse(input.toString()) as T;
    }

    if(ValidChecker.isSameType(T, bool)){
      return BoolAssistance.itemToBool(input) as T;
    }

    return null;
  }

  static String? removeMarks(String? input) {
    if (input == null) {
      return null;
    }

    const marks = ['\u202A', '\u202B', '\u202C', '\u202D', '\u202E',
      '\u2066', '\u2067', '\u2068', '\u2069', '\u200E', '\u200F', '\u061C'];

    for (var i = 0; i < marks.length; i++) {
      input = input!.replaceAll(marks[i], '');
    }

    return input;
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
    value = numberToEnglish(value);

    return value;
  }

  static String? numberToEnglish(String? input) {
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

  static String numberToFarsi(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (var i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    for (var i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], farsi[i]);
    }

    return input;
  }

  static String? numberToArabic(String? input) {
    if (input == null) {
      return null;
    }

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (var i = 0; i < english.length; i++) {
      input = input!.replaceAll(english[i], arabic[i]);
    }

    for (var i = 0; i < farsi.length; i++) {
      input = input!.replaceAll(farsi[i], arabic[i]);
    }

    return input;
  }

  static String removeNonDigits(String input) {
    const Map<String, String> faToEnDigits = {
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };

    String normalized = input.split('').map((char) {
      return faToEnDigits[char] ?? char;
    }).join();

    return normalized.replaceAll(RegExp(r'[^0-9.-]'), '');
  }

  static String onlyDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static double removeNonDigitsAsDouble(String input) {
    var res = removeNonDigits(input);
    res = TextAssistance.isEmptyOrNull(res) ? '0' : res;

    return MathAssistance.clearToDouble(res);
  }

  static int removeNonDigitsAsInt(String input) {
    var res = removeNonDigits(input);
    res = TextAssistance.isEmptyOrNull(res) ? '0' : res;

    return MathAssistance.clearToInt(res);
  }

  static String normalizeMobileNumber(String input) {
    String phone = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    phone = phone.replaceAll(RegExp(r'^(?:\+|00)+'), '');

    if (phone.length > 10) {
      phone = phone.substring(phone.length - 10);
    }

    return phone;
  }
}
