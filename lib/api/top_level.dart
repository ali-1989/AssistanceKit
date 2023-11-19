T? reType<T>(dynamic value){
  if(value == null){
    return null;
  }

  if(value.runtimeType == T.runtimeType){
    return value as T;
  }

  if(T.runtimeType is int){
    if(value is num){
      return value.toInt() as T;
    }

    if(value is String){
      return int.tryParse(value) as T;
    }
  }

  if(T.runtimeType is double){
    if(value is num){
      return value.toDouble() as T;
    }

    if(value is String){
      return double.tryParse(value) as T;
    }
  }

  if(T.runtimeType is String){
    if(value is num){
      return value.toString() as T;
    }
  }

  if(T.runtimeType is bool){
    if(value is num){
      return (value != 0) as T;
    }

    if(value is String){
      final b = value.toString();

      return (b == 'true') as T;
    }
  }

  return null;
}
