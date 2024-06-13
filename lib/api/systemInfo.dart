import 'dart:io';
import 'package:assistance_kit/api/helpers/mathHelper.dart';
import 'package:assistance_kit/shell_assistance.dart';

class SystemInfo {
  String kernel_name = '';    // Linux
  String kernel_version = ''; // 5.4.0-29-generic
  String os_name = '';        // Ubuntu
  String os_version = '';     // 20.04
  Map<String, String> os_release = <String, String>{};

  SystemInfo() {
    final version = File('/proc/version').readAsStringSync();
    final os = File('/etc/os-release').readAsLinesSync();
    final vSplit = version.split(' ');

    kernel_name = vSplit[0];
    kernel_version = vSplit[2];
    os_release = <String, String>{};

    for (final e in os) {
      final data = e.split('=');
      os_release[data[0]] = data[1].replaceAll('\"', '');
    }

    os_name = os_release['NAME'] ?? '';
    os_version = os_release['VERSION_ID'] ?? '';
  }
}
///==================================================================================
class CpuModel {
  int processor = 0;
  String vendor_id = '';
  int cpu_family = -1;
  int model = -1;
  String model_name = '';
  int stepping = -1;
  int microcode = -1;
  double cpu_mhz = -1.0;
  String cache_size = '';
  int physical_id = -1;
  int siblings = -1;
  int core_id = -1;
  int cpu_cores = -1;
  int apicid = -1;
  int initial_apicid = -1;
  bool fpu = false;
  bool fpu_exception = false;
  int cpuid_level = -1;
  bool wp = false;
  List<String> flags = [];
  double bogomips = -1.0;
  int clflush_size = -1;
  int cache_alignment = -1;
  MapEntry<String, String> address_sizes = MapEntry<String, String>('', '');

  CpuModel.fromData(
      this.processor,
      this.vendor_id,
      this.cpu_family,
      this.model,
      this.model_name,
      this.stepping,
      this.microcode,
      this.cpu_mhz,
      this.cache_size,
      this.physical_id,
      this.siblings,
      this.core_id,
      this.cpu_cores,
      this.apicid,
      this.initial_apicid,
      this.fpu,
      this.fpu_exception,
      this.cpuid_level,
      this.wp,
      this.flags,
      this.bogomips,
      this.clflush_size,
      this.cache_alignment,
      this.address_sizes);

  CpuModel();

  List<int> load() {
    var f = File('/proc/stat');
    var lines = f.readAsLinesSync();
    var loads = lines[processor + 1].split(' ');

    loads.removeAt(0);

    var total = loads
        .map((String token) => int.parse(token))
        .toList()
        .reduce((int a, int b) => a + b);

    var idle = int.parse(loads[3]);

    return [idle, total];
  }

  Stream<double> getCpuUsagePercentagePerSecond() async* {
    var idleTotalPrev = <int>[0, 0];

    while (true) {
      var idleTotal = load();
      var dTotal = idleTotal[0] - idleTotalPrev[0];
      var dLoad = idleTotal[1] - idleTotalPrev[1];
      idleTotalPrev = idleTotal;

      var percent = 100.0 * (1.0 - dTotal / dLoad);
      yield percent;

      sleep(Duration(seconds: 1));
    }
  }

  Future<double> getCpuUsagePercentage() async {
    final idleTotal = load();
    final dTotal = idleTotal[0];
    final dLoad = idleTotal[1];

    return 100.0 * (1.0 - dTotal / dLoad);
  }
}
///==================================================================================
class CpuInfo {

  static List<CpuModel> getProcessors() {
    var cpus = <CpuModel>[];
    var curCpu = 0;
    var currentCpu = CpuModel();
    var lines = File('/proc/cpuinfo').readAsLinesSync();

    for (final l in lines) {
      final data = l.split(':');

      if (data.isNotEmpty) {
        data[0] = data[0].trim();

        if (data[0] == 'processor' && curCpu > 0) {
          cpus.add(currentCpu);
          currentCpu = CpuModel();
          currentCpu.processor = int.parse(data[1]);
          curCpu += 1;
        }

        switch (data[0]) {
          case 'vendor_id':
            currentCpu.vendor_id = data[1];
            break;
          case 'cpu family':
            currentCpu.cpu_family = int.parse(data[1]);
            break;
          case 'model':
            currentCpu.model = int.parse(data[1]);
            break;
          case 'model name':
            currentCpu.model_name = data[1];
            break;
          case 'stepping':
            currentCpu.stepping = int.parse(data[1]);
            break;
          case 'microcode':
            currentCpu.microcode = int.parse(data[1]);
            break;
          case 'cpu MHz':
            currentCpu.cpu_mhz = double.parse(data[1]);
            break;
          case 'cache size':
            currentCpu.cache_size = data[1];
            break;
          case 'physical id':
            currentCpu.physical_id = int.parse(data[1]);
            break;
          case 'siblings':
            currentCpu.siblings = int.parse(data[1]);
            break;
          case 'core id':
            currentCpu.core_id = int.parse(data[1]);
            break;
          case 'cpu cores':
            currentCpu.cpu_cores = int.parse(data[1]);
            break;
          case 'apicid':
            currentCpu.apicid = int.parse(data[1]);
            break;
          case 'initial apicid':
            currentCpu.initial_apicid = int.parse(data[1]);
            break;
          case 'fpu':
            currentCpu.fpu = data[1] == 'yes' ? true : false;
            break;
          case 'fpu_exception':
            currentCpu.fpu_exception = data[1] == 'yes' ? true : false;
            break;
          case 'cpuid level':
            currentCpu.cpuid_level = int.parse(data[1]);
            break;
          case 'wp':
            currentCpu.wp = data[1] == 'yes' ? true : false;
            break;
          case 'flags':
            currentCpu.flags = data[1].split(' ');
            break;
          case 'bogomips':
            currentCpu.bogomips = double.parse(data[1]);
            break;
          case 'clflush size':
            currentCpu.clflush_size = int.parse(data[1]);
            break;
          case 'cache_alignment':
            currentCpu.cache_alignment = int.parse(data[1]);
            break;
          case 'address sizes':
            currentCpu.address_sizes = MapEntry(data[1].split(',')[0], data[1].split(',')[1]);
            break;
        }

        if (curCpu == 0) {
          curCpu += 1;
        }
      }
    }

    return cpus;
  }

  static Future<List<ThreadModel>> getThreads() async {
    final out = await ShellAssistance.shell('ps', ['-eo', '%cpu,pid,user,args']);
    final data = out.stdout.toString();

    final res = <ThreadModel>[];
    final sp = data.split('\n');

    for(final i in sp){
      final sp2 = i.trim().split(RegExp(' +'));
      final itm = ThreadModel();

      if(sp2.length > 2){
        itm.cpu = MathHelper.clearToDouble(sp2[0]);
        itm.pId = MathHelper.clearToInt(sp2[1]);
        itm.user = sp2[2];

        if(sp2.length > 3){
          itm.cmd = sp2.getRange(3, sp2.length).join(' ');
        }

        res.add(itm);
      }
    }

    return res;
  }
}
///==================================================================================
class ThreadModel {
  double cpu = 0.0;
  int pId = 0;
  String user = '';
  String cmd = '';
}
///==================================================================================
class MemInfo {
  int mem_total = 0;
  int mem_total_mb = 0;
  int mem_total_gb = 0;
  int mem_free = 0;
  int mem_free_mb = 0;
  int mem_free_gb = 0;
  int swap_total = 0;
  int swap_total_mb = 0;
  int swap_total_gb = 0;
  int swap_free = 0;
  int swap_free_mb = 0;
  int swap_free_gb = 0;

  MemInfo() {
    final lines = File('/proc/meminfo').readAsLinesSync();

    for (final e in lines) {
      final data = e.split(':');

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




/*

  static List<int> load() {
    var f = File('/proc/stat');
    var lines = f.readAsLinesSync();

    var loads = lines[0]
        .substring('cpu  '.length)
        .split(' ')
        .map((String token) => int.parse(token))
        .toList();

    var idle = loads[3];
    var total = loads.reduce((int a, int b) => a + b);

    return [idle, total];
  }

  static Future<double> getCpuUsagePercentage() async {
    //final idleTotalPrev = <int>[0, 0];

    var idleTotal = load();
    var dTotal = idleTotal[0] - 0;
    var dLoad = idleTotal[1] - 0;
    //idleTotalPrev = idleTotal;

    var percent = 100.0 * (1.0 - dTotal / dLoad);
    return percent;
  }
 */