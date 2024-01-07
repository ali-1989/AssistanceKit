import 'dart:io';

class HttpOverrideProxy extends HttpOverrides {
  String _port;
  String _host;
  HttpOverrideProxy(this._host, this._port);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY $_host:$_port;";
      };
  }
}
