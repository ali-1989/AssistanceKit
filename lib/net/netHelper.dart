import 'dart:convert';
import 'dart:io';
import 'package:assistance_kit/api/helpers/textHelper.dart';
import 'package:assistance_kit/shellAssistance.dart';
import 'package:assistance_kit/api/system.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class NetHelper {
  NetHelper._();

  static Future<List<Map<String, String>>> getIps() async {
    // type.name: [IPv4/IPv6]
    var res = <Map<String, String>>[];

    for (var interface in await NetworkInterface.list()) {
      var itm = <String, String>{};
      itm['name'] = interface.name;
      itm['address'] = interface.addresses.first.address;

      res.add(itm);
    }

    return res;
  }

  static Future<InternetAddress> retrieveIPAddress() async {
    int code = Random().nextInt(255);
    final dgSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    dgSocket.readEventsEnabled = true;
    dgSocket.broadcastEnabled = true;

    Future<InternetAddress> ret = dgSocket.timeout(const Duration(milliseconds: 100), onTimeout: (sink) {
      sink.close();
    }).expand<InternetAddress>((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = dgSocket.receive();

        if (dg != null && dg.data.length == 1 && dg.data[0] == code) {
          dgSocket.close();
          return [dg.address];
        }
      }
      return [];
    }).firstWhere((InternetAddress? a) => a != null);

    dgSocket.send([code], InternetAddress('255.255.255.255'), dgSocket.port);
    return ret;
  }
  
  static Future<GeolocationData?> getRouterIpData({String query = ''}) async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/$query'));

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return GeolocationData.fromJson(parsed);
      }

      return null;
    }
    catch (e) {
      return null;
    }
  }

  static Future<String> getGateway() async{
    if(System.isWindows()) {
      return ShellAssistance.shell('ipconfig', [], runInShell: true).then((process) {
        var text = process.stdout as String;
        var lines = text.split(RegExp(r'\n'));

        for (var line in lines) {
          if (line.indexOf(RegExp(r'Default Gateway')) > 0) {
            var start = line.indexOf(RegExp(r'((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|\b|$)){4}'));

            if (start > -1) {
             return TextHelper.removeNonViewableFull(line.substring(start));
            }
          }
        }

        return '';
      });
    }
    else {
      return ShellAssistance.shell('ip', ['route'], runInShell: true).then((process) {
        var text = process.stdout as String;
        var lines = text.split(RegExp(r'\n'));

        for (var line in lines) {
          if (line.contains(RegExp(r'default via', multiLine: false, caseSensitive: false))) {
            var start = line.indexOf(RegExp(r'((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|\b|$)){4}'));

            if (start > -1) {
              return TextHelper.removeNonViewableFull(line.substring(start));
            }
          }
        }

        return '';
      });
    }
  }

 /* static Future<String> findCountryWithIP() async {
    var res = await findCountryWithIP1();
    res ??= await findCountryWithIP2();
    res ??= await findCountryWithIP3();
    res ??= await findCountryWithIP4();

    return res?? 'US';
  }

  static Future<String?> findCountryWithIP1() async {
    const url = 'https://api.country.is';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) async {
      if(res.isOk){
        return res.getBodyAsJson()!['country'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<String?> findCountryWithIP2() async {
    const url = 'http://ip-api.com/json';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) {
      if(res.isOk){
        return res.getBodyAsJson()!['countryCode'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<String?> findCountryWithIP3() async {
    const url = 'https://api.db-ip.com/v2/free/self';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) {
      if(res.isOk){
        return res.getBodyAsJson()!['countryCode'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }

  static Future<String?> findCountryWithIP4() async {
    const url = 'https://hutils.loxal.net/whois';

    HttpItem http = HttpItem(fullUrl: url);
    http.method = 'GET';

    final res = AppHttpDio.send(http);

    return res.response.then((value) {
      if(res.isOk){
        return res.getBodyAsJson()!['countryIso'] as String;
      }

      return null;
    })
        .onError((error, stackTrace) => null);
  }*/
}
///=============================================================================
class GeolocationData {
  final String country, countryCode, timezone, ip;
  final double lat, lon;

  GeolocationData(
      {required this.country,
        required this.countryCode,
        required this.timezone,
        required this.ip,
        required this.lat,
        required this.lon,
      });

  factory GeolocationData.fromJson(Map<String, dynamic> json) {
    return GeolocationData(
        country: json['country'],
        countryCode: json['countryCode'],
        timezone: json['timezone'],
        ip: json['query'],
        lat: json['lat'],
        lon: json['lon']);
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'countryCode': countryCode,
      'timezone': timezone,
      'ip': ip,
      'lat': lat,
      'lon': lon
    };
  }
}