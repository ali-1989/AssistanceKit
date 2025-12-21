// Dart imports:
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

class GeneratorAssistance {
  static final _random = Random();
  static final List<String> _words = [];
  
  GeneratorAssistance._();

  static int hash(String p1, List<String> p) {
    return Object.hash(p1, p); //hashValues(p1, p);
  }

  static String generateMd5(String input) {
    return crypto.md5.convert(utf8.encode(input)).toString();
  }

  static String hashMd5(String data) {
    final content = Utf8Encoder().convert(data);
    final md5 = crypto.md5;
    final digest = md5.convert(content);

    return hex.encode(digest.bytes);
  }

  static String generateAlphabetAndNumbers(int len){
    final s = 'abcdefghijklmnopqrstwxyz0123456789ABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    return res;
  }

  static String generateNumbers(int len){
    final s = '0123456789';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    return res;
  }

  static String generateAlphabet(int len){
    final s = 'abcdefghijklmnopqrstwxyzABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = _random.nextInt(s.length);
      res += s[j];
    }

    return res;
  }

  static bool randomBool(){
    return _random.nextBool();
  }

  static int generateIdAsInt(int len){
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

    return res + generateAlphabetAndNumbers(len);
  }

  static String generateDateMillWithSalt(int len){
    return '${DateTime.now().toUtc().millisecondsSinceEpoch}${generateAlphabetAndNumbers(len)}';
  }

  static int generateDateMillWith6Digit(){
    return int.parse('${DateTime.now().toUtc().millisecondsSinceEpoch}${generateNumbers(6)}');
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

  static String generateWords(int wordCount, int minWordLen, int maxWordLean){
    if(_words.isEmpty) {
      _words.add('hi');
      _words.add('hello');
      _words.add('and');
      _words.add('a');
      _words.add('an');
      _words.add('is');
      _words.add('was');
      _words.add('has');
      _words.add('the');
      _words.add('good');
      _words.add('goodBy');
      _words.add('good morning');
      _words.add('what');
      _words.add('not');
      _words.add('same');
      _words.add('some');
      _words.add('where');
      _words.add('*****');
      _words.add('who');
      _words.add('mr');
      _words.add('miss');
      _words.add('book');
      _words.add('flower');
      _words.add('computer');
      _words.add('wallet');
      _words.add('device');
      _words.add('go');
      _words.add('come');
      _words.add('back');
      _words.add('next');
      _words.add('glass');
      _words.add('dish');
      _words.add('he');
      _words.add('she');
      _words.add('we');
    }

    List<String> res = [];

    while(res.length < wordCount){
      final w = _words[_random.nextInt(_words.length)];

      if(w.length >= minWordLen && w.length <= maxWordLean) {
        res.add(w);
      }
    }

    return res.join(' ');
  }
}
///=============================================================================
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
