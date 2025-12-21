// Dart imports:
import 'dart:async';

// Project imports:
import 'couple.dart';

class TimeoutCache {
  final List<Couple<String, dynamic>> _couples = [];

  TimeoutCache();

  void clearAll(){
    _couples.clear();
  }

  void deleteTimeout(String key){
    _couples.removeWhere((element) => element.key == key);
  }

  bool add(String key, Duration dur, {dynamic value}){
    for(final x in _couples){
      if(x.key == key) {
        return false;
      }
    }

    _couples.add(Couple.kv(key, value));

    Timer(dur, (){
      _couples.removeWhere((element) => element.key == key);
    });

    return true;
  }

  bool exist(String key){
    for(final x in _couples){
      if(x.key == key) {
        return true;
      }
    }

    return false;
  }

  dynamic getValue(String key){
    for(final x in _couples){
      if(x.key == key) {
        return x.value;
      }
    }

    return null;
  }

  bool changeValue(String key, newValue){
    for(final x in _couples){
      if(x.key == key) {
        x.value = newValue;
        return true;
      }
    }

    return false;
  }
}

