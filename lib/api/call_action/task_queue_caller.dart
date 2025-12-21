// Dart imports:
import 'dart:async';
import 'dart:collection';

typedef OnNext<T, S> = void Function(T obj, S? streamValue);
///=============================================================================
class TaskQueueCaller<T, S> {
  final Queue<T> _queue = Queue();
  final StreamController<S?> _controller = StreamController();
  OnNext<T,S>? _onNext;
  bool _isStart = false;

  TaskQueueCaller(){
    _init();
  }

  TaskQueueCaller.fn(OnNext onNext) : _onNext = onNext {
    _init();
  }

  void _init(){
    _controller.stream.listen((event) {
      if(_queue.isNotEmpty) {
        _onNext?.call(_queue.removeFirst(), event);
      }
      else {
        _isStart = false;
      }
    });
  }

  void _start(){
    if(_isStart){
      return;
    }

    _isStart = true;
    _onNext?.call(_queue.removeFirst(), null);
  }

  void setFn(OnNext<T,S> onNext){
    _onNext = onNext;
  }

  void addObject(T obj){
    _queue.add(obj);
    _start();
  }

  void removeObject(T obj){
    _queue.remove(obj);
  }

  void removeLast(){
    _queue.removeLast();
  }

  void callNext(S? value){
    _controller.sink.add(value);
  }

  void dispose(){
    _queue.clear();
    _controller.close();
  }
}
