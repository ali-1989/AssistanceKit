// Dart imports:
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';

// Project imports:
import 'package:assistance_kit/api/assistance/file_assistance.dart';

class Logger {
  static Logger? _staticLogger;
  final String _dirPath;
  final String _fileName;
  SendPort? _sendPort;
  late Completer<bool> _initCompleter;

  static Logger get L {
    _staticLogger ??= Logger(getStoragePath(), fileName: 'public_log');
    return _staticLogger!;
  }

  Logger(this._dirPath, {String? fileName}): _fileName = fileName?? 'log' {
    final receiver = ReceivePort();
    _initCompleter = Completer();
    final msg = DataHolder(receiver.sendPort, _fileName, _dirPath);

    final f = Isolate.spawn<DataHolder>(isolateFunction, msg);

    f.then((isolate) {
      receiver.first.then((port){
        _sendPort = port;
        receiver.close();
        _initCompleter.complete(true);
      });
    });
  }

  Future<bool> isPrepare() => _initCompleter.future;

  void logToAll(dynamic obj){
    logToScreen(obj);
    logToFile(obj);
  }

  void logToFile(dynamic text){
    _sendPort?.send(['◄LOGGER►$text']);
  }

  void logToScreen(dynamic text){
    print('◄LOGGER►${text.toString()}');
  }

  static String getStoragePath(){
    //return MemoryFileSystem().systemTempDirectory.path;
    // G:/Programming/DartProjects/project/bin/run.dart
    var pat = Platform.script.path;

    if(Platform.isWindows) {
      if (pat.startsWith(r'\') || pat.startsWith(r'/')) {
        pat = pat.substring(1);
      }
    }

    var f = File(pat);
    f = File(f.parent.parent.path);

    return f.path;
  }
}
///=============================================================================
void isolateFunction(DataHolder dataHolder){
  final receiver = ReceivePort();
  final Queue<String> _queue = Queue();
  bool _isWriting = false;
  var _counter = 1;

  dataHolder.sendPort.send(receiver.sendPort);

  ///---------------------------------------------
  Future<String> getFilePath() async {
    final p = '${dataHolder.basePath}${Platform.pathSeparator}${dataHolder.fileName}$_counter.txt';
    final f = File(p);

    if (!await f.exists()) {
      await FileAssistance.createNewFile(p);
      return p;
    }

    if (await f.length() < 1024000) {
      return p;
    }

    _counter++;
    return getFilePath();
  }
  ///---------------------------------------------
  Future<void> processQueue() async {
    if (_isWriting){
      return;
    }

    _isWriting = true;

    while (_queue.isNotEmpty) {
      final text = _queue.removeFirst();
      final path = await getFilePath();
      await _logToRelativeFile(path, text);
    }

    _isWriting = false;
  }

  receiver.listen((message) {
    _queue.add(message[0]);
    processQueue();
  });
  ///---------------------------------------------
  receiver.listen((message) async {
    _queue.add(message);

    while(_queue.isNotEmpty) {
      final lis = _queue.removeFirst(); //_queue.elementAt(0);
      await _log(await getFilePath(), lis[0]);
    }
  });
}

Future _log(String filePath, String text) async{
  return _logToRelativeFile(filePath, text);
}

Future<void> _logToRelativeFile(String filePath, String text) async {
  var f = File(filePath);

  var pr = '$text\n------------------------|\n';
  /*this is not write full code: final oFile = await f.open(mode: FileMode.append, );
  oFile.writeStringSync(pr);
  oFile.closeSync();*/
  await f.writeAsString(pr, mode: FileMode.append, flush: true);
}
///=============================================================================
class DataHolder {
  SendPort sendPort;
  String fileName;
  String basePath;

  DataHolder(this.sendPort, this.fileName, this.basePath);
}



/*
void isoHandler2(SendPort port) {
  var com = ReceivePort();
  port.send(com.sendPort);
}
 */
