
// (List<int>).hashCode  !=  (List<int?>).hashCode
// l1 = [1,2,3] :       l1.runtimeType.toString() =>  List<int>
// l2 = [1,2,3, null] : l2.runtimeType.toString() =>  List<int?>
import 'package:assistance_kit/models/method_result.dart';

bool isSameType(Type t1, Type t2){
  return t1.hashCode == t2.hashCode
      || (t1).toString().replaceFirst('?', '') == (t2).toString().replaceFirst('?', '');
  // T.hashCode == ((int).hashCode)
}

T? reType<T>(dynamic input){
  if(input == null){
    return null;
  }

  if(T == dynamic){
    return input;
  }

  if(input.runtimeType == T){
    return input as T;
  }

  /// string
  if(isSameType(T, String)){
    // bool, int, double,
    return input.toString() as T;
  }

  /// int
  if(isSameType(T, int)){
    if(input is num){
      return input.toInt() as T;
    }

    if(input is bool){
      return (input == true? 1 : 0) as T;
    }
    
    return int.tryParse(input.toString()) as T;
  }

  /// double
  if(isSameType(T, double)){
    if(input is num){
      return input.toDouble() as T;
    }

    if(input is bool){
      return (input == true? 1.0 : 0.0) as T;
    }

    return double.tryParse(input.toString()) as T;
  }

  /// bool
  if(isSameType(T, bool)){
    if(input is bool) {
      return input as T;
    }

    if(input is num) {
      return (input != 0) as T;
    }

    final item = input.toString().toLowerCase();
    final res = item == 'true' || item == 't' || item == 'yes' || item == 'y' || item == '1' || item == '1.0';

    return res as T;
  }

  return null;
}

List<S>? reTypeList<S>(dynamic input){
  if(input == null){
    return null;
  }

  if(input.runtimeType == List<S>){
    return input;
  }

  S mapper(e) {
    if(e is Map){
      return e as S;
    }

    if(e is List){
      return e as S;
    }

    return reType<S>(e)!;
  }

  /// List
  if(input is List){
    return input.map<S>(mapper).toList();
  }

  return null;
}

Map<K,V>? reTypeMap<K,V>(dynamic input){
  if(input == null){
    return null;
  }

  if(input.runtimeType == Map<K,V>){
    return input;
  }

  /// Map
  if(input is Map){
    return input.map<K,V>((a,b) => MapEntry<K,V>(reType<K>(a)!, reType<V>(b)!));
  }

  return null;
}

MethodResult<T> toInstance<T>(Map<String, dynamic> data, T Function(Map<String, dynamic> map) fn){
  final mResult = MethodResult<T>();

  try{
    if(data['user_id'] == null && data['requester_id'] != null){
      data['user_id'] = int.parse(data['requester_id']);
    }

    mResult.data = fn.call(data);
  }
  catch (e, stack){
    mResult.exception = e;
    mResult.stackTrace = stack;
  }

  return mResult;
}

bool areNull(List<dynamic> items) {
  for(final x in items){
    if(x == null){
      return true;
    }
  }
  
  return false;
}