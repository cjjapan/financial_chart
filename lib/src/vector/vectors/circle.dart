import 'dart:math';

import 'package:vector_math/vector_math.dart';

class CircleUtil {
  static List<Vector2> intersectionPointsToLine(
    double cx,
    double cy,
    double r,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    double m = (y2 - y1) / (x2 - x1);

    double b = y1 - m * x1;

    double A = 1 + m * m;
    double B = 2 * (m * (b - cy) - cx);
    double C = cx * cx + (b - cy) * (b - cy) - r * r;

    double discriminant = B * B - 4 * A * C;

    if (discriminant < 0) {
      return [];
    }

    double x1Intersection = (-B + sqrt(discriminant)) / (2 * A);
    double x2Intersection = (-B - sqrt(discriminant)) / (2 * A);

    double y1Intersection = m * x1Intersection + b;
    double y2Intersection = m * x2Intersection + b;

    return [
      Vector2(x1Intersection, y1Intersection),
      Vector2(x2Intersection, y2Intersection),
    ];
  }

  static Vector2 nearestPointOn(
    double cx,
    double cy,
    double r,
    double px,
    double py,
  ) {
    Vector2 direction =
        Vector2(px - cx, py - cy)
          ..normalize()
          ..scale(r);
    return Vector2(cx + direction.x, cy + direction.y);
  }

  static double distanceTo(
    double cx,
    double cy,
    double r,
    double px,
    double py,
  ) {
    Vector2 nearestPoint = nearestPointOn(cx, cy, r, px, py);
    return Vector2(px, py).distanceTo(nearestPoint);
  }

  static bool isInside(double cx, double cy, double r, double px, double py) {
    return Vector2(px - cx, py - cy).length <= r;
  }

  static bool hitTest({
    required double cx,
    required double cy,
    required double r,
    required double px,
    required double py,
    bool testArea = false,
    double epsilon = 5.0,
  }) {
    if (testArea) {
      return isInside(cx, cy, r, px, py);
    }
    final distance = sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy));
    return (distance <= (r + epsilon)) && (distance >= (r - epsilon));
  }
}
