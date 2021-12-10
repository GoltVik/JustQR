import 'package:flutter/material.dart';
import 'package:just_qr/just_qr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late final JustScannerController _controller;

  MyApp({Key? key}) : super(key: key) {
    _controller = JustScannerController(onScanResult: (code) {
      _codeNotifier.value = code;
    });
  }

  final ValueNotifier<String> _codeNotifier = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 400,
                      child: JustQrScanWidget(
                        controller: _controller,
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _codeNotifier,
                      builder: (context, value, _) => Text(value),
                    ),
                  ],
                ),
              ),
            ),
            Wrap(
              children: [
                TextButton(
                    onPressed: _controller.startCamera,
                    child: const Text('startCamera')),
                TextButton(
                    onPressed: _controller.startCameraPreview,
                    child: const Text('startCameraPreview')),
                TextButton(
                    onPressed: _controller.stopCameraPreview,
                    child: const Text('stopCameraPreview')),
                TextButton(
                    onPressed: _controller.stopCamera,
                    child: const Text('stopCamera')),
                TextButton(
                    onPressed: _controller.turnOnFlash,
                    child: const Text('turnOnFlash')),
                TextButton(
                    onPressed: _controller.turnOffFlash,
                    child: const Text('turnOffFlash')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
