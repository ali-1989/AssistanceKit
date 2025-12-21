// Dart imports:
import 'dart:async';

class AvoidReCall {
  static final List<_AvoidReICallItem> _list = [];
  late final String id;
  Future? _future;
  Duration? _duration;
  void Function()? _function;
  void Function()? onReleaseFunction;
  final void Function()? _additionalFunction;
  bool _isLock = false;


  set function (void Function()? function) => _function = function;

  static AvoidReCall build({
    required String id,
    void Function()? function,
    void Function()? additionalFunction,
  }){

    late AvoidReCall i;
    final find = get(id);

    if(find != null){
      i = find;
    }
    else {
      i = AvoidReCall._(id: id, additionalFunction: additionalFunction);
      final r = _AvoidReICallItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static AvoidReCall buildDuration({
    required String id,
    Duration duration = const Duration(milliseconds: 1600),
    void Function()? function,
    void Function()? additionalFunction,
  }){

    late AvoidReCall i;
    final find = get(id);

    if(find != null){
      i = find;
      i._duration = duration;
    }
    else {
      i = AvoidReCall._(id: id, duration: duration, additionalFunction: additionalFunction);
      final r = _AvoidReICallItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static AvoidReCall buildFuture({
    required String id,
    required Future future,
    void Function()? function,
    void Function()? additionalFunction,
  }){

    late AvoidReCall i;
    final find = get(id);

    if(find != null){
      i = find;
      i._future = future;
    }
    else {
      i = AvoidReCall._(future: future, id: id, additionalFunction: additionalFunction);
      final r = _AvoidReICallItem(id, i);

      _list.add(r);
    }

    i._function = function;

    return i;
  }

  static AvoidReCall? get(String id){
    for(final i in _list){
      if(i.id == id){
        return i.avoidRecall;
      }
    }

    return null;
  }

  //void Function() get function {
  void  getFunction() {
    if(_isLock){
      return;
    }

    _isLock = true;

    if(_duration != null){
      Future.delayed(_duration!, (){
        _releaseLock();
      });
    }
    else if(_future != null){
      _future!.then((value) {
        _releaseLock();
      });
    }

    _function!.call();
    _additionalFunction?.call();
  }

  void _releaseLock(){
    _isLock = false;
    onReleaseFunction?.call();
  }

  void releaseLock(){
    _isLock = false;
  }

  static void destroy(String id){
    _list.removeWhere((itm)=> itm.id == id);
  }

  void destroyThis(){
    destroy(id);
  }

  static void clearIsNotLock(){
    _list.removeWhere((element) {
      return element.avoidRecall._isLock == false;
    });
  }

  AvoidReCall._({
    required this.id,
    void Function()? function,
    void Function()? additionalFunction,
    void Function()? onReleaseFunction,
    Duration? duration,
    Future? future,
  }): _function = function,
        _additionalFunction = additionalFunction,
        _duration = duration,
        _future = future,
  onReleaseFunction = onReleaseFunction;

 /*AvoidReCall._duration(this._duration, {
   required this.id,
    void Function()? function,
    void Function()? additionalFunction,
  }): _function = function, _additionalFunction = additionalFunction;

  AvoidReCall._future(this._future, {
    required this.id,
    void Function()? function,
    void Function()? additionalFunction,
  }) : _function = function, _additionalFunction = additionalFunction;*/
}
///=============================================================================
class _AvoidReICallItem {
  String id;
  AvoidReCall avoidRecall;

  _AvoidReICallItem(this.id, this.avoidRecall);
}
