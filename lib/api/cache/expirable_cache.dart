// Project imports:
import 'package:assistance_kit/api/cache/cache_scope_interface.dart';
import 'package:assistance_kit/api/cache/expirable_kv.dart';

class ExpirableCache {
  static final List<ExpirableKv> _list = [];

  ExpirableCache._();

  static bool store(ExpirableKv kv){
    if(find(kv.scope, kv.key) == null) {
      _list.add(kv);
      return true;
    }

    return false;
  }

  static bool storeWith<K, V>(CacheScopeInterface scope, K key, V value){
    final rt = ExpirableKv<K, V>(scope, key);
    rt.value = value;

    return store(rt);
  }

  static bool storeOrUpdate<K, V>(CacheScopeInterface scope, K key, V value, {Duration? updateDuration}){
    ExpirableKv? rt;

    rt = find(scope, key);

    if(rt != null){
      rt.value = value;
      return true;
    }

    rt = ExpirableKv<K, V>(scope, key);
    rt.value = value;
    rt.expireDuration = updateDuration;

    return store(rt);
  }

  static ExpirableKv? find(CacheScopeInterface scope, dynamic key){
    for(final itm in _list){
      if(itm.scope == scope && itm.key == key){
        return itm;
      }
    }

    return null;
  }

  static void remove(ExpirableKv kv){
    _list.removeWhere((element) {
      return element.scope == kv.scope && element.key == kv.key;
    });
  }

  static void removeBy(CacheScopeInterface scope, dynamic key){
    _list.removeWhere((element) {
      return element.scope == scope && element.key == key;
    });
  }

  static bool isUpdate(CacheScopeInterface scope, dynamic key, {Duration? duration, bool defaultResult = false}){
    final kv = find(scope, key);

    if(kv != null){
      if(duration != null){
        return kv.isUpdateFrom(duration);
      }

      return kv.isUpdate();
    }

    return defaultResult;
  }

  static void resetUpdateTime(CacheScopeInterface scope, dynamic key){
    final kv = find(scope, key);

    if(kv != null){
      kv.resetUpdateTime();
    }
  }
}
