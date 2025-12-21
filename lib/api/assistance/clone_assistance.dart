// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';

abstract class DeepCopyable{
  T deepCopy<T>();
}

class CloneAssistance {
  CloneAssistance._();

  static bool deepEquals(Map s1, Map s2){
    return DeepCollectionEquality.unordered().equals(s1, s2);
  }

  static Map<I,J> cloneShallow<I,J>(Map<I, J> src){
    return Map.from(src);
    //return {...src};
    //return src.map((key, value) => MapEntry(key, value));

    //return []..addAll(originalList);
  }

  static dynamic clone<T>(dynamic obj){
    if(obj is List){
      return listDeepCopy(obj).map((e) => e as T).toList();
    }

    if(obj is Set){
      return setDeepCopy(obj) as T;
    }

    if(obj is Map){
      return mapDeepCopy(obj) as T;
    }

    return null;
  }

  static List<T> listDeepCopy<T>(List list){
    final newList = <T>[];

    for (final itm in list) {
      newList.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) : itm
      );
    }

    return newList;
  }

  static Set<T> setDeepCopy<T>(Set orgSet){
    final newSet = <T>{};

    for (final itm in orgSet) {
      newSet.add(
          itm is Map ? mapDeepCopy(itm) :
          itm is List ? listDeepCopy(itm) :
          itm is Set ? setDeepCopy(itm) :
          itm
      );
    }

    return newSet;
  }

  static Map<K,V> mapDeepCopy<K,V>(Map map){
    final newMap = <K,V>{};

    map.forEach((key, value){
      newMap[key] = (
      value is Map ? mapDeepCopy(value) :
      value is List ? listDeepCopy(value) :
      value is Set ? setDeepCopy(value) :
      value
      ) /*as V*/;
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
