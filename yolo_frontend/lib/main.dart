import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yolo_frontend/box_drawer.dart';
import 'package:yolo_frontend/connector.dart';
import 'package:yolo_frontend/prediction.dart';

Future<void> main() async {
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatelessWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;

  late WebSocketChannel _channel;

  final StreamController<dynamic> _streamController =
      StreamController.broadcast();

  bool isReady = false, isPaused = false;

  // list of predictions the server made
  List<Prediction> _predictions = [];

  // image resolution
  Size _resolution = Size.zero;

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) async {
      controller = CameraController(
        value[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );
      try {
        await controller.initialize();
        if (!mounted) {
          return;
        }
        connectWebSocket();

        setState(() {
          isReady = true;
        });

        Future.doWhile(() async {
          await Future.wait([
            Future.delayed(const Duration(seconds: 1)),
            predictCameraImage(),
          ]);
          return true;
        });
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint("denied");
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  Future<void> predictCameraImage() async {
    if (isPaused) return;
    try {
      final pic = await controller.takePicture();

      final predictions = await sendPic(
        pic,
        _channel,
        _streamController.stream,
      );
      setState(() {
        _resolution = predictions.$1;
        _predictions = predictions.$2;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: isReady
              ? Stack(
                  alignment: Alignment.center,
                  // fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    Positioned.fill(
                        child: BoxDrawer(
                      predictions: _predictions,
                      resolution: _resolution,
                    )),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                isPaused = !isPaused;
                                if (isPaused) {
                                  controller.pausePreview();
                                } else {
                                  controller.resumePreview();
                                }
                              }),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                height: 80,
                                width: 80,
                                child: Icon(
                                  isPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  size: 50,
                                ),
                              ),
                            )
                          ]),
                        ),
                      ),
                    ),
                  ],
                )
              : const Text(
                  "Loading",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.add(status.goingAway);
    _channel.sink.close();
    super.dispose();
  }

  void connectWebSocket() async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8000'));
    _channel.stream.listen((event) {
      // this is one way to listen to the websocket stream multiple times
      _streamController.sink.add(event);
    });
  }
}
