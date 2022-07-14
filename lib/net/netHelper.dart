import 'dart:convert';
import 'dart:io';
import 'package:assistance_kit/api/helpers/textHelper.dart';
import 'package:assistance_kit/shellAssistance.dart';
import 'package:assistance_kit/api/system.dart';
import 'package:http/http.dart' as http;

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
}
///======================================================================================================
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