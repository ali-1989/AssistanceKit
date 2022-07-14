
class Tools {
  Tools._();

  ///..... Youtube .....................................................................................
  static bool isYoutubeSameUrl(String? link){
    return link != null &&
        (link.contains('youtube.')
        || link.contains('youtu.be'));
  }
  ///..... Toggle btn .....................................................................................

  static List<bool> getTogglesSelected(Map<String, bool> items){
    var res = <bool>[];

    for(var i in items.entries){
      res.add(i.value);
    }

    return res;
  }

  static void setToggleState(Map<String, bool> items, String key, bool state, {bool others = false}){
    items.updateAll((key, value) => others);
    items[key] = state;
  }

  static void setToggleStateByIndex(Map<String, bool> items, int idx){
    setToggleState(items, items.keys.elementAt(idx), true, others: false);
  }

  static String? getToggleSelectedName(Map<String, bool> items, {String? defValue}){
    for(var i in items.entries){
      if(i.value) {
        return i.key;
      }
    }

    return defValue;
  }
  ///..... Math map .....................................................................................
  static dynamic findByKey(Map<String, dynamic> src, String k, {dynamic ifNotFound}){
    for(var x in src.entries){
      if(x.key == k) {
        return x.value;
      }
    }

    return ifNotFound;
  }

  static dynamic findKeyByValue(Map<dynamic, dynamic> src, dynamic val, {dynamic ifNotFound}){
    for(var x in src.entries){
      if(x.value == val) {
        return x.key;
      }
    }

    return ifNotFound;
  }

}
///******************************************************************************************************************

///******************************************************************************************************************