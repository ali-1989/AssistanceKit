// Project imports:
import 'package:assistance_kit/api/cache/cache_scope_interface.dart';

class ExpirableKv<K,V> {
  late CacheScopeInterface scope;
  late K key;
  V? _value;
  DateTime? lastUpdate;
  Duration? expireDuration;

  ExpirableKv(this.scope, this.key);

  ExpirableKv.fill(this.scope, this.key, V value, {this.lastUpdate, this.expireDuration}) : _value = value {
    lastUpdate = DateTime.now();
  }

  set value(V? value){
    _value = value;
    lastUpdate = DateTime.now();
  }

  V? get value => _value;

  bool isUpdateFrom(Duration duration){
    return lastUpdate != null && lastUpdate!.add(duration).isAfter(DateTime.now());
  }

  bool isUpdate(){
    if(expireDuration == null){
      return true;
    }

    return lastUpdate != null && lastUpdate!.add(expireDuration!).isAfter(DateTime.now());
  }

  void resetUpdateTime(){
    lastUpdate = null;
  }

  void changeUpdateTime(DateTime dt){
    lastUpdate = dt;
  }

  void longTimeKeepUpdate(){
    lastUpdate = DateTime.now().add(const Duration(days: 100));
  }
}
