
class MemoryCache {
  final Map<String, CacheItem> _itemList = {};

  MemoryCache();

  void clearCashes(){
    _itemList.clear();
  }

  void deleteCash(String key){
    _itemList.remove(key);
  }

  bool add(String key, CacheItem ci){
    if(existCash(key)) {
      return false;
    }

    _itemList.putIfAbsent(key, () => ci);
    return true;
  }

  void addOrReplace(String key, CacheItem ci){
    _itemList[key] = ci;
  }

  void addOrReplaceBy(String key, dynamic val){
    _itemList[key] = CacheItem(value: val);
  }

  bool addKey(String key){
    if(existCash(key)) {
      return false;
    }

    var ci = CacheItem(value: 'none');
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

  T? getValue<T>(String key){
    return _itemList[key]?._value;
  }

  dynamic getValueOrDefault(String key, dynamic def){
    var t = _itemList[key];
    return (t != null)? t._value : def;
  }
}
///====================================================================================
class CacheItem {
  String? tag;
  late DateTime _lastUpdated;
  dynamic _value;

  CacheItem({required dynamic value, this.tag}){
    _lastUpdated = DateTime.now();
    _value = value;
  }

  void update(dynamic value){
    _value = value;
    _lastUpdated = DateTime.now();
  }

  dynamic get value => _value;
  DateTime get lastUpdated => _lastUpdated;
}