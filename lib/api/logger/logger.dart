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
    _staticLogger ??= Logger(getStoragePath(), logName: 'staticLog');

    return _staticLogger!;
  }

  Logger(this._dirPath, {String? logName}): _fileName = logName?? 'log' {
    var receiver = ReceivePort();
    _completer = Completer();
    var msg = IsolateData(receiver.sendPort, _fileName, _dirPath);

    var f = Isolate.spawn<IsolateData>(isoHandler, msg);
    f.then((iso) {
      //_isolate = iso;

      receiver.first.then((port){
        _sendPort = port;
        receiver.close();
        _completer.complete(true);
      });
    });
  }

  Future<bool> isPrepare() => _completer.future;

  void logToAll(dynamic obj, {String type = ''}){
    logToScreen(obj, type: type);
    logToFile(obj, type: type);
  }

  void logToFile(dynamic text, {String type = ''}){
    _sendPort?.send(['◄LOGGER►$type', text.toString()]);
  }

  void logToScreen(dynamic text, {String type = ''}){
    if(type.isNotEmpty) {
      print('◄LOGGER►[$type]: ${text.toString()}');
    }
    else {
      print('◄LOGGER►$text');
    }
  }

  static String getStoragePath(){
    //return MemoryFileSystem().systemTempDirectory.path;

    // G:/Programming/DartProjects/BrandfitServer/bin/run.dart
    var pat = Platform.script.path;

    if(Platform.isWindows) {
      if (pat.startsWith(r'\') || pat.startsWith(r'/')) {
        pat = pat.substring(1);
      }
    }

    var f = File(pat);
    f = File(f.parent.parent.path);
    //f = File(f.parent.path);

    return f.path;
  }
}
///=============================================================================
void isoHandler2(SendPort port) {
  var com = ReceivePort();
  port.send(com.sendPort);
}

void isoHandler(IsolateData isolateData){
  var com = ReceivePort();
  final _que = Queue<List<String>>();
  var _counter = 1;

  isolateData.port.send(com.sendPort);


  com.listen((message) {
    _que.add(message);
  });

  Future<String> getFilePath() async{
    var p = isolateData.basePath + Platform.pathSeparator + '${isolateData.fileName}$_counter.txt';
    var f = File(p);

    if(!f.existsSync()) {
      await FileHelper.createNewFile(p);
      return p;
    }
    else {
      var size = await f.length();

      if(size < 1024000){
        return p;
      }

      _counter++;
      return getFilePath();
    }
  }

  Timer.periodic(Duration(milliseconds: 200), (timer) async{

    while(_que.isNotEmpty) {
      var lis = _que.removeFirst();//_que.elementAt(0);

      await _log(await getFilePath(), lis[1], lis[0]);
    }
  });
}

Future _log(String filePath, String text, String type) async{
  return _logToRelativeFile(filePath, text, type);
}

Future<void> _logToRelativeFile(String filePath, String text, String type) async {
  var f = File(filePath);

  var pr = '$type::$text\n----------------------------|\n';
  await f.writeAsString(pr, mode: FileMode.append);
}
///=============================================================================
class IsolateData {
  SendPort port;
  String fileName;
  String basePath;

  IsolateData(this.port, this.fileName, this.basePath);
}

