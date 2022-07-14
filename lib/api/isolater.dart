import 'dart:isolate';

/// accepted types: (null, num, int, double, bool, String, List<dynamic>, Map<dynamic, dynamic>, Uint8List And SendPort)

/// ** isolate not improve speed (is slower than main), only free Ui thread.


class Isolater {
  Isolater._();
  ///--------------------------------------------------------------------------------------------------------
  static void _isolateEntry(dynamic sendData) async {
    final receivePort = ReceivePort();

    Map<String, dynamic> firstPack = sendData;
    Function fn = firstPack['staticFn'];
    SendPort fnOwn = firstPack['sendPort'];
    dynamic fnParam = firstPack['fnParam'];

    fnOwn.send(receivePort.sendPort);
    fn.call(fnOwn, receivePort.sendPort, fnParam);
  }

  static Future<Isolate> runIsolate(ReceivePort receivePort, void Function(SendPort fnOwn, SendPort isoOwn, dynamic param) staticFn,
      dynamic fnParam) async {
     var map = <String, dynamic>{'sendPort': receivePort.sendPort, 'staticFn' : staticFn, 'fnParam' : fnParam};
     var isolate = await Isolate.spawn(_isolateEntry, map);

     return isolate;
  }
  ///--------------------------------------------------------------------------------------------------------
  /// fn Method must declare outside of a class or be a static
  /*static Future<R> computeIsolate<M, R>(R fn(M message), M message) async{
    return compute<M, R>(fn, message);
  }*/
}

/*
  Sample:

  void iso_brightness(SendPort fnOwn, SendPort isoOwn, dynamic param) {
    img.Image xx = img.decodeImage(param);
    xx = ImageHelper.brightness(xx, 150);
    fnOwn.send(img.encodeNamedImage(xx, 'x.jpeg'));
  }
    ...............................................................................
  Isolate iso;
  ReceivePort receivePort = ReceivePort();

  receivePort.listen((message) async {
    SendPort sendToIso;

    if(message is SendPort){
      sendToIso = message;
      return;
    }

    //state.editOptions.imageBytes = Uint8List.fromList(ImageHelper.imageToJpg(xx, 100));
    state.editOptions.imageBytes = Uint8List.fromList(message);
    state.editOptions._image = await PicEditorState.bytesToImage(state.editOptions.imageBytes);

    state.brightnessValue = 0;
    state.progressController.setWidgetValue(false);
    state.update();

    iso.kill();
  });

  iso = await Isolater.runIsolate(receivePort, iso_brightness, state.editOptions.imageBytes);
 */