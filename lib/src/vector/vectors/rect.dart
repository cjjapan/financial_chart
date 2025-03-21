import 'package:vector_math/vector_math.dart';
import 'line.dart';
import 'extensions.dart';

class RectUtil {
  static (double left, double top, double right, double bottm) getLTRB(
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    double left = x1 < x2 ? x1 : x2;
    double right = x1 > x2 ? x1 : x2;
    double top = y1 < y2 ? y1 : y2;
    double bottom = y1 > y2 ? y1 : y2;
    return (left, top, right, bottom);
  }

  static Vector2 nearestPointOnRect(
    double x1,
    double y1,
    double x2,
    double y2,
    double px,
    double py, {
    double rotationTheta = 0,
  }) {
    final (left, top, right, bottom) = getLTRB(x1, y1, x2, y2);
    Vector2 center = Vector2((left + right) / 2, (top + bottom) / 2);
    Vector2 point = Vector2(px, py);
    if (rotationTheta != 0) {
      point.rotate(-rotationTheta, center: center);
    }
    Vector2 result = Vector2(0, 0);

    if (point.x <= center.x) {
      if (point.y <= center.y) {
        if (point.x - left < point.y - top) {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: top,
              x2: left,
              y2: bottom,
              px: point.x,
              py: point.y,
            ),
          );
        } else {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: top,
              x2: right,
              y2: top,
              px: point.x,
              py: point.y,
            ),
          );
        }
      } else {
        if (point.x - left < bottom - point.y) {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: bottom,
              x2: left,
              y2: top,
              px: point.x,
              py: point.y,
            ),
          );
        } else {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: bottom,
              x2: right,
              y2: bottom,
              px: point.x,
              py: point.y,
            ),
          );
        }
      }
    } else {
      if (point.y <= center.y) {
        if (right - point.x < point.y - top) {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: right,
              y1: top,
              x2: right,
              y2: bottom,
              px: point.x,
              py: point.y,
            ),
          );
        } else {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: top,
              x2: right,
              y2: top,
              px: point.x,
              py: point.y,
            ),
          );
        }
      } else {
        if (right - point.x < bottom - point.y) {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: right,
              y1: bottom,
              x2: right,
              y2: top,
              px: point.x,
              py: point.y,
            ),
          );
        } else {
          result.setFrom(
            LineUtil.nearestPointOn(
              x1: left,
              y1: bottom,
              x2: right,
              y2: bottom,
              px: point.x,
              py: point.y,
            ),
          );
        }
      }
    }

    return result..rotate(rotationTheta, center: center);
  }

  static double distanceTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double px,
    double py, {
    double rotationTheta = 0,
  }) {
    Vector2 nearestPoint = nearestPointOnRect(
      x1,
      y1,
      x2,
      y2,
      px,
      py,
      rotationTheta: rotationTheta,
    );
    return (Vector2(px, py) - nearestPoint).length;
  }

  static bool isInside(
    double x1,
    double y1,
    double x2,
    double y2,
    double px,
    double py, {
    double rotationTheta = 0,
  }) {
    Vector2 point = Vector2(px, py);
    final (left, top, right, bottom) = getLTRB(x1, y1, x2, y2);
    Vector2 center = Vector2((left + right) / 2, (top + bottom) / 2);
    if (rotationTheta != 0) {
      point.rotate(-rotationTheta, center: center);
    }
    return point.x >= left &&
        point.x <= right &&
        point.y >= top &&
        point.y <= bottom;
  }

  static bool hitTest({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double px,
    required double py,
    bool testArea = false,
    double? epsilon,
    double rotationTheta = 0,
  }) {
    if (testArea) {
      return isInside(x1, y1, x2, y2, px, py, rotationTheta: rotationTheta);
    }
    final distance = distanceTo(
      x1,
      y1,
      x2,
      y2,
      px,
      py,
      rotationTheta: rotationTheta,
    );
    return (distance <= (epsilon ?? 5.0));
  }
}
