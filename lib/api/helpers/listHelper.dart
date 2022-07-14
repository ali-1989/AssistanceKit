
class ListHelper {
  ListHelper._();

  static List<String>? stringToStringList(String? text, {String splitter = ','}){
    if(text == null) {
      return null;
    }

    text = text.replaceAll(' ', '');
    text = text.replaceFirst('{', '');
    text = text.replaceFirst('}', '');
    text = text.replaceFirst('[', '');
    text = text.replaceFirst(']', '');

    if(text.trim().isEmpty) {
      return [];
    }

    return text.split(splitter);
  }

  static List<num>? stringToNumList(String? text, {String splitter = ','}){
    var res = stringToStringList(text, splitter: splitter);

    if(res == null) {
      return null;
    }

    var it = res.map((s) => num.parse(s));
    return it.toList();
  }

  static List<int>? stringToIntList(String? text, {String splitter = ','}){
    var res = stringToStringList(text, splitter: splitter);

    if(res == null) {
      return null;
    }

    var it = res.map((s) => int.parse(s));
    return it.toList();
  }

  /// [1,2,3]   =>  "{1,2,3}"
  static String? listToArrayAsString(List<dynamic>? list, {String splitter = ','}){
    if(list == null) {
      return null;
    }

    if(list.isEmpty) {
      return '{}';
    }

    var res = '{';

    for (var el in list) {
      res += '$el$splitter';
    }

    res = res.substring(0, res.length-1);
    res += '}';
    return res;
  }

  /// ['a', 'b', 'c']   => "{"a", "b", "c"}"
  static String? listStringToArrayAsString(List<String>? list, {String splitter = ','}){
    if(list == null) {
      return null;
    }

    if(list.isEmpty) {
      return '{}';
    }

    var res = '{';

    for (var el in list) {
      res += '"$el"$splitter';
    }

    res = res.substring(0, res.length-1);
    res += '}';
    return res;
  }

  // [1,2,3]  =>   '1,2,3'
  static String listToSequence(Iterable input) {
    if(input.isEmpty){
      return '';
    }

    var res = '';

    for(var i in input){
      if(i is String){
        res += '"$i", ';
      }
      else {
        res += '$i, ';
      }
    }

    res = res.substring(0, res.length-2);

    return res;
  }

  static bool isMatch(List? a, List? b){
    if(a == null || b == null) {
      return false;
    }

    if(a.length != b.length) {
      return false;
    }

    for(var aCase in a){
      if(!b.contains(aCase)) {
        return false;
      }
    }

    return true;
  }

  static List<T>? removesAsNew<T>(List<T>? base, List<T>? remove){
    if(base == null) {
      return null;
    }

    if(remove == null) {
      return base;
    }

    var res = <T>[];

    for(var aCase in base){
      if(!remove.contains(aCase)) {
        res.add(aCase);
      }
    }

    return res;
  }

  static List<T> slice<T>(List<T>? src, int start, int count){
    if(src == null || start+count > src.length) {
      return [];
    }

    var res = <T>[];

    for(var i= start; i < start+count; i++){
      res.add(src[i]);
    }

    return res;
  }

  static int indexOf<T>(List<T>? src, List<T>? search, {int start = 0}){
    if(src == null || search == null || search.length+start > src.length) {
      return -1;
    }

    var find = false;

    for(var i= start; i < src.length; i++){
      if(src.length - i < search.length) {
        break;
      }

      if(src[i] != search[0]) {
        continue;
      }

      find = true;

      for(var j=0; j< search.length; j++){
          if(src[i+j] != search[j]) {
            find = false;
            break;
          }
      }

      if(find) {
        return i;
      }
    }

    return -1;
  }

  static void sortList<T>(List<T> src, int Function(T t1, T t2) sorter){
    src.sort(sorter);
  }
}