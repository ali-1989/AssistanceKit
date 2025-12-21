
class MemoryCache<T> {
  final Map<String, CacheItem<T?>> _itemList = {};

  MemoryCache();

  void clearCashes(){
    _itemList.clear();
  }

  void deleteCash(String key){
    _itemList.remove(key);
  }

  bool add(String key, CacheItem<T?> ci){
    if(existCash(key)) {
      return false;
    }

    _itemList.putIfAbsent(key, () => ci);
    return true;
  }

  void addOrReplace(String key, CacheItem<T?> ci){
    _itemList[key] = ci;
  }

  void addOrReplaceBy(String key, T? val){
    _itemList[key] = CacheItem(value: val);
  }

  bool addKey(String key){
    if(existCash(key)) {
      return false;
    }

    final ci = CacheItem<T?>(value: null);
    _itemList[key] = ci;

    return true;
  }

  DateTime? getLastUpdate(String key){
    return _itemList[key]?.lastUpdated;
  }

  bool existCash(String key){
    return _itemList[key] != null;
  }

  bool update(String key, dynamic newValue){
    var t = _itemList[key];

    if(t == null) {
      return false;
    }

    t.update(newValue);
    return true;
  }

  CacheItem? get(String key){
    return _itemList[key];
  }

  T? getValue(String key){
    return _itemList[key]?._value;
  }

  T? getValueOrDefault(String key, T? def){
    var t = _itemList[key];
    return (t != null)? t._value : def;
  }
}
///====================================================================================
class CacheItem<T> {
  String? tag;
  late DateTime _lastUpdated;
  T? _value;

  T? get value => _value;
  DateTime get lastUpdated => _lastUpdated;

  CacheItem({this.tag, required T value}){
    _lastUpdated = DateTime.now();
    _value = value;
  }

  void update(T value){
    _value = value;
    _lastUpdated = DateTime.now();
  }
}