import 'dart:io';
import 'package:assistance_kit/api/logger/logger.dart';

Future main(List<String> arguments) async {
  var startInfo = '''
    ====================================================================================
    ====================================================================================
    start at: ${DateTime.now().toUtc()}  UTC
    start at: ${DateTime.now()}  Local
    exe path: ${File(Platform.script.path).parent.path}
    -----------
  ''';

  Logger.L.logToScreen(startInfo);
}
