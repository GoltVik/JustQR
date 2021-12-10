import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/constants.dart';

dynamic _jsQR(d, w, h, o) {
  return js.context.callMethod('jsQR', [d, w, h, o]);
}

/// A web implementation of the JustQrWeb plugin.
class JustQrWeb {
  static void registerWith(Registrar registrar) {
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      Just.nativeName,
      (int viewId) => JustQrWeb(viewId, registrar).videoElement,
    );
  }

  final html.VideoElement videoElement;
  late final MethodChannel _channel;
  bool isScannActive = false;

  JustQrWeb(int viewId, Registrar registrar)
      : videoElement = html.VideoElement()
          ..id = 'webcamVideoElement$viewId'
          ..autoplay = true {
    _initMethodCallHandler(viewId, registrar);
  }

  void _initMethodCallHandler(int viewId, Registrar registrar) {
    _channel = MethodChannel(
      Just.channelName + '$viewId',
      const StandardMethodCodec(),
      registrar,
    )..setMethodCallHandler(handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "startCamera":
        return _startCamera();
      case "resumeCameraPreview":
        return _startCameraPreview();
      case "stopCameraPreview":
        return stopCameraPreview();
      case "stoptCamera":
        return stopCamera();
      case "openFlash":
        return _openFlash();
      case "closeFlash":
        return _closeFlash();
      default:
        throw UnimplementedError();
    }
  }

  ///region MethodCallHandler
  void _startCamera() async {
    final initFuture = () {
      try {
        return html.window.navigator.mediaDevices?.getUserMedia({
          'video': {
            'facingMode': 'environment',
            'width': {'exact': 720},
            'height': {'exact': 720},
          }
        });
      } catch (e) {
        debugPrint(e.toString());
      }

      try {
        return html.window.navigator.getUserMedia(video: {
          'facingMode': 'environment',
        });
      } catch (e) {
        debugPrint(e.toString());
      }

      return null;
    }();

    // Access the webcam stream
    if (initFuture != null) {
      html.MediaStream stream = await initFuture;

      videoElement
        ..srcObject = stream
        ..setAttribute('playsinline', 'true');
    }
  }

  void _startCameraPreview() async {
    videoElement.play();
    isScannActive = true;
    _startCodeSearching();
  }

  void _startCodeSearching() async {
    while (videoElement.readyState != 4) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    var _canvasElement = html.CanvasElement();
    final _canvas =
        _canvasElement.getContext("2d") as html.CanvasRenderingContext2D?;

    while (isScannActive) {
      _canvasElement
        ..width = videoElement.videoWidth
        ..height = videoElement.videoHeight;

      _canvas?.drawImage(videoElement, 0, 0);

      var imageData = _canvas?.getImageData(
          0, 0, _canvasElement.width ?? 0, _canvasElement.height ?? 0);

      if (imageData is html.ImageData) {
        js.JsObject? code = _jsQR(
          imageData.data,
          imageData.width,
          imageData.height,
          {'inversionAttempts': 'dontInvert'},
        );
        if (code != null) {
          _channel.invokeMethod('codeFound', code['data']);
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void stopCameraPreview() {
    isScannActive = false;
    videoElement.pause();
  }

  void stopCamera() {
    isScannActive = false;
    videoElement.srcObject!.getTracks().forEach((e) => e.stop());
  }

  void _openFlash() {
    videoElement.srcObject!.getTracks().forEach((e) {
      if (e.getCapabilities().containsKey('torch')) {
        e.applyConstraints({
          'advanced': {'torch': true}
        });
      }
    });
  }

  void _closeFlash() {
    videoElement.srcObject!.getTracks().forEach((e) {
      if (e.getCapabilities().containsKey('torch')) {
        e.applyConstraints({
          'advanced': {'torch': false}
        });
      }
    });
  }

  ///endregion
}
