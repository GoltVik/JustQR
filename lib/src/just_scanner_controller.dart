import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class JustScannerController {
  late final MethodChannel _channel;
  final ValueSetter<String>? onScanResult;

  JustScannerController({this.onScanResult});

  void initWithId(int viewId) {
    _channel = MethodChannel(
      Just.channelName + '$viewId',
      const StandardMethodCodec(),
    )..setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'codeFound') {
      onScanResult?.call(call.arguments as String);
    }
  }

  Future<T?> _call<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  Future<void> startCamera() => _call<void>('startCamera');

  void startCameraPreview() => _call<void>('resumeCameraPreview');

  void stopCameraPreview() => _call<void>('stopCameraPreview');

  void stopCamera() => _call<void>('stoptCamera');

  void turnOnFlash() => _call<void>('openFlash');

  void turnOffFlash() => _call<void>('closeFlash');
}
