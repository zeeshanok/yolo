import 'dart:ui';

class Prediction {
  final String name;

  // top left and bottom right corners of the bounding box of the
  // predicted object
  final Offset p1, p2;

  Prediction({
    required this.name,
    required this.p1,
    required this.p2,
  });

  factory Prediction.fromMap(Map map) {
    final c = map['coords'];
    return Prediction(
      name: map['name'],
      p1: Offset(c[0].toDouble(), c[1].toDouble()),
      p2: Offset(c[2].toDouble(), c[3].toDouble()),
    );
  }
}
