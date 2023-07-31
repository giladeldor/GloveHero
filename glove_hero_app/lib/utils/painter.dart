import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:glove_hero_app/utils/styles.dart';
import '../models/ble.dart';
import '../models/touch.dart';

/// A base class for painters that draw the touches on the screen.
/// This allows the painters for the single-player and recording modes to share
/// the logic for drawing touches.
abstract class PainterBase extends CustomPainter {
  final _paintStroke = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;
  final _paintFill = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.fill;

  double _radius(Size size) => size.width / 10;

  double _circleCenterWidth(Size size, {required int index}) {
    return size.width / 8 * (2 * index + 1);
  }

  double _inputLineHeight(Size size) => size.height - _radius(size) * 2;

  Path _touchPath(
    Size size, {
    required Touch touch,
    required int timeStamp,
    required int window,
  }) {
    final radius = _radius(size);
    final ratio = _inputLineHeight(size) / window;

    final xPos = _circleCenterWidth(size, index: touch.input.idx);
    var bottom = ratio * (timeStamp - touch.timeStamp + window);
    final top = min(
      bottom - ratio * (touch.duration ?? 0),
      _inputLineHeight(size),
    );
    bottom = min(bottom, _inputLineHeight(size));

    return Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(xPos, top),
          width: 2 * radius,
          height: 2 * radius,
        ),
        pi,
        pi,
      )
      ..lineTo(xPos + radius, bottom)
      ..addArc(
        Rect.fromCenter(
          center: Offset(xPos, bottom),
          width: 2 * radius,
          height: 2 * radius,
        ),
        0,
        pi,
      )
      ..lineTo(xPos - radius, top);
  }

  void paintInputCircles(
    Canvas canvas,
    Size size, {
    Input activeInput = Input.none,
  }) {
    final radius = _radius(size);

    for (final input in Input.values) {
      if (input == Input.none) continue;

      final index = inputCircleIndex(input)!;
      final paint = (activeInput == input ? _paintFill : _paintStroke)
        ..color = inputColors[input]!;
      final center = Offset(
        _circleCenterWidth(size, index: index),
        _inputLineHeight(size),
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  void paintTouch(
    Canvas canvas,
    Size size, {
    required Touch touch,
    required int timeStamp,
    required int window,
  }) {
    final paint = _paintFill..color = inputColors[touch.input]!.withAlpha(150);
    final path =
        _touchPath(size, touch: touch, timeStamp: timeStamp, window: window);
    canvas.drawPath(path, paint);
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
