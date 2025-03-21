import 'dart:math';

import 'package:vector_math/vector_math.dart';
import 'extensions.dart';

class LineUtil {
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

  bool hitTest({
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
}
