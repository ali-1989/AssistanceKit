import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'package:assistance_kit/api/helpers/fileHelper.dart';

class Logger {
  static Logger? _staticLogger;
  final String _dirPath;
  final String _fileName;
  //late Isolate _isolate;
  SendPort? _sendPort;
  late Completer<bool> _completer;

  static Logger get L {
    _staticLogger ??= Logger(getStoragePath(), fileName: 'public_log');
    return _staticLogger!;
  }

  Logger(this._dirPath, {String? fileName}): _fileName = fileName?? 'log' {
    final receiver = ReceivePort();
    _completer = Completer();
    final msg = DataHolder(receiver.sendPort, _fileName, _dirPath);

    final f = Isolate.spawn<DataHolder>(isolateFunction, msg);

    f.then((isolate) {
      receiver.first.then((port){
        _sendPort = port;
        receiver.close();
        _completer.complete(true);
      });
    });
  }

  Future<bool> isPrepare() => _completer.future;

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
  final _que = Queue<List<String>>();
  var _counter = 1;

  dataHolder.sendPort.send(receiver.sendPort);

  Future<String> getFilePath() async {
    final p = dataHolder.basePath + Platform.pathSeparator + '${dataHolder.fileName}$_counter.txt';
    final f = File(p);

    if(!f.existsSync()) {
      await FileHelper.createNewFile(p);
      return p;
    }
    else {
      final size = await f.length();

      if(size < 1024000){
        return p;
      }

      _counter++;
      return getFilePath();
    }
  }

  receiver.listen((message) async {
    _que.add(message);

    while(_que.isNotEmpty) {
      final lis = _que.removeFirst(); //_que.elementAt(0);
      await _log(await getFilePath(), lis[0]);
    }
  });


  /*Timer.periodic(Duration(milliseconds: 250), (timer) async {
    while(_que.isNotEmpty) {
      final lis = _que.removeFirst(); //_que.elementAt(0);

      await _log(await getFilePath(), lis[1], lis[0]);
    }
  });*/
}

Future _log(String filePath, String text) async{
  return _logToRelativeFile(filePath, text);
}

Future<void> _logToRelativeFile(String filePath, String text) async {
  var f = File(filePath);

  var pr = '$text\n------------------------|\n';
  final oFile = await f.open(mode: FileMode.append);
  oFile.writeStringSync(pr);
  oFile.closeSync();
  //await f.writeAsString(pr, mode: FileMode.append);
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