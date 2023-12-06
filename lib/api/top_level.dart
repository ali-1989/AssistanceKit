import 'package:assistance_kit/api/helpers/boolHelper.dart';

bool isSameType(Type t1, Type t2){
  return t1.hashCode == t2.hashCode || (t1).toString().replaceFirst('?', '') == (t2).toString();
  // T.hashCode == ((int).hashCode)
}

T? reType<T>(dynamic input){
  if(input == null){
    return null;
  }

  if(input.runtimeType == T){
    return input as T;
  }
  
  if(isSameType(T, String)){
    // bool, int, double,
    return input.toString() as T;
  }

  if(isSameType(T, int)){
    if(input is num){
      return input.toInt() as T;
    }

    if(input is bool){
      return (input == true? 1 : 0) as T;
    }
    
    return int.tryParse(input.toString()) as T;
  }

  if(isSameType(T, double)){
    if(input is num){
      return input.toDouble() as T;
    }

    if(input is bool){
      return (input == true? 1.0 : 0.0) as T;
    }

    return double.tryParse(input.toString()) as T;
  }

  if(isSameType(T, bool)){
    return BoolHelper.itemToBool(input) as T;
  }

  return null;
}
