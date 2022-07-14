class Checker {
	Checker._();

	static bool validateMobile(String value) {
		// -> '^(( (\+|00) ([1-9]{1,4}[\s-]?)  \d{10}) |  0\d{10})$'
		var pat = r'^(((\+|00)([1-9]{1,4}[\s-]?)\d{10})|0\d{10})$';
		var regExp = RegExp(pat);

		return regExp.hasMatch(value);
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
		var ePattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
				r'(([(\d|[1-9]\d|1[0-9][0-9]|(2([0-4]\d|5[0-5])))\.'
				r'(\d|[1-9]\d|1[0-9][0-9]|(2([0-4]\d|5[0-5])))\.'
				r'(\d|[1-9]\d|1[0-9][0-9]|(2([0-4]\d|5[0-5])))\.'
				r'(\d|[1-9]\d|1[0-9][0-9]|(2([0-4]\d|5[0-5])))])|(([a-zA-Z\\-0-9]+\.)+[a-zA-Z]{2,}))$';

		var regExp = RegExp(ePattern);
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

	static String? _numberToEnglish(String? input) {
		if (input == null) {
		  return null;
		}

		const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
		const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
		const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

		for (var i = 0; i < farsi.length; i++) {
			input = input!.replaceAll(farsi[i], english[i]);
		}

		for (var i = 0; i < arabic.length; i++) {
			input = input!.replaceAll(arabic[i], english[i]);
		}

		return input;
	}
}