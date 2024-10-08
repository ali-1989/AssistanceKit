
class BoolHelper{
  BoolHelper._();

  static bool isTrue(dynamic v, {dynamic onNull = false}) {
    return itemToBool(v, onNull: onNull) == true;
  }

  static bool isFalse(dynamic v, {dynamic onNull = false}) {
    return itemToBool(v, onNull: onNull) != true;
  }

  static bool itemToBool(dynamic item, {dynamic onNull = false}) {
    if (item == null) {
      return onNull;
    }

    if(item is bool) {
      return item;
    }

    if(item is num) {
      return item != 0;
    }

    item = item.toString().toLowerCase();
    return item == 'true' || item == 't' || item == 'yes' || item == 'y' || item == '1' || item == '1.0';
  }

  static String? boolToString(bool? val) {
    if (val == null) {
      return null;
    }

    if (val) {
      return 'true';
    }

    return 'false';
  }
}