
class CacheList<T> {
  int size;
  late List<T> _internalList;

  CacheList(this.size){
    _internalList = List<T>.empty(growable: true);
  }

  void add(T item){
    if(_internalList.contains(item)) {
      return;
    }

    if(_internalList.length >= size) {
      _internalList.removeAt(0);
    }

    _internalList.add(item);
  }

  bool remove(T item){
    return _internalList.remove(item);
  }

  bool exist(T item){
    return _internalList.contains(item);
  }

  int getSize(){
    return size;
  }

  int getCount(){
    return _internalList.length;
  }

  void clear(){
    _internalList.clear();
  }

  T? find(CacheFindMethod<T> fm){
    for(var i in _internalList){
      if(fm.find(i)) {
        return i;
      }
    }

    return null;
  }

  List<T> finds(CacheFindMethod<T> fm){
    var res = <T>[];

    for(var i in _internalList){
      if(fm.find(i)) {
        res.add(i);
      }
    }

    return res;
  }
}
///=============================================================================================================
abstract class CacheFindMethod<T> {
  bool find(T item);
  //void onFound(T result);
}