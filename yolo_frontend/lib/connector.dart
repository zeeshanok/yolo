import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yolo_frontend/prediction.dart';

Future<(Size resolution, List<Prediction> predictions)> sendPic(XFile img,
    WebSocketChannel channel, Stream<dynamic> websocketStream) async {
  channel.sink.add('${kIsWeb ? '' : 'r'}sending');

  await websocketStream.firstWhere((data) => data == 'ready');
  debugPrint("sending image");
  channel.sink.add(await img.readAsBytes());

  debugPrint("waiting for result");
  final result = (await websocketStream
          .firstWhere((data) => data.startsWith('result ')) as String)
      .substring('result '.length);

  final d = const JsonDecoder().convert(result);

  final res =
      Size(d['resolution'][0].toDouble(), d['resolution'][1].toDouble());

  final predictions =
      (d['predictions'] as List).map((e) => Prediction.fromMap(e)).toList();
  debugPrint("done");

  return (res, predictions);
}
