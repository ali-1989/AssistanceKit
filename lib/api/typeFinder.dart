class TypeFinder<T> {
  const TypeFinder();

  bool check(dynamic object) => object is T;
}