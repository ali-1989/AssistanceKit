
import 'dart:math';

class Tools {
  Tools._();

  static void verboseLog(dynamic obj){
    if(obj == null){
      return;
    }

    final txt = obj.toString();

    for(int i = 0; i< txt.length; i+= 1000){
      print(txt.substring(i, min(i+1000, txt.length)));
    }
  }

  static void verboseStackTrace(){
    verboseLog(StackTrace.current);
  }

  static void logWithDelimiter(Object obj){
    print('${'*' * 40}\n ${obj.toString()} \n${'*' * 50}');
  }

  /*static Future<FilePickerResult?> openPickFiles({bool isMulti = false}){
    return FilePicker.platform.pickFiles(allowMultiple: isMulti);
  }

  static Future<String?> openSaveDirectory({String? title}){
    // not imp: return FilePicker.platform.saveFile(fileName: 'pdfff.pdf');
    return FilePicker.platform.getDirectoryPath(dialogTitle: title);
  }

  /// Android: 21+ , iOS:11+
  static Future<String?> selectDirectory(){
    return FilePicker.platform.getDirectoryPath();
  }*/
  ///..... Youtube .............................................................
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