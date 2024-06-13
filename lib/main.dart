import 'dart:io';
import 'package:assistance_kit/api/logger/logger.dart';
import 'package:assistance_kit/dateSection/date_helper.dart';

Future main(List<String> arguments) async {
  var startInfo = '''
    ============================================================================
    ============================================================================
    start at: ${DateTime.now().toUtc()}  UTC
    start at: ${DateTime.now()}  Local
    exe path: ${File(Platform.script.path).parent.path}
    -----------
  ''';

  Logger.L.logToScreen(startInfo);
  codes();
}

void codes(){
  final d1 = DateTime.now();
  final d2 = DateTime.timestamp();
  final d3 = DateTime.now().toUtc();
  final d4 = DateHelper.nowMinusUtcOffset();
  final d5 = DateHelper.localPcToUtc(d1);
  final d6 = DateHelper.localToUtc(d1, 'Asia/Tehran');
  final d7 = DateHelper.localToUtc(d1, 'Asia/Tehran', isDayLight: true);

  print('$d1,  ${d1.millisecondsSinceEpoch}');
  print('$d2,  ${d2.millisecondsSinceEpoch}');
  print('$d3,  ${d3.millisecondsSinceEpoch}');
  print(d4);
  print(d5);
  print(d6);
  print(d7);
}
