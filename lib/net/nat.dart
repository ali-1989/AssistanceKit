//library nat_info;

import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'dart:async';
import 'dart:math';

class NAT {
  NAT._();

  static Future<NATInfo> getNATInfo() async {
    const stun_servers = [
      '216.58.203.222',
      '172.217.27.190',
      '216.58.197.94',
      '74.125.200.127'
    ];
    //defined packet as per RFC5389
    var packet = hex.decode('000100002112A442000000100010111111111111');
    //set up udp sockets
    var sockets = <RawDatagramSocket>[];
    var startPort = 44444;
    var results = <Uint8List?>[];

    for (var i = 0; i < stun_servers.length; i++) {
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, startPort + i).then((RawDatagramSocket socket) {

        socket.send(packet, InternetAddress(stun_servers[i]), 19302);

        socket.listen((RawSocketEvent e) {
          sockets.add(socket);

          if (e == RawSocketEvent.read) {
            var reply = socket.receive();

            results.add(reply?.data);
          }
        }).onError((error) {});
      });
    }

    await Future.delayed((const Duration(seconds: 1)));

    for (var i = 0; i < sockets.length; i++) {
      sockets[i].close();
    }

    return NATInfo(results);
  }
}
///=============================================================================
class NATInfo {
  String? natMapping;
  double mappingCertainty = 0;
  InternetAddress? publicAddress;
  bool connected = false;

  NATInfo(List<Uint8List?> data) {
    var nullCount = 0;
    var directMapped = 0;
    var randomMapped = 0;
    connected = true;

    var startPort = 44444;

    for (var i = 0; i < data.length; i++) {
      if (data[i] == null) {
        nullCount++;
      }
      else {
        publicAddress ??= _extractAddress(data[i]!);

        if (_extractPort(data[i]!) == startPort + i) {
          directMapped++;
        }
        else {
          randomMapped++;
        }
      }
    }

    if (nullCount == data.length) {
      connected = false;
    }
    else {
      if (directMapped == data.length || randomMapped == data.length) {
        mappingCertainty = 1;
      }
      else if (directMapped == randomMapped) {
        mappingCertainty = 0.5;
      }
      else {
        mappingCertainty =
            max(directMapped, randomMapped) / (directMapped + randomMapped);
      }

      if (directMapped >= randomMapped) {
        natMapping = 'Direct';
      }
      else {
        natMapping = 'Random';
      }
    }
  }

  @override
  String toString() =>
      'connected:$connected\npublic IP:$publicAddress\nNAT mapping:$natMapping\nNAT mapping certainty:$mappingCertainty';

  int _extractPort(List<int> packet) {
    var magic = hex.decode('2112');
    var port = <int>[];

    for (var i = 26; i < 28; i++) {
      port.add(packet[i] ^ magic[i - 26]);
    }

    var portNumber = port[0] << 8;
    portNumber += port[1];

    return portNumber;
  }

  InternetAddress _extractAddress(List<int> packet) {
    var magic = hex.decode('2112A442'); //magic number as per RFC5389
    //packet length is 32 bytes, last 4 bytes contain the ipv4 address.
    //Extracting the XOR-Mapped address
    var address = <int>[];

    for (var i = 28; i < 32; i++) {
      address.add(packet[i] ^ magic[i - 28]);
    }

    var addressString = '';

    for (var j = 0; j < 4; j++) {
      addressString += address[j].toString();

      if (j != 3) {
        addressString += '.';
      }
    }

    return InternetAddress(addressString);
  }
}