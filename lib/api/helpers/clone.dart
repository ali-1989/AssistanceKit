import 'dart:convert';

abstract class DeepCopyable{
  T deepCopy<T>();
}

class Clone {

  static List<T> listDeepCopy<T>(List list){
    var newList = <T>[];

    list.forEach((value) {
      newList.add(
          value is Map ? mapDeepCopy(value) :
          value is List ? listDeepCopy(value) :
          value is Set ? setDeepCopy(value) :
          value is DeepCopyable ? value.deepCopy() :
          value
      );
    });

    return newList;
  }

  static Set<T> setDeepCopy<T>(Set s){
    var newSet = <T>{};

    s.forEach((value) {
      newSet.add(
          value is Map ? mapDeepCopy(value) :
          value is List ? listDeepCopy(value) :
          value is Set ? setDeepCopy(value) :
          value is DeepCopyable ? value.deepCopy() :
          value
      );
    });

    return newSet;
  }


  static Map<K, dynamic> mapDeepCopy<K,V>(Map<K,dynamic> map){
    var newMap = <K,dynamic>{};

    map.forEach((key, value){
      newMap[key] = value is Map ? mapDeepCopy(value) :
      value is List ? listDeepCopy(value) :
      value is Set ? setDeepCopy(value)  :
      value is DeepCopyable ? value.deepCopy() :
      value;
    });

    return newMap;
  }

  static Map<K,V> mapDeepCopyExplicit<K,V>(Map<K,V> map){
    var newMap = <K,V>{};

    map.forEach((key, value){
      newMap[key] = value is Map ? (mapDeepCopy(value) as V) :
      value is List ? (listDeepCopy(value) as V):
      value is Set ? (setDeepCopy(value) as V) :
      value is DeepCopyable ? value.deepCopy() :
      value;
    });

    return newMap;
  }

  // no multi dimensional (shallow copy)
  static List cloneD1List(List inp){
    return [...inp]; //= [].addAll(inp)
  }

  static Set cloneD1Set(Set inp){
    return {...inp};
  }

  static Map cloneD1Map(Map inp){
    return {...inp}; // map.map((key, value) => MapEntry(key, value))
  }

  static Map cloneMapSlow(Map inp){
    return json.decode(json.encode(inp));
  }
}