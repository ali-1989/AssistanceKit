class ValidChecker {
	ValidChecker._();

	static bool validateMobile(String value) {
		// -> '^(( (\+|00) ([1-9]{1,4}[\s-]?)  \d{10}) |  0\d{10})$'
		var pat = r'^(((\+|00)([1-9]{1,4}[\s-]?)\d{10})|0\d{10})$';
		var regExp = RegExp(pat);

		return regExp.hasMatch(value);
	}

  static bool isValidSheba(String sheba) {
    sheba = sheba.replaceAll(RegExp(r'\s+'), '').toUpperCase();

    // Check basic structure
    if (!sheba.startsWith('IR') || sheba.length != 26) {
      return false;
    }

    // Move first 4 chars to the end (country code + check digits)
    String rearranged = sheba.substring(4) + sheba.substring(0, 4);

    // Replace letters with numbers (A=10, B=11, ..., Z=35)
    String numericSheba = rearranged.split('').map((ch) {
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        return (ch.codeUnitAt(0) - 55).toString(); // A=10, B=11, ...
      }
      else {
        return ch;
      }
    }).join();

    // Perform mod 97 operation
    int remainder = 0;

    for (int i = 0; i < numericSheba.length; i++) {
      int digit = int.parse(numericSheba[i]);
      remainder = (remainder * 10 + digit) % 97;
    }

    // Valid if remainder == 1
    return remainder == 1;
  }

  static bool validateIranNationalCode(String input) {
    if (input.length != 10) return false;

    if (!RegExp(r'^\d{10}$').hasMatch(input)) return false;

    // avoid reapeat: 1111111111
    if (RegExp(r'^(\d)\1{9}$').hasMatch(input)) return false;

    final digits = input.split('').map(int.parse).toList();
    final checkDigit = digits[9];

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }

    final remainder = sum % 11;

    if (remainder < 2) {
      return checkDigit == remainder;
    }
    else {
      return checkDigit == (11 - remainder);
    }
  }

  static bool isNullOrEmpty(dynamic input){
		if(input == null) {
		  return true;
		}

		return input.toString().trim().isEmpty;
	}

	static bool isValidEmail(String email) {
		//String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"
		//+ "\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
		final pattern = '''^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@
    (([(d|[1-9]d|1[0-9][0-9]|(2([0-4]d|5[0-5]))).
    (d|[1-9]d|1[0-9][0-9]|(2([0-4]d|5[0-5]))).
    (d|[1-9]d|1[0-9][0-9]|(2([0-4]d|5[0-5]))).
    (d|[1-9]d|1[0-9][0-9]|(2([0-4]d|5[0-5])))])|(([a-zA-Z\\-0-9]+.)+[a-zA-Z]{2,})\$''';

		final regExp = RegExp(pattern);
		return regExp.hasMatch(email);
	}

	static bool isJson(String? text) {
		if(text == null) {
		  return false;
		}

		var pat = r'^\s*(\{|\[.{0,4}\{).*?(\}|\}.{0,4}\])\s*$';
		var regExp = RegExp(pat, multiLine: true, dotAll: true);
		return regExp.hasMatch(text);
	}

	static bool isSameType(Type t1, Type t2){
		/// 2th section is for nullable (int? == int)
		return t1.hashCode == t2.hashCode || (t1).toString().replaceFirst('?', '') == (t2).toString();
		// T.hashCode == ((int).hashCode)
	}

	static bool isNumeric(String input) {
		if (input.isEmpty) {
			return false;
		}

		return double.tryParse(input) != null;
	}

	static bool isNumericExtend(String input, {bool allowDecimal = true, bool allowNegative = true}) {
		if (input.isEmpty) return false;

		if (allowNegative && input.startsWith('-')) {
			input = input.substring(1);
		}

		if (allowDecimal) {
			final dotCount = '.'.allMatches(input).length;
			if (dotCount > 1) return false;
		}
		else {
			if (input.contains('.')) return false;
		}

		return input.split('').every((char) => '0123456789.'.contains(char));
	}
}