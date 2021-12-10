import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../just_qr.dart';
import 'constants.dart';
import 'native/just_view_controller.dart';

class JustQrScanWidget extends StatelessWidget {
  final JustScannerController _controller;

  JustQrScanWidget({
    Key? key,
    JustScannerController? controller,
  })  : _controller = controller ?? JustScannerController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return PlatformViewLink(
        key: key,
        viewType: Just.nativeName,
        onCreatePlatformView: (PlatformViewCreationParams params) {
          _controller.initWithId(params.id);

          final htmlController = JustViewController(params.id, Just.nativeName);
          htmlController.initialize().then((_) async {
            params.onPlatformViewCreated(params.id);
            await _controller.startCamera();
            _controller.startCameraPreview();
          });
          return htmlController;
        },
        surfaceFactory: (context, controller) {
          return PlatformViewSurface(
            controller: controller,
            gestureRecognizers: const {},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
      );
    } else {
      throw UnsupportedError("Unsupported platform view");
    }
  }
}
