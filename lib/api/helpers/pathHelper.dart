import 'package:assistance_kit/api/helpers/textHelper.dart';
import 'package:assistance_kit/api/system.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart'; // work with path address

class PathHelper{
  PathHelper._();

  // dir/f.js  >> f.js
  static String getFileName(String path) {
    return p.basename(path);
  }

  //   dir/f.js  >> f
  static String getFileNameNoExtension(String path) {
    return p.basenameWithoutExtension(path);
  }

  // return with {.}  >> .jpg |  >> ''
  static String getDotExtension(String path) {
    return p.extension(path);
  }

  static String getDotExtensionForce(String path, String replace) {
    var f = p.extension(path);

    if(f.isEmpty || !f.contains(RegExp(r'\.'))) {
      f = replace;
    }

    return f;
  }

  static String getNameDotExtensionForce(String path, String dotExtension) {
    final n = p.basenameWithoutExtension(path);
    return n + getDotExtensionForce(path, dotExtension);
  }

  static String getParentDirPath(String path) {
    return p.dirname(resolvePath(path)!);
  }

  static List<String> splitDir(String path) {
    return p.split(path);
  }

  //  /  or  c:\  or  http:://x.com  or  ''
  static String getRootPrefix(String path) {
    return p.rootPrefix(path);
  }

  // file:///path/to/foo'  --> '/path/to/foo
  static String fileUriToPath(String uri) {
    return p.fromUri(uri);
  }

  static bool isWithin(String parent, String child) {
    return p.isWithin(parent, child);
  }

  //win: K:\Programming\DartProjects\IrisDB\
  //android: /
  static String gstCurrentPath() {
    return p.current;
  }

  static String getSeparator() {
    return p.separator;
  }

  static String? resolveEndSeparator(String? path) {
    if(path == null) {
      return null;
    }

    return path.replaceAll(RegExp(r'(\\{2,})$'), r'\').replaceAll(RegExp('(/{2,})\$'), '/');
  }

  static String? resolvePath(String? path) {
    if(path == null) {
      return null;
    }

    if(System.isWindows()) {
      path = path.replaceAll(RegExp(r'/'), r'\');
      path = path.replaceAll(RegExp(r'^(\\+)'), '');//.replaceAll(RegExp('^(/+)'), '');
      path = path.replaceAll(RegExp(r'(?<!:)\\{2,}'), r'\');
    }
    else {
      path = path.replaceAll(RegExp(r'\\'), '/');
      path = path.replaceAll(RegExp('(?<!:)/{2,}'), '/');
    }

    return path;
  }

  static String? resolveUrl(String? url) {
    if(url == null) {
      return null;
    }

    url = url.replaceAll(RegExp(r'\\'), r'/');
    url = url.replaceAll(RegExp('(?<!:)/{2,}'), '/');

    return url;
  }

  /// change multi / or \ to one
  /// remove end / or \
  static String? normalize(String? path) {
    if(path == null) {
      return null;
    }

    final res = p.normalize(path);

    if(System.isWindows() && res.startsWith(RegExp(r'\\'))) {
      return res.substring(1);
    }

    return res;
  }

  static String? canonicalize(String? path) {
    if(path == null) {
      return null;
    }

    return p.canonicalize(path);
  }

  static String? joinWindows(String path1, String path2) {
    final context = p.Context(style: Style.windows);
    return context.join(path1, path2);
  }

  static String? joinMacLinux(String path1, String path2) {
    final context = p.Context(style: Style.posix);
    return context.join(path1, path2);
  }

  static String? join(String path1, String path2) {
    final context = p.Context(style: Style.platform);
    return context.join(path1, path2);
  }

  static bool isStartBy(String master, String startBy) {
    if (TextHelper.isEmptyOrNull(master) || TextHelper.isEmptyOrNull(startBy)) {
      return false;
    }

    return master.startsWith(startBy);
  }

  static String removeIfStartBy(String? master, String? startBy) {
    if (TextHelper.isEmptyOrNull(master) || TextHelper.isEmptyOrNull(startBy)) {
      return '';
    }

    if (master!.startsWith(startBy!)) {
      return master.substring(startBy.length);
    } else {
      return master;
    }
  }
}