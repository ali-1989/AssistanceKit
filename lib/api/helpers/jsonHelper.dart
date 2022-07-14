import 'dart:convert';


class JsonHelper {
  JsonHelper._();

  static Map<K, V>? jsonToMap<K,V>(dynamic inp) {
    if(inp == null) {
      return null;
    }

    try {
      if(inp is Map) {
        if(inp is Map<K, V>) {
          return inp;
        }
        else {
          return inp.map((key, value) => MapEntry<K, V>(key as K, value as V));
        }
      }

      final dynamic result = json.decode(inp);

      if(result is! Map) {
        return null;
      }

      // ignore: unnecessary_type_check
      if(K is dynamic && V is dynamic){
        return result as Map<K, V>;
      }

      return result.map((key, value) => MapEntry<K, V>(key as K, value as V));
    }
    catch (e) { //FormatException
      return null;
    }
  }

  static Map<String, String>? jsonToMapStrings(dynamic inp) {
    return jsonToMap<String, String>(inp);
  }

  static List<T>? jsonToList<T>(dynamic inp) {
    if(inp == null) {
      return inp;
    }

    if(inp is List) {
      if(inp is List<T>) {
        return inp;
      }
      else {
        inp.map((e) => e as T).toList();
      }
    }

    try {
      dynamic decode = inp;

      if(inp is String) {
        //same: jsonDecode(inp);
        decode = json.decode(inp);
      }

      if(decode is! List) {
        return null;
      }

      return decode.map((e) => e as T).toList();
    }
    catch (e) { //FormatException
      return null;
    }
  }

  static String mapToJson(Map<dynamic, dynamic> map) {
    return json.encode(map);
    //List<MyClass> realData = List<MyClass>.from(map<>).map((x) => MyClass.fromJson(x)));
  }

  static String? mapToJsonNullable(Map<dynamic, dynamic>? map) {
    if(map == null){
      return null;
    }

    return mapToJson(map);
  }

  static String? objToJson(dynamic obj) {
    if(obj == null){
      return null;
    }

    //if obj be null return 'null'
    return json.encode(obj);
  }

  static String listToJson(List cas) {
    return json.encode(cas);
  }

  static Map<I,J> clone<I,J>(Map<I, J> src){
    return Map.from(src);
    //return {...src};
    //return src.map((key, value) => MapEntry(key, value));

    //return []..addAll(originalList);
  }

  static Map<I,J> updateMap<I,J>(Map<I, J>? src, I/*String*/ key, J/*dynamic*/ value){
    if(src == null) {
      return {key: value};
    }

    src[key] = value; //[key as I]
    return src;
  }

  static Map<I,J> updateMapCopy<I,J>(Map<I, J>? src, I key, J value){
    if(src == null) {
      return {key: value};
    }

    final res = clone(src);

    res[key] = value;
    return res;
  }

  static R? fetchDynamicFromMap<R>(Map? src, String mapKey) {
    if(src == null) {
      return null;
    }

    final dynamic find = src[mapKey];

    if(find == null) {
      return null;
    }

    return find as R;
  }

  /// List<Map<String, dynamic>>? list = JsonHelper.fetchListFromMap(trainer.fitnessStatusJs, nodeName);
  static List<R>? fetchListFromMap<R>(Map? src, String mapKey) {
    if(src == null) {
      return null;
    }

    final dynamic con = src[mapKey];

    if(con == null || con is! List) {
      return null;
    }

    if(con is List<R>) {
      return con;
    }

    final mapTo = con.map((e) => e as R).toList();

    return mapTo;
  }

  static Map<K, V>? reFormat<K, V>(dynamic inp) {
    if(inp == null){
      return null;
    }

    if(inp is Map) {
      if(inp is Map<K, V>) {
        return inp;
      }
      else {
        inp.map((key, value) => MapEntry<K, V>(key as K, value as V));
      }
    }

    try {
      return inp.map((key, value) => MapEntry<K, V>(key as K, value as V));
    }
    catch (e) { //FormatException
      return null;
    }
  }

  static Map? removeNulls(Map? inp) {
    if(inp == null){
      return null;
    }

    try {
      inp.removeWhere((key, value) => value == null);
      return inp;
    }
    catch (e) {
      return null;
    }
  }

  static Map<K, V>? removeNullsByKey<K, V>(Map<K, V>? inp, List<K> keys) {
    if(inp == null){
      return null;
    }

    try {
      inp.removeWhere((key, value) => keys.contains(key) && value == null);
      return inp;
    }
    catch (e) {
      return null;
    }
  }

  static void mergeUnNull(Map? base, Map? newCase) {
    if(base == null || newCase == null){
      return;
    }

    for(var t in newCase.entries){
      if(t.value != null){
        base[t.key] = t.value;
      }
    }
  }

  static Map<K, V> reduceTo<K,V>(Map src, List<String> keyLimits) {
    return {
      for (var e in src.keys.where((k) {
        return keyLimits.contains(k);
      })) e as K : src[e]
    };
    //return t.cast<String, dynamic>();

    /*
      return Map<K, V>.fromIterable(src.keys.where((k) {
      return limits.contains(k);
      }),
          key: (key) => key as K,
          value: (val) => src[val]);
      //return t.cast<String, dynamic>();
    }
     */
  }

  static void removeKeys(Map src, List<String> removes) {
    for(var r in removes){
      src.removeWhere((key, value) => key == r);
    }
  }
}