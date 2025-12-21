// Dart imports:
import 'dart:convert';

class TextAssistance{
	TextAssistance._();

	static final RegExp _exp = RegExp(r'%');

	/// interpolate('Hello %, cool %',['world','!']);
	static String interpolate(String string, List l) {
		var matches = _exp.allMatches(string);

		assert(l.length == matches.length);

		var i = -1;
		return string.replaceAllMapped(_exp, (match) {
			i = i + 1;
			return '${l[i]}';
		});
	}

	static String subStringByCountSafe(String? str, int count) {
		if (isEmptyOrNull(str)) {
		  return '';
		}

		if (str!.length < count) {
		  return str;
		}

		return str.substring(0, count);
	}

	static String? removeFromLast(String? str, {int num = 1}){
		if (str != null && str.length > num) {
			str = str.substring(0, str.length - num);
		}

		return str;
	}

	static bool isEmptyOrNull(dynamic input){
		if (input == null || input.toString().trim().isEmpty) {
			return true;
		}

		return false;
	}

	static dynamic nullIfIsEmpty(dynamic input){
		if (input == null || input.toString().isEmpty) {
			return null;
		}

		return input;
	}

	static String emptyIfnull(dynamic input){
		if (input == null) {
			return '';
		}

		return input.toString();
	}

	static String? subStringByRegex(String src, String pattern, int group){
		var pat = RegExp(pattern);

		if(pat.hasMatch(src)) {
		  return pat.firstMatch(src)?.group(group);
		}

		return '';
	}

	static String subStringSafe(String? src, int start, int end){
		if(src == null || start > src.length) {
		  return '';
		}

		var endTrue = src.length > end? end : src.length;
		return src.substring(start, endTrue);
	}

	static String padLeftIfSmall(String src, int max, {String p = ' '}){
		if(src.length < max) {
			//return src.padLeft(max - src.length, p);
			return src.padLeft(max, p);
		}

		return src;
	}

	static String removeSpace(String? src){
		if(src == null){
			return '';
		}

		return src.replaceAll(RegExp(r'\s'), '');
	}

	static String scapeNewLine(String? src){
		if(src == null){
			return '';
		}

		return src.replaceAll(RegExp(r'(\n|\r\n|\r)', multiLine: true, unicode: true), r'\n');
	}

	static List<String> getWords(String src){
		return src.split(RegExp(r'\b\w+\b'));
	}

	static int countWords(String text) {
		// remove syntax sgins
		String cleaned = text.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '');

		List<String> words = cleaned
				.trim()
				.split(RegExp(r'\s+')) // enter, tab, space
				.where((word) => word.isNotEmpty)
				.toList();

		return words.length;
	}

	static String getFirstWord(String? src){
		if(src == null){
			return '';
		}

		int idx = src.length;

		for(int i=1; i < src.length; i++){
			if(src[i] == ' '){
				idx = i;
				break;
			}
		}

		return src.substring(0, idx);
	}

	static List<String> splitRegex(String src, String reg){
		return src.split(RegExp(reg));
	}

	static String replace(String src, String regText, String replace){
		return src.replaceAllMapped(RegExp(regText), (match) {
			return replace;  // return '"${match.group(0)}"'
		});
	}

	// removeUntil('$value', "0", "1")
	static String? removeUntil(String? input, String remove, String breakText) {
		if(input == null) {
		  return null;
		}

		var res = StringBuffer();
		var find = false;

		for(var i=0; i<input.length; i++){
			if(!find && input[i] == remove) {
			  continue;
			}

			if(input[i] == breakText) {
			  find = true;
			}

			res.write(input[i]);
		}

		return res.toString();
	}

	static String removeNonAscii(String str) {
		return str.replaceAll(RegExp(r'[^\x00-\x7F]', caseSensitive: false, multiLine: true, unicode: true), '');
	}

	static String removeNonViewable(String str){ // All Control Char
		return str.replaceAll(RegExp(r'[\p{C}]', caseSensitive: false, multiLine: true, unicode: true), '');
	}

	static String removeNonViewableFull(String str) {
		return removeNonViewable(str)
				.replaceAll(RegExp(r'[\r\n\t]', caseSensitive: false, multiLine: true, unicode: true), '');
	}

	static int countLines(String text) {
		if (text.trim().isEmpty) {
			return 0;
		}

		List<String> lines = text.split('\n');
		return lines.length;
	}

	static int countNonEmptyLines(String text) {
		if (text.trim().isEmpty) {
			return 0;
		}

		List<String> lines = text.split('\n');

		final proccesed = lines.map((line) => line.trim())
				.where((line) => line.isNotEmpty)
				.toList();

		return proccesed.length;
	}

	static int countPragraphs(String text) {
		if (text.trim().isEmpty) {
			return 0;
		}

		List<String> lines = text.split('\n');

		int paragraphs = 0;
		bool lastWasEmpty = true;

		for (var line in lines) {
			if (line.trim().isEmpty) {
				lastWasEmpty = true;
			}
			else {
				if (lastWasEmpty) {
					paragraphs++;
				}

				lastWasEmpty = false;
			}
		}

		return paragraphs;
	}
}
///=============================================================================
const String _spaces = r'[\s]*';
const String _paramExpressionSet = r'[\w]+';
///=============================================================================
class InterpolationOption {
	final String _prefix;
	final String _suffix;
	final String _subKeyPointer;

	// {required String prefix, required String suffix, required String subKeyPointer}): _prefix = prefix, _suffix = suffix, _subKeyPointer = subKeyPointer
	InterpolationOption._init(this._prefix, this._suffix, this._subKeyPointer);

	factory InterpolationOption(
			{String prefix = '{',
				String suffix = '}',
				String subKeyPointer = '.'}) =>
			InterpolationOption._init(prefix, suffix, subKeyPointer);

	String _escapedTrim(String val) => RegExp.escape(val.trim());

	String get prefix => _escapedTrim(_prefix);

	String get suffix => _escapedTrim(_suffix);

	String get subKeyPointer => _escapedTrim(_subKeyPointer);
}
///=============================================================================
class Interpolation {
	final InterpolationOption _option;
	late RegExp _paramRegex;

	Interpolation._init(this._option) {
		_paramRegex = _getParamRegex;
	}

	factory Interpolation({InterpolationOption? option}) =>
			Interpolation._init(option ?? InterpolationOption());

	String _missingKeyKeepAlive(String key) =>
			'${_option._prefix}$key${_option._suffix}';

	RegExp get _getParamRegex => RegExp(
			'${_option.prefix}'
					'($_spaces$_paramExpressionSet'
					'(?:(${_option.subKeyPointer})$_paramExpressionSet)*$_spaces)'
					'${_option.suffix}',
			caseSensitive: true,
			multiLine: false,
			dotAll: true);

	String traverse(Map<String, dynamic>? obj, String key, [bool keepAlive = false]) {
		var result = key.split(_option._subKeyPointer).fold(
				obj,
						(parent, k) => null == parent
						? null
						: parent is String
						? parent
						: (parent as dynamic)[k]);
		return result?.toString() ?? (keepAlive ? _missingKeyKeepAlive(key) : '');
	}

	Set<String> _getMatchSet(String str) =>
			_paramRegex.allMatches(str).map((match) => match[1]!).toSet();

	String _getInterpolated(String str, Map<String, String> values, [bool keepAlive = false]) {
		return str.replaceAllMapped(_paramRegex, (match) {
			var param = match[1]!.trim();
			return values.containsKey(param)
					? values[param]!
					: keepAlive
					? match[0]!
					: '';
		});
	}

	Map<String, String> _flattenAndResolve(
			Map<String, dynamic> obj, Set<String> matchSet,
			[Map<String, String>? oldCache, bool keepAlive = false]) {
		var cache = oldCache ?? <String, String>{};

		for (var match in matchSet) {
			if (cache.containsKey(match)) {
			  return cache;
			}

			var curVal = traverse(obj, match, keepAlive);

			if (_missingKeyKeepAlive(match) != curVal && _paramRegex.hasMatch(curVal)) {

				var missingMatchSet = _getMatchSet(curVal);
				missingMatchSet.removeAll(cache.keys);

				if (missingMatchSet.isNotEmpty) {
					cache = _flattenAndResolve(obj, missingMatchSet, cache, keepAlive);
				}

				curVal = _getInterpolated(curVal, cache, keepAlive);
			}

			cache[match] = curVal.replaceAll('"', '\\"');
		}

		return cache;
	}

	String eval(String str, Map<String, dynamic> values, [bool keepAlive = false]) {
		if (_paramRegex.hasMatch(str)) {
			var missingMatchSet = _getMatchSet(str);
			var cache = _flattenAndResolve(values, missingMatchSet, null, keepAlive);
			str = _getInterpolated(str, cache, keepAlive);
		}

		return str;
	}

	Map<String, dynamic> resolve(Map<String, dynamic> obj, [bool keepAlive = false]) {
		var jsonString = json.encode(obj);
		jsonString = eval(jsonString, obj, keepAlive);
		return json.decode(jsonString);
	}
}

/*	Interpolation usage:

  var interpolation = Interpolation();
  var str = "Hi, my name is '{name}'. I'm {age}. I am {education.degree} {education.profession}.";

  pr(interpolation.eval(str, {
    'name': 'David',
    'age': 29,
    'education': {'degree': 'M.B.B.S', 'profession': 'Doctor'}
  }));


  mapObject = {a:'ali' , m:{'second': 'val', x:y}}
  interpolation.traverse(mapObject, 'm.second'))    ==> val
 */
