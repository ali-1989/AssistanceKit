/// CustomTrace programInfo = CustomTrace(StackTrace.current);

class CustomTrace {
  final StackTrace _trace;
  String? fileName;
  String? functionName;
  String? callerFunctionName;
  int? lineNumber;
  int? columnNumber;

  CustomTrace(StackTrace stackTrace): _trace = stackTrace {
    _parseTrace();
  }

  String _getFunctionNameFromFrame(String frame) {
    var currentTrace = frame;
    var indexOfWhiteSpace = currentTrace.indexOf(' ');
    var subStr = currentTrace.substring(indexOfWhiteSpace);
    var indexOfFunction = subStr.indexOf(RegExp(r'[A-Za-z0-9$]'));

    subStr = subStr.substring(indexOfFunction);
    indexOfWhiteSpace = subStr.indexOf(' ');
    subStr = subStr.substring(0, indexOfWhiteSpace);

    return subStr;
  }

  void _parseTrace() {
    /* The trace comes with multiple lines of strings, (each line is also known as a frame) */
    var frames = _trace.toString().split('\n');
    functionName = _getFunctionNameFromFrame(frames[0]);
    callerFunctionName = _getFunctionNameFromFrame(frames[1]);

    var traceString = frames[0];
    var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z]+.dart'));

    var fileInfo = traceString.substring(indexOfFileName);
    var listOfInfos = fileInfo.split(':');
    fileName = listOfInfos[0];
    lineNumber = int.parse(listOfInfos[1]);
    var columnStr = listOfInfos[2];
    columnStr = columnStr.replaceFirst(')', '');
    columnNumber = int.parse(columnStr);
  }
}