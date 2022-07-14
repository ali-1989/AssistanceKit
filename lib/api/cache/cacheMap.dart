
typedef CanAdd = bool Function(dynamic key, dynamic item);
typedef CacheMapFinder<K,T> = bool Function(K key, T item);
///==============================================================================================
class CacheMap<K,T> {
  int count;
  late List<K> _internalKList;
  late List<T> _internalVList;
  CanAdd? _canAdd;

  CacheMap(this.count){
    _internalKList = List<K>.empty(growable: true);
    _internalVList = List<T>.empty(growable: true);
  }

  void setCheckBeforeAdd(CanAdd canAdd){
    _canAdd = canAdd;
  }

  void add(K key, T item){
    if(key == null || _internalKList.contains(key)) {
      return;
    }

    if(_canAdd != null){
      if(!_canAdd!(key, item)) {
        return;
      }
    }

    if(_internalKList.length >= count) {
      _internalKList.removeAt(0);
      _internalVList.removeAt(0);
    }

    _internalKList.add(key);
    _internalVList.add(item);
  }

  bool removeByKey(K key){
   var idx = _internalKList.indexOf(key);

   if(idx > -1) {
     _internalKList.removeAt(idx);
     _internalVList.removeAt(idx);
     return true;
   }

   return false;
  }

  bool removeByValue(T item){
    var idx = _internalVList.indexOf(item);

    if(idx > -1) {
      _internalVList.removeAt(idx);
      _internalKList.removeAt(idx);
      return true;
    }

    return false;
  }

  bool existKey(K key){
    return _internalKList.contains(key);
  }

  bool existItem(T item){
    return _internalVList.contains(item);
  }

  int getSize(){
    return count;
  }

  int getCount(){
    return _internalKList.length;
  }

  void clear(){
    _internalKList.clear();
    _internalVList.clear();
  }

  T? find(CacheMapFinder<K,T> fm){
    for(var i = 0; i < _internalVList.length; i++){
      var mT =  _internalVList[i];

      if(fm.call(_internalKList[i], mT)) {
        return mT;
      }
    }

    return null;
  }

  Map<K,T> finds(CacheMapFinder<K,T> fm){
    var res = <K,T>{};

    for(var i = 0; i < _internalVList.length; i++){
      var mK = _internalKList[i];
      var mT =  _internalVList[i];

      if(fm.call(mK, mT)) {
        res[mK] = mT;
      }
    }

    return res;
  }
}
///=================================================================================================
