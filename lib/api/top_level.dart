import 'package:assistance_kit/api/helpers/boolHelper.dart';

T? reType<T>(dynamic input){
  if(input == null){
    return null;
  }

  if(input.runtimeType == T){
    return input as T;
  }

  if(T is String){
    // bool, int, double,
    return input.toString() as T;
  }

  if(T is int){
    if(input is num){
      return input.toInt() as T;
    }

    if(input is bool){
      return (input == true? 1 : 0) as T;
    }

    return int.tryParse(input.toString()) as T;
  }

  if(T is double){
    if(input is num){
      return input.toDouble() as T;
    }

    if(input is bool){
      return (input == true? 1.0 : 0.0) as T;
    }

    return double.tryParse(input.toString()) as T;
  }

  if(T is bool){
    return BoolHelper.itemToBool(input) as T;
  }

  return null;
}
