import 'package:assistance_kit/api/assistance/text_assistance.dart';

typedef ModelBuilderMethod<T> = T Function<I>(I data);
///=============================================================================
class MethodResult<T> {
  String? userMessage;
  dynamic exception;
  StackTrace? stackTrace;
  T? data;
  List<T> dataList = [];

  T get noNullData => data!;

  void setError(dynamic err, {StackTrace? stackTrace}){
    exception = err;
    this.stackTrace = stackTrace;
  }

  bool hasError(){
    return exception != null;
  }

  bool isEmpty(){
    return data == null && dataList.isEmpty && !hasError();
  }

  String getErrorText({int size = 100}){
    return TextAssistance.subStringByCountSafe(exception.toString(), size);
  }

  M? dataToModel<M>(ModelBuilderMethod<M> builder){ //M Function(T inp) fn
    if(data == null){
      return null;
    }

    return builder.call<T>(data!);
  }

  T? transform<M>(ModelBuilderMethod<T> builder){
    if(data == null || data !is M){
      return null;
    }

    return builder.call<M>(data! as M);
  }

  List<M> map<M>(ModelBuilderMethod<M> builder){
    return dataList.map<M>((elm) => builder.call<T>(elm)).toList();
  }

}