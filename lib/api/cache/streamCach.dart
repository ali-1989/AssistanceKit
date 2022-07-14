import 'dart:async';
import 'memoryCache.dart';

typedef StreamFn = Function(String key, StreamController streamCtr);
///========================================================================================
class StreamCache {
  StreamCache._();
  static final MemoryCache _holder = MemoryCache();

  static Future<T?> get<T>(String key, StreamFn streamFn) {
    var str = _holder.getValue(key);

    if(str == null || str.isClosed){
      str = StreamController.broadcast();
      _holder.addOrReplace(key, CacheItem(value: str));
    }

    StreamSubscription? lis;
    var completer = Completer<T?>();

    lis = str.stream.listen((event) {
      if(event is T) {
        lis?.cancel();

        if(!str!.hasListener) {
          _holder.deleteCash(key + 'fn');
          str.close();
        }

        completer.complete(event);
      }
    });

    if(!_holder.existCash(key + 'fn')) {
      _holder.addKey(key + 'fn');
      streamFn(key, str);
    }

    return completer.future;
  }
}