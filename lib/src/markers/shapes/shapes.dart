import 'dart:math';

import 'package:flutter/painting.dart';

class GShapes {
  static Path circle(double radius) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(center: Offset.zero, radius: radius));
    return path;
  }

  static Path star(double radius, {required int vertexCount}) {
    final Path path = Path();
    final double innerRadius = radius * 0.5;
    for (int i = 0; i < vertexCount * 2; i++) {
      final double radian = pi / vertexCount * i.toDouble();
      final double x = (i.isEven ? innerRadius : radius) * cos(radian);
      final double y = (i.isEven ? innerRadius : radius) * sin(radian);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  static Path heart(double radius) {
    final Path path = Path();
    path.moveTo(0, radius);
    path.cubicTo(
      -radius * 2,
      -radius * 0.5,
      -radius * 0.5,
      -radius * 1.5,
      0,
      -radius * 0.5,
    );
    path.cubicTo(
      radius * 0.5,
      -radius * 1.5,
      radius * 2,
      -radius * 0.5,
      0,
      radius,
    );
    path.close();
    return path;
  }

  static Path polygon(double radius, {required int vertexCount}) {
    final Path path = Path();
    for (int i = 0; i < vertexCount; i++) {
      final double radian = pi * 2 / vertexCount * i.toDouble();
      final double x = radius * cos(radian);
      final double y = radius * sin(radian);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
}
