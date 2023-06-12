import 'package:flutter/rendering.dart';
import 'package:glove_hero_app/utils/styles.dart';
import '../models/ble.dart';

abstract class PainterBase extends CustomPainter {
  final paintStroke = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;
  final paintFill = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.fill;

  void paintInputCircles(
    Canvas canvas,
    Size size, {
    Input activeInput = Input.none,
  }) {
    final radius = size.width / 10;

    for (final input in Input.values) {
      if (input == Input.none) continue;

      final index = inputCircleIndex(input)!;
      final paint = (activeInput == input ? paintFill : paintStroke)
        ..color = inputColors[input]!;
      final center =
          Offset(size.width / 8 * (2 * index + 1), size.height - radius * 2);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  int? inputCircleIndex(Input input) {
    return switch (input) {
      Input.input1 => 0,
      Input.input2 => 1,
      Input.input3 => 2,
      Input.input4 => 3,
      Input.none => null,
    };
  }
}
