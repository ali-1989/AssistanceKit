// Dart imports:
import 'dart:async';

// Project imports:
import 'memory_cache.dart';

typedef Handler<T> = FutureOr<T?> Function(String key);
///========================================================================================
class FutureCache {
  FutureCache._();

  static final MemoryCache<List<Completer>> _cacheHolder = MemoryCache();

  static Future<T?> get<T>(String key, Handler<T> handler) {
    var handlerList = _cacheHolder.getValue(key);
    final handlerKey = '${key}_fn';

    /// if not exist Handler list, create once and add it.
    if(handlerList == null){
      handlerList = <Completer>[];
      _cacheHolder.addOrReplace(key, CacheItem(value: handlerList));
    }

    final completer = Completer<T?>();
    handlerList.add(completer);

    /// if not exist handler, add this
    if(!_cacheHolder.existCash(handlerKey)) {
      _cacheHolder.addKey(handlerKey);

      final res = handler.call(key);

      if(res is Future){
        (res as Future).then((value) {
          for(final x in handlerList!){
            x.complete(value);
          }

          handlerList.clear();
          _cacheHolder.deleteCash(handlerKey);
        });
      }
      else {
        for(final x in handlerList){
          x.complete(res);
        }

        handlerList.clear();
        _cacheHolder.deleteCash(handlerKey);
      }
    }

    return completer.future;
  }
}


/*
typedef StreamSinkHandler = Function(String key, StreamController streamCtr);
///========================================================================================
class StreamCache {
  StreamCache._();

  static final MemoryCache<StreamController> _cacheHolder = MemoryCache();

  static Future<T?> get<T>(String key, StreamSinkHandler streamSinkHandler) {
    var streamCtr = _cacheHolder.getValue(key);
    final handlerKey = '${key}_fn';

    /// if not exist StreamController, create once and add it.
    if(streamCtr == null || streamCtr.isClosed){
      streamCtr = StreamController.broadcast();
      _cacheHolder.addOrReplace(key, CacheItem(value: streamCtr));
    }

    late StreamSubscription lis;
    final completer = Completer<T?>();

    lis = streamCtr.stream.listen((result) {
      if(result is T) {
        lis.cancel();

        if(!streamCtr!.hasListener) {
          _cacheHolder.deleteCash(key);
          _cacheHolder.deleteCash(handlerKey);
          streamCtr.close();
        }

        completer.complete(result);
      }
    });

    /// if not exist handler, add this
    if(!_cacheHolder.existCash(handlerKey)) {
      _cacheHolder.addKey(handlerKey);
      streamSinkHandler(key, streamCtr);
    }

    return completer.future;
  }
}*/
