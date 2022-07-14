import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart' as p; // work with path address

/// https://medium.com/flutter-community/working-with-bytes-in-dart-6ece83455721

class FileHelper {
  FileHelper._();

  static File getFile(String? path) {
    File f;

      f = File(path?? '');

    return f;
  }

  static Future<File> createNewFile(String path, {bool withDir = true}) async {
    return File(path).create(recursive: withDir);
  }

  static Future<Directory> createDirectory(String path, {bool withDir = true}) async {
    return Directory(path).create(recursive: withDir);
  }

  static void createDirectorySync(String path, {bool withDir = true}) {
    return Directory(path).createSync(recursive: withDir);
  }

  static void createLinkSync(String path, String target, {bool withDir = true}) {
    return Link(path).createSync(target, recursive: withDir);
  }

  static File createNewFileSync(String path, {bool withDir = true}) {
    var f = getFile(path);
    f.createSync(recursive: withDir);
    return f;
  }

  static Future<Uint8List> readFile(String path) {
    return getFile(path).readAsBytes();
  }

  static Uint8List readFileSync(String path) {
    return getFile(path).readAsBytesSync();
  }

  static Future<Uint8List> readFileBytes(String path, int len) async {
    //final String fileName = Platform.script.toFilePath();
    final file = getFile(path);
    var fileOpen = await file.open(mode: FileMode.read); // is RandomAccessFile

    var count = 0;
    var bytes = <int>[];
    var byte = 0;

    while (byte != -1 && count < len) {
      byte = fileOpen.readByteSync();
      bytes.add(byte);
      count++;
    }

    await fileOpen.close();
    return Uint8List.fromList(bytes);
  }

  static Future<bool> exist(String path) async {
    return getFile(path).exists();
  }

  static bool existSync(String path) {
    return getFile(path).existsSync();
  }

  static Future<FileSystemEntity> delete(String? path) {
    return getFile(path).delete();
  }

  static void deleteSync(String path) {
    getFile(path).deleteSync();
  }

  static Future<DateTime> lastModified(String path) async {
    return getFile(path).lastModified();
  }

  static DateTime lastModifiedSync(String path) {
    return getFile(path).lastModifiedSync();
  }

  static Future<int> length(String path) async {
    return getFile(path).length();
  }

  static int lengthSync(String path) {
    return getFile(path).lengthSync();
  }

  static Future<File> rename(String path, String newName) async {
    return getFile(path).rename(newName);
  }

  /// newNameAddress:    /path/name.ext
  static File renameSync(String path, String newNameAddress) {
    return getFile(path).renameSync(newNameAddress);
  }

  static File renameSyncSafe(String path, String newNameAddress) {
    try{
      return renameSync(path, newNameAddress);
    }
    catch (e){
      return getFile(path);
    }
  }

  static String getFileName(String path) {
    return p.basename(path);
  }

  static String getFileNameWithoutExtension(String path) {
    return p.basenameWithoutExtension(path);
  }

  // return with {.}  >> .jpg  | >> ''
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
    var n = p.basenameWithoutExtension(path);
    return n + getDotExtensionForce(path, dotExtension);
  }

  static Stream<FileSystemEntity> getDirContentsStream(String path) {
    return Directory(path).list(recursive: false);
  }

  static List<FileSystemEntity> getDirContentsSync(String path) {
    return Directory(path).listSync(recursive: false).toList();
  }

  static Future<List<FileSystemEntity>> getDirContents(String path) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = Directory(path).list(recursive: false);

    lister.listen ((file) => files.add(file),
        onDone: () => completer.complete(files)
    );

    return completer.future;
  }

  static Future<List<String>> getDirFiles(String path) {
    var files = <String>[];
    var completer = Completer<List<String>>();
    var lister = Directory(path).list(recursive: false);

    lister.listen ((file){
      //FileSystemEntity.typeSync(file.path) != FileSystemEntityType.directory;

      if(FileSystemEntity.isFileSync(file.path)){
        files.add(file.path);
      }
    },
        onDone: () => completer.complete(files)
    );

    return completer.future;
  }

  static String getDirPath(String path) {
    return p.dirname(path);
  }

  static Future<FileStat> stat(String path) async {
    return getFile(path).stat();
  }

  static FileStat statSync(String path) {
    return getFile(path).statSync();
  }

  static Future<File> writeStringToFile(File file, String content) async {
    return file.writeAsString(content, encoding: Encoding.getByName('utf-8')?? Utf8Codec());
  }

  static Future<File> writeBytesToFile(File file, List<int> content) async {
    return file.writeAsBytes(content);
  }

  static void writeStringToFileSync(File file, String content) {
    file.writeAsStringSync(content, encoding: Encoding.getByName('utf-8')!);
  }

  static void writeBytesToFileSync(File file, List<int> content) {
    file.writeAsBytesSync(content);
  }

  static Future<File> writeString(String filePath, String content) async {
    var file = await createNewFile(filePath);
    return file.writeAsString(content, encoding: Encoding.getByName('utf-8')!);
  }

  static Future<File> writeBytes(String filePath, List<int> content) async {
    var file = await createNewFile(filePath);
    return file.writeAsBytes(content);
  }

  static void writeStringSync(String filePath, String content) {
    var file = createNewFileSync(filePath);
    file.writeAsStringSync(content, encoding: Encoding.getByName('utf-8')!);
  }

  static void writeBytesSync(String filePath, List<int> content) {
    var file = createNewFileSync(filePath);
    file.writeAsBytesSync(content);
  }

  static void writeByteDataSync(String filePath, ByteData data) {
    var file = createNewFileSync(filePath);
    final buffer = data.buffer;
    file.writeAsBytesSync(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<File> writeByteData(String filePath, ByteData data) async{
    var file = await createNewFile(filePath);
    final buffer = data.buffer;
    return file.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<File> appendString(String filePath, String content) async {
    var file = getFile(filePath);
    return file.writeAsString(content, mode: FileMode.append, encoding: Encoding.getByName('utf-8')!, flush: true);
  }

  static Future<File> appendBytes(String filePath, List<int> content) async {
    var file = getFile(filePath);
    return file.writeAsBytes(content, mode: FileMode.append, flush: true);
  }

  static void appendStringSync(String filePath, String content) {
    var file = getFile(filePath);
    file.writeAsStringSync(content, mode: FileMode.append, encoding: Utf8Codec(), flush: true);
  }

  static void appendBytesSync(String filePath, List<int> content) {
    var file = getFile(filePath);
    file.writeAsBytesSync(content, mode: FileMode.append, flush: true);
  }

  static Future<RandomAccessFile> openFile(String filePath, FileMode mode) async {
    var file = getFile(filePath);
    return file.open(mode: mode);
  }

  static RandomAccessFile openFileSync(File file, FileMode mode) {
    return file.openSync(mode: mode);
  }

  static Future<String> readAsString(String filePath) async {
    var file = getFile(filePath);
    return file.readAsString();
  }

  static String readAsStringSync(String filePath) {
    var file = getFile(filePath);
    return file.readAsStringSync();
  }

  static Future<Uint8List> readAsBytes(String filePath) async {
    var file = getFile(filePath);
    return file.readAsBytes();
  }

  static Uint8List readAsBytesSync(String filePath) {
    var file = getFile(filePath);
    return file.readAsBytesSync();
  }

  static Future<File> copy(String path, String newPath) async {
    return getFile(path).copy(newPath);
  }

  static File copySync(String path, String newPath) {
    return getFile(path).copySync(newPath);
  }

  Future mergeFiles(String baseFile, String appendFile) async {
    var base = getFile(baseFile);
    var f2 = getFile(appendFile);
    var ioSink = base.openWrite(mode: FileMode.writeOnlyAppend); //IOSink
    await ioSink.addStream(f2.openRead());
    await f2.delete();
    await ioSink.close();
  }

  static Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      return await sourceFile.rename(newPath);
    }
    on FileSystemException {
      var newFile = await getFile(newPath).create(recursive: true);
      newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }
}