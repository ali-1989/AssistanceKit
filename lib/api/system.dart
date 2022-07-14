import 'dart:io' show File, Platform;

class System {
  System._();

  static int currentTimeMillis(){
    return DateTime.now().millisecondsSinceEpoch;
  }

  static int currentTimeMillisUtc(){
    var now = DateTime.now();
    var offset = now.timeZoneOffset.inMilliseconds;
    return now.millisecondsSinceEpoch - offset;
  }

  static bool isDesktop(){
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isLinux(){
    return Platform.isLinux;
  }

  static bool isWindows(){
    return Platform.isWindows;
  }

  static bool isMac(){
    return Platform.isMacOS;
  }

  static bool isAndroid(){
    return Platform.isAndroid;
  }

  static Future wait(Duration dur) {
    return Future.delayed(dur, (){});
  }

  static Future waitThen(Duration dur, void Function() fn) {
    return Future.delayed(dur, fn);
    //Timer(dur, fn);
  }
}
//======================================================================================================
class MemoryInfo {
  static int mem_total = 0;
  static int mem_total_mb = 0;
  static int mem_total_gb = 0;
  static int mem_free = 0;
  static int mem_free_mb = 0;
  static int mem_free_gb = 0;
  static int swap_total = 0;
  static int swap_total_mb = 0;
  static int swap_total_gb = 0;
  static int swap_free = 0;
  static int swap_free_mb = 0;
  static int swap_free_gb = 0;

  static void initial() {
    var lines = File('/proc/meminfo').readAsLinesSync();

    for (var e in lines) {
      var data = e.split(':');

      if (data.length == 2) {
        data[0] = data[0].trim();
        switch (data[0]) {
          case 'MemTotal':
            {
              data[1] = data[1].trim().substring(0, data[1].trim().length - 3);
              mem_total = int.parse(data[1]);
              mem_total_mb = (mem_total / 1024).round();
              mem_total_gb = (mem_total_mb / 1024).round();
            }
            break;
          case 'MemFree':
            {
              data[1] = data[1].trim().substring(0, data[1].trim().length - 3);
              mem_free = int.parse(data[1]);
              mem_free_mb = (mem_free / 1024).round();
              mem_free_gb = (mem_free_mb / 1024).round();
            }
            break;
          case 'SwapTotal':
            {
              data[1] = data[1].trim().substring(0, data[1].trim().length - 3);
              swap_total = int.parse(data[1]);
              swap_total_mb = (swap_total / 1024).round();
              swap_total_gb = (swap_total_mb / 1024).round();
            }
            break;
          case 'SwapFree':
            {
              data[1] = data[1].trim().substring(0, data[1].trim().length - 3);
              swap_free = int.parse(data[1]);
              swap_free_mb = (swap_free / 1024).round();
              swap_free_gb = (swap_free_mb / 1024).round();
            }
            break;
        }
      }
    }
  }
}