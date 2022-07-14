import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';

class Generator {
  static final _random = Random();

  Generator._();

  static String generateMd5(String input) {
    return crypto.md5.convert(utf8.encode(input)).toString();
  }

  static int hash(String p1, List<String> p) {
    return 0;//'to-do'
  }

  static String hashMd5(String data) {
    final content = Utf8Encoder().convert(data);
    final md5 = crypto.md5;
    final digest = md5.convert(content);

    return hex.encode(digest.bytes);
  }

  static String generateKey(int len){
    final s = 'abcdefghijklmnopqrstwxyz0123456789ABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    return res;
  }

  static String generateName(int len){
    final s = 'abcdefghijklmnopqrstwxyzABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    return res;
  }

  static int generateIntId(int len){
    final s = '0123456789';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    while(res.startsWith('0')){
      res = res.substring(1) + s[_random.nextInt(s.length)];
    }

    return int.parse(res);
  }

  static String generateDateIsoId(int len){
    var res = '';
    res += DateTime.now().toUtc().toIso8601String();

    return res + generateKey(len);
  }

  static String generateDateMillWithKey(int len){
    return '${DateTime.now().toUtc().millisecondsSinceEpoch}${generateKey(len)}';
  }

  static int generateDateMillWith6Digit(){
    return int.parse('${DateTime.now().toUtc().millisecondsSinceEpoch}${generateIntId(6)}');
  }

  static int getRandomInt(int min, int max){
    return _random.nextInt(max-min) + min;
  }

  static double getRandomDouble(double min, double max){
    return _random.nextDouble() * (max-min) + min;
  }

  static E getRandomFrom<E>(List<E> list){
    final len = list.length;
    final idx = _random.nextInt(len);

    return list[idx];
  }
}
///==========================================================================================================
class KeyGenerator {
  int? _code;
  late int _len;
  late Random _r;

  KeyGenerator({length = 5}){
    _r = Random();

    if(length > 16) {
      length = 16;
    } else if(length < 1) {
      length = 1;
    }

    _len = length;

    _code = _generate();
  }

  int _generate(){
    var i = 0;
    var res = 0;

    while(i < _len){
      i++;
      res = _r.nextInt(9) + 1;
      res *= 10;
    }

    res = res ~/ 10;
    return res;
  }

  int getCurrent(){
    //if(_code == null)
      //_code = _generate();

    return _code!;
  }

  int rebuild(){
    var temp = _generate();

    while(temp == _code){
      temp = _generate();
    }

    _code = temp;
    return _code!;
  }
}
///==========================================================================================================