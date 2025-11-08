import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math.dart';
import 'extensions.dart';

/// Utility functions for line geometry calculations.
class LineUtil {
  /// Finds the nearest point on a line segment to a given point.
  static Vector2 nearestPointOn({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
  }) {
    if (x1 == x2) {
      if (py > max(y1, y2)) {
        return Vector2(x1, max(y1, y2));
      } else if (py < min(y1, y2)) {
        return Vector2(x1, min(y1, y2));
      } else {
        return Vector2(x1, py);
      }
    } else if (y1 == y2) {
      if (px > max(x1, x2)) {
        return Vector2(max(x1, x2), y1);
      } else if (px < min(x1, x2)) {
        return Vector2(min(x1, x2), y1);
      } else {
        return Vector2(px, y1);
      }
    }
    Vector2 A = Vector2(x1, y1);
    Vector2 B = Vector2(x2, y2);
    Vector2 P = Vector2(px, py);
    //return projection(A, B, P);
    return (P - A).projection(B - A, clamp: true) + A;
  }

  /// Calculates the distance from a point to a line segment.
  static double distanceTo({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
  }) {
    Vector2 nearestPoint = nearestPointOn(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      px: px,
      py: py,
    );
    return Vector2(px, py).distanceTo(nearestPoint);
  }

  static bool hitTest({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
    double epsilon = 5.0,
  }) {
    double distance = distanceTo(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      px: px,
      py: py,
    );
    return distance <= epsilon;
  }

  static Offset? findIntersectionPointOfTwoLineSegments(
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    final double x1 = p1.dx;
    final double y1 = p1.dy;
    final double x2 = p2.dx;
    final double y2 = p2.dy;
    final double x3 = p3.dx;
    final double y3 = p3.dy;
    final double x4 = p4.dx;
    final double y4 = p4.dy;

    final double denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
      return null;
    }
    final double x =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
        denominator;
    final double y =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
        denominator;

    final intersection = Offset(x, y);
    if (x < p1.dx || x > p2.dx || x < p3.dx || x > p4.dx) {
      return null;
    }
    return intersection;
  }
}
