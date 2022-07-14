import 'dart:async';
import 'package:assistance_kit/api/logger/logger.dart';

/// src: https://levelup.gitconnected.com/speed-up-dart-flutter-with-futures-streams-and-streamtransformers-77ff5a20daa3
/// https://gist.github.com/mmdk95/725a13db8f93934984e8b0e47caa6243

class AsyncTransformer<S, T> extends StreamTransformerBase<S, T> {
  late final StreamController<T> _streamController;
  final FutureOr<T> Function(S event) _asyncCB;
  final int _parallelMax;
  int _futureCount;
  bool _finalizing;
  late StreamSubscription _subscription;
  void Function()? _resumeCallback;


  AsyncTransformer(this._asyncCB, { int parallel = 5 }):
        _parallelMax = parallel,
        _futureCount = 0,
        _finalizing = false,
        _streamController = StreamController();

  @override
  Stream<T> bind(Stream<S> stream) {
    _subscription = stream.listen(_onData);

    _streamController.onCancel = _onCancel;
    _streamController.onResume = _subscription.resume;
    _streamController.onPause = _subscription.pause;

    _subscription.onDone(() {
      _finalizing = true;

      if (_futureCount <= 0) {
        // if we are not waiting for futures,
        // close the stream controller.
        _streamController.close();
      }
    });

    // return the stream from our internal stream controller
    return _streamController.stream;
  }


  void _onData(S data) {
    // execute our callback with the data we got
    var futureOrValue = _asyncCB(data);

    // check if it returned a future, or a value
    if (!(futureOrValue is Future)) {
      // if it does not return a future
      // we will immediately add it to the stream
      _streamController.add(futureOrValue);
      return;
    }

    _futureCount++;

    (futureOrValue as Future<T>).then(_onFutureResult);

    if (_futureCount >= _parallelMax) {
      if (_resumeCallback != null) {
        return;
      }

      var c = Completer();
      _resumeCallback = c.complete;
      _subscription.pause(c.future);
    }
  }

  void _onFutureResult(T value) {
    _futureCount--;
    _streamController.add(value);

    if (_futureCount < _parallelMax && _resumeCallback != null) {
      _resumeCallback!.call();
    }

    if (_finalizing && _futureCount <= 0) {
      _streamController.close();
    }
  }

  void _onCancel() {
    //old: assert(_subscription != null, '_onCancel called before subscription was bound');
    _subscription.cancel();
    _finalizing = true;
  }
}
///=====================================================================================================
///  ##### sample use:

class DownloadHolder {
  final String name;
  final int waitTime;
  bool success = true;
  DownloadHolder(this.name, this.waitTime);
}

Future<DownloadHolder> downloadSimulate(DownloadHolder asset) async {
  await Future.delayed(Duration(milliseconds: asset.waitTime));
  Logger.L.logToScreen('Downloaded and saved ${asset.name}');
  return asset;
}

Future<void> downloadWithParallelStreams() async {

  var assets = <DownloadHolder>[
    DownloadHolder('Big file', 100),
    DownloadHolder('Small file', 20),
    DownloadHolder('Medium file ', 50),
  ];

  var successCount = 0;
  var streamController = StreamController<DownloadHolder>();

  for (var asset in assets) {
    streamController.add(asset);
  }

  var mStream = streamController.stream;
  mStream = mStream.transform(AsyncTransformer(downloadSimulate, parallel: 2));

  // Make sure to close our stream with
  mStream = mStream.map((downItem) {
    if (downItem.success) {
      successCount++;
    }

    if (successCount == assets.length) {
      streamController.close();
    }

    return downItem;
  });

  mStream = mStream.skipWhile((downItem) => downItem.success);

  // listen for our stream,
  // all failed downloads added back into the stream
  var subScrip = mStream.listen((downItem) => streamController.add(downItem));

  subScrip.pause(Future.sync(() => {
    // You can pause like this and wait for a future to complete
    // Future.sync, returns next tick (almost immediately)
    // but you can also wait until you get internet back for example
  }));

  await subScrip.asFuture();
}