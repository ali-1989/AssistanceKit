//library deeply;

class Deeply {
  ///   data = updateDeeply(["name", "first"], data, (name) => name += " Second")
  static dynamic upsertDeeply(List keysChain, dynamic src, Function(dynamic cur) updater, [dynamic notSetValue, int i = 0]) {
    if (i == keysChain.length) {
      return updater(src ?? notSetValue);
    }

    if (src is! Map) {
      src = {};
    }

    src = Map<String, dynamic>.from(src);

    src[keysChain[i]] = upsertDeeply(keysChain, src[keysChain[i]], updater, notSetValue, ++i);

    return src;
  }

  static dynamic insertDeeplyToSrc(List keysChain, dynamic src, dynamic data, [int i = 0]) {
    if (src is! Map || keysChain.length <= i) {
      return src;
    }

    if (!src.containsKey(keysChain[i])) {
      if (keysChain.length == i + 1) {
        src[keysChain[i]] = data;
      }

      return src;
    }

    src[keysChain[i]] = insertDeeplyToSrc(keysChain, src[keysChain[i]], data, ++i);

    return src;
  }

  static dynamic removeDeeplyFromSrc(List keysChain, dynamic src, [int i = 0]) {
    if (src is! Map) {
      return src;
    }

    if (!src.containsKey(keysChain[i])) {
      return src;
    }

    if (keysChain.length == i + 1) {
      src.remove(keysChain[i]);
      return src;
    }

    src[keysChain[i]] = removeDeeplyFromSrc(keysChain, src[keysChain[i]], ++i);

    return src;
  }

  ///  data = renameDeeply(["name"], "Name", data);
  ///  data = renameDeeply(["birthday", "month"], "monat", data);
  static dynamic renameDeeply(List keysChain, dynamic src, String newKey, [int i = 0]) {
    if (src is! Map) {
      return src;
    }

    if (!src.containsKey(keysChain[i])) {
      return src;
    }

    if (keysChain.length == i + 1) {
      src[newKey] = src[keysChain[i]];
      src.remove(keysChain[i]);
      return src;
    }

    src[keysChain[i]] = renameDeeply(keysChain, src[keysChain[i]], newKey, ++i);

    return src;
  }

  static void insertToList(List keysChain, Map src, dynamic newValue) {
    var i = 0;
    var childMap = src;

    while (i < keysChain.length - 1) {
      dynamic x = childMap[keysChain[i]];

      if (x is! Map) {
        return;
      }

      childMap = x;
      i++;
    }

    dynamic x = childMap[keysChain[i]];

    if (x is! List) {
      return;
    }

    var list = x;

    list.add(newValue);
  }

  static Map<String, dynamic> getMapFromList(List keysChain, Map src, String mapKey, String whereValue) {
    var i = 0;
    var childMap = src;

    while(i < keysChain.length-1){
      dynamic x = childMap[keysChain[i]];

      if(x is! Map) {
        return {};
      }

      childMap = x;
      i++;
    }

    dynamic x = childMap[keysChain[i]];

    if(x is! List) {
      return {};
    }

    var list = x;

    for(var itm in list){
      Map<String, dynamic> m = itm;

      if(m[mapKey] == whereValue) {
        return m;
      }
    }

    return {};
  }

  static void insertToListMap(List keysChain, Map src, String findKey, dynamic findVal, Map newValue) {
    var i = 0;
    var childMap = src;

    while(i < keysChain.length-1){
      dynamic x = childMap[keysChain[i]];

      if(x is! Map) {
        return;
      }

      childMap = x;
      i++;
    }

    dynamic x = childMap[keysChain[i]];

    if(x is! List) {
      return;
    }

    var list = x;

    for(var i=0; i<list.length; i++){
      dynamic elm = list.elementAt(i);

      if (elm is Map) {
        var item = elm;

        if (item[findKey] == findVal) {
          item.addAll(newValue);
          break;
        }
      }
    }
  }

  static void updateList(List keysChain, Map src, String? findKey, dynamic findVal, dynamic newValue) {
    var i = 0;
    var childMap = src;

    while(i < keysChain.length-1){
      dynamic x = childMap[keysChain[i]];

      if(x is! Map) {
        return;
      }

      childMap = x;
      i++;
    }

    dynamic x = childMap[keysChain[i]];

    if(x is! List) {
      return;
    }

    var list = x;
    var findIndex = -1;

    for(var i=0; i<list.length; i++){
      dynamic elm = list.elementAt(i);

      if (elm is Map) {
        var item = elm as Map<String, dynamic>;

        if (item[findKey] == findVal) {
          item[findKey!] = newValue;
          break;
        }
      }
      else {
        if (elm == findVal) {
          findIndex = i;
          break;
        }
      }
    }

    if (findIndex >= 0) {
      list.removeAt(findIndex);
      list.add(newValue);
    }
  }

  static void removeFromList(List keysChain, Map src, String findKey, dynamic findVal) {
    var i = 0;
    var childMap = src;

    while (i < keysChain.length-1) {
      dynamic x = childMap[keysChain[i]];

      if (x is! Map) {
        return;
      }

      childMap = x;
      i++;
    }

    dynamic x = childMap[keysChain[i]];

    if (x is! List) {
      return;
    }

    var list = x;
    var findIndex = -1;

    for (var i = 0; i < list.length; i++) {
      dynamic elm = list.elementAt(i);

      if (elm is Map) {
        var item = elm as Map<String, dynamic>;

        if (item[findKey] == findVal) {
          findIndex = i;
          break;
        }
      }
      else {
        if (elm == findVal) {
          findIndex = i;
          break;
        }
      }
    }

    if (findIndex >= 0) {
      list.removeAt(findIndex);
    }
  }
}


/*
  help:

  Map<String, dynamic> map = {
      'name':{ 'first': 'ali', 'last': 'bagheri'},
      'age': 25,
    };

    -------------------------------------------------------
    map = Deeply.upsertDeeply(['name', 'middle'], map, (cur)=> 'yazdabady');//insert 'middle' to name
    map = Deeply.upsertDeeply(['name'], map, (cur)=> 'changedTo');//update
    map = Deeply.upsertDeeply(['height'], map, (cur)=> 173);//insert 'height' to root
    map = Deeply.upsertDeeply(['height', 'height to map'], map, (cur)=> 175);//convert 'height' to Map

    prin(map);   {name: changedTo, age: 25, height: {height to map: 175}}
    -------------------------------------------------------------
    Deeply.insertDeeplyToSrc(['name', 'middle'], map, 'yazdabady');
    Deeply.insertDeeplyToSrc(['name'], map, 'yazd2');//not insert: 'name' is exist
    Deeply.insertDeeplyToSrc(['height',], map, 173);
    Deeply.insertDeeplyToSrc(['height', 'fake'], map, 175);//not insert: 'height' is not Map

    prin(map);   {name: {first: ali, last: bagheri, middle: yazdabady}, age: 25, height: 173}
    -------------------------------------------------------------
    Deeply.removeDeeplyFromSrc(['name', 'middle'], map);//nothings
    Deeply.removeDeeplyFromSrc(['name'], map);//remove name
    Deeply.removeDeeplyFromSrc(['height'], map);//nothings
    Deeply.removeDeeplyFromSrc(['age'], map);//remove age
    Deeply.removeDeeplyFromSrc(['height', 'heightSub'],map);//nothings

    prin(map);     {}
    -------------------------------------------------------------
    map = Deeply.renameDeeply(['name', 'middle'], map, 'middle2');//nothings
    map = Deeply.renameDeeply(['name'], map, 'name2');//rename
    map = Deeply.renameDeeply(['name2', 'last'], map, 'last2');//rename
    map = Deeply.renameDeeply(['height'], map, 'weight');//nothings
    map = Deeply.renameDeeply(['height', 'heightSub'],map, 'old');//nothings

    prin(map);  {age: 25, name2: {first: ali, last2: bagheri}}
 */


/*
  Map<String, dynamic> map = {
      'name':{ 'first': 'ali', 'm1': [{'k1': 'v1', 'k2': 'v2'}, {'k1': 'v3', 'k2': 'v2'}]},
      'family':{ 'first': 'ali', 'm2': ['a', 'b', 'c', 'd']},
      'mid': ['a', 'b', 'c', 'd'],
      'age': 25,
    };

    Deeply.insertToList(['name', 'm1'], map, {'k1': 'v5'});
    Deeply.insertToList(['name', 'm2'], map, {'k1': 'v5'}); //nothing
    Deeply.insertToList(['family', 'm2'], map, 'f');
    Deeply.insertToList(['mid'], map, 'f');
    Deeply.insertToList(['mid', 'pid'], map, 'f'); //nothing
    -----------------------------------------------------------------
    Deeply.updateList(['name', 'm1'], map, 'k1', 'v3', 'updated');
    Deeply.updateList(['family', 'm2'], map, '', 'a', 'updated');
    Deeply.updateList(['mid'], map, null, 'b', 'updated');

    {name: {first: ali, m1: [{k1: v1, k2: v2}, {k1: updated, k2: v2}]},
      family: {first: ali, m2: [b, c, d, updated]}, mid: [a, c, d, updated], age: 25}
    -----------------------------------------------------------------
    Deeply.removeFromList(['name', 'm1'], map, 'k1', 'v3');
    Deeply.removeFromList(['family', 'm2'], map, '', 'a');
    Deeply.removeFromList(['mid'], map, '', 'b');

    */