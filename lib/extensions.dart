
extension TextExtension on String {
  String get L => toLowerCase();

  String get inCaps => isNotEmpty ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String get capitalizeFirstOfEach => split(RegExp(' +')).map((str) => str.inCaps).join(' ');
}
//-----------------------------------------------------------------------------------------------------
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereSafe(bool Function(E element) test) {
    try {
      return firstWhere(test);
    }
    catch (e) {
      return null;
    }
  }
}
//-----------------------------------------------------------------------------------------------------