
class LocaleHelper {
  LocaleHelper._();

  static List<String> rtlLanguageCode = [
    'ar', // Arabic
    'ur', // Urdu
    'fa', // Farsi
    'pr', // Persian
    'he', // Hebrew
    'iw', //Hebrew (old code)
    'ps', // Pashto
    'dv', //Divehi
    'ha', //Hausa
    'ji', //Yiddish (old code)
    'yi', //Yiddish
  ];

  static bool hasRtlChar(String inp){
    var rtlChars = RegExp('[\u0600-\u06FF\u0750-\u077F\u08A0–\u08FF\uFB50–\uFBC1\uFBD3-\uFD3F\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFD\uFE70-\uFEFC\u0660-\u0669\u06F0-\u06F9]+',
        caseSensitive: false, multiLine: true);
    return rtlChars.hasMatch(inp);

    // https://en.wikipedia.org/wiki/List_of_Unicode_characters
    // https://en.wikipedia.org/wiki/Arabic_script_in_Unicode
    // https://en.wikipedia.org/wiki/Persian_alphabet
    // arabic Number: \u0660-\u0669
    // persian Number: \u06F0-\u06F9
  }

  /// https://www.regular-expressions.info/unicode.html
  /// https://javascript.info/regexp-unicode

  static String removeNonAscii(String str) {
    return str.replaceAll(RegExp('[^\\x00-\\x7F]', unicode: true, multiLine: true), '');
  }

  static String removeNoneViewable(String str){ // All Control Char \u200E\u200F
    return str.replaceAll(RegExp(r'[\p{C}]', unicode: true, multiLine: true), '');
  }

  static String removeNoneViewableFull(String str) {
    return removeNoneViewable(str).replaceAll(RegExp('[\\r\\n\\t]', unicode: true, multiLine: true), '');
  }

  static String numberToFarsi(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (var i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }

    for (var i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], farsi[i]);
    }

    return input;
  }

  static String? numberToArabic(String? input) {
    if (input == null) {
      return null;
    }

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (var i = 0; i < english.length; i++) {
      input = input!.replaceAll(english[i], arabic[i]);
    }

    for (var i = 0; i < farsi.length; i++) {
      input = input!.replaceAll(farsi[i], arabic[i]);
    }

    return input;
  }

  static String? numberToEnglish(String? input) {
    if (input == null) {
      return null;
    }

    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-']; // [-]: 45
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '−']; // [-]: 8722 or \u2212
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '−'];

    for (var i = 0; i < farsi.length; i++) {
      input = input!.replaceAll(farsi[i], english[i]);
    }

    for (var i = 0; i < arabic.length; i++) {
      input = input!.replaceAll(arabic[i], english[i]);
    }

    return input;
  }

  static String? removeMarks(String? input) {
    if (input == null) {
      return null;
    }

    const marks = ['\u202A', '\u202B', '\u202C', '\u202D', '\u202E',
      '\u2066', '\u2067', '\u2068', '\u2069', '\u200E', '\u200F', '\u061C'];

    for (var i = 0; i < marks.length; i++) {
      input = input!.replaceAll(marks[i], '');
    }

    return input;
  }

  /// https://en.wikipedia.org/wiki/Bidirectional_text
  /// https://www.w3.org/International/questions/qa-bidi-unicode-controls

  // var txt = '  ($amount)  -  $dateHuman';
  // txt = LocaleHelper.embedLtr(txt);
  /// used
  static String embedLtr(String text) {
    var res = StringBuffer();

    res.write('\u202A');
    res.write(text);
    res.write('\u202C');

    return res.toString();
  }

  ///used
  static String embedRtl(String text) {
    var res = StringBuffer();

    res.write('\u202B');
    res.write(text);
    res.write('\u202C');

    return res.toString();
  }

  static String overrideLtr(String text) { //LRO
    var res = StringBuffer();

    res.write('\u202D');
    res.write(text);
    res.write('\u202C');

    return res.toString();
  }

  static String overrideRtl(String text) {
    var res = StringBuffer();

    res.write('\u202E');
    res.write(text);
    res.write('\u202C');

    return res.toString();
  }

  static String isolateLtr(String text) {
    var res = StringBuffer();

    res.write('\u2066');
    res.write(text);
    res.write('\u2069');

    return res.toString();
  }

  static String isolateRtl(String text) { //RLI
    var res = StringBuffer();

    res.write('\u2067');
    res.write(text);
    res.write('\u2069');

    return res.toString();
  }

  static String isolateAuto(String text) { //FSI
    var res = StringBuffer();

    res.write('\u2068');
    res.write(text);
    res.write('\u2069');

    return res.toString();
  }

  static String markRtl(String text) {
    var res = StringBuffer();

    res.write('\u200F'); //&rlm &#8207
    res.write(text);

    return res.toString();
  }

  static String markLtr(String text) {
    var res = StringBuffer();

    res.write('\u200E'); //&lrm &#8206
    res.write(text);

    return res.toString();
  }

  static String markArabic(String text) {
    var res = StringBuffer();

    res.write('\u061C');
    res.write(text);

    return res.toString();
  }
}
