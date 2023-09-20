import 'package:flutter/material.dart';
import 'package:yolo_frontend/prediction.dart';

class BoxDrawer extends StatelessWidget {
  const BoxDrawer(
      {super.key, required this.predictions, required this.resolution});

  final List<Prediction> predictions;
  final Size resolution;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        painter: BoxPainter(predictions, resolution),
        size: constraints.biggest,
      );
    });
  }
}

class BoxPainter extends CustomPainter {
  final List<Prediction> predictions;
  final Size resolution;

  BoxPainter(this.predictions, this.resolution);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    final paint2 = Paint()..color = Colors.red;

    final ratio = size.width / resolution.width;

    for (final p in predictions) {
      final p1 = p.p1 * ratio;
      final p2 = p.p2 * ratio;
      final r = Rect.fromPoints(p1, p2);
      canvas.drawRect(r, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: p.name,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width - p1.dx);
      canvas.drawRect(
        Rect.fromLTWH(
            p1.dx, p1.dy, textPainter.width + 4, textPainter.height + 3),
        paint2,
      );
      textPainter.paint(canvas, p1 + Offset(2, 0));
    }
  }

  @override
  bool shouldRepaint(BoxPainter old) {
    return true;
  }
}
