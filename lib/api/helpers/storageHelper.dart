import 'package:path/path.dart' as pat; // work with path address
import 'package:file/file.dart' as fs;
import 'package:file/src/backends/memory.dart';
import 'package:file/local.dart';

/// /storage/emulated/0/ARE
/// /data/user/0/ir.iris.ARE/files

class StorageHelper {
	StorageHelper._();

	//  /  or  c:\  or  http:://x.com  or  ''
	static String getRootPrefix(String path) {
		return pat.rootPrefix(path);
	}

	static String gstCurrentPath() {
		return pat.current;
	}

	static String getDirSeparator() {
		return pat.separator;
	}

	static Future<double> getFreeDiskSpace() async {
		double? size = 100;

		return Future<double>.value(size);
	}

	static Future<double> getTotalDiskSpace() async {
		double? size;

		try {
			size = 100;
		}
		on Exception {
			size = 0;
		}

		return Future<double>.value(size);
	}

	static fs.FileSystem getFileSystem() {
		return const LocalFileSystem();
	}

	static MemoryFileSystem getMemoryFileSystem() {
		return MemoryFileSystem();
	}

	static final Map _osToPathStyle = <String, String>{
		'linux': 'posix',
		'macos': 'posix',
		'android': 'posix',
		'ios': 'posix',
		'fuchsia': 'posix',
		'windows': 'windows',
	};

	static List<String> _getCandidatePaths(String command, List<String> searchPaths,
			List<String> extensions, pat.Context context,) {

		var withExtensions = extensions.isNotEmpty
				? extensions.map((String ext) => '$command$ext').toList()
				: <String>[command];

		if (context.isAbsolute(command)) {
		  return withExtensions;
		}

		return searchPaths
				.map((String path) =>
				withExtensions.map((String command) => context.join(path, command)))
				.expand((Iterable<String> e) => e)
				.toList();
				//.cast<String>();
	}
	///--- Web --------------------------------------------------------------------------------------------
	static String getWebExternalStorage() {
		return getMemoryFileSystem().path.current;
	}
}