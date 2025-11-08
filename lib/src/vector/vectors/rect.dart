import 'dart:ui';

import 'package:vector_math/vector_math.dart';
import 'line.dart';
import 'extensions.dart';

/// Utility functions for rectangle geometry calculations.
class RectUtil {
  /// Gets the left, top, right, and bottom coordinates from two points.
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

  /// Finds the nearest point on a rectangle to a given point.
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

  static bool hitTestRoundedRect({
    required Rect rect,
    required double cornerRadius,
    required Offset point,
    required double epsilon,
    bool testArea = true,
  }) {
    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;

    final leftCorner = left + cornerRadius;
    final rightCorner = right - cornerRadius;
    final topCorner = top + cornerRadius;
    final bottomCorner = bottom - cornerRadius;

    if (testArea) {
      // check if point is inside the rectangle area
      if (point.dx >= left &&
          point.dx <= right &&
          point.dy >= top &&
          point.dy <= bottom) {
        // check if point is inside the corner circles
        if (cornerRadius > 1e-6) {
          Offset topLeftCenter = Offset(leftCorner, topCorner);
          Offset topRightCenter = Offset(rightCorner, topCorner);
          Offset bottomLeftCenter = Offset(leftCorner, bottomCorner);
          Offset bottomRightCenter = Offset(rightCorner, bottomCorner);

          if (point.dx < leftCorner && point.dy < topCorner) {
            return (point - topLeftCenter).distance <= cornerRadius + epsilon;
          }
          if (point.dx > rightCorner && point.dy < topCorner) {
            return (point - topRightCenter).distance <= cornerRadius + epsilon;
          }
          if (point.dx < leftCorner && point.dy > bottomCorner) {
            return (point - bottomLeftCenter).distance <=
                cornerRadius + epsilon;
          }
          if (point.dx > rightCorner && point.dy > bottomCorner) {
            return (point - bottomRightCenter).distance <=
                cornerRadius + epsilon;
          }
          return true; // Point is inside the rectangle area with corner circles
        } else {
          return true; // Point is inside the rectangle area without corner circles
        }
      }
    } else {
      // check border lines
      if ((point.dx >= leftCorner - epsilon &&
              point.dx <= rightCorner + epsilon &&
              (point.dy >= top - epsilon && point.dy <= top + epsilon)) ||
          (point.dx >= leftCorner - epsilon &&
              point.dx <= rightCorner + epsilon &&
              (point.dy >= bottom - epsilon && point.dy <= bottom + epsilon)) ||
          (point.dy >= topCorner - epsilon &&
              point.dy <= bottomCorner + epsilon &&
              (point.dx >= left - epsilon && point.dx <= left + epsilon)) ||
          (point.dy >= topCorner - epsilon &&
              point.dy <= bottomCorner + epsilon &&
              (point.dx >= right - epsilon && point.dx <= right + epsilon))) {
        return true;
      }

      // check corner circles
      if (cornerRadius > 1e-6) {
        Offset topLeftCenter = Offset(leftCorner, topCorner);
        Offset topRightCenter = Offset(rightCorner, topCorner);
        Offset bottomLeftCenter = Offset(leftCorner, bottomCorner);
        Offset bottomRightCenter = Offset(rightCorner, bottomCorner);

        if (point.dx < leftCorner && point.dy < topCorner) {
          return (point - topLeftCenter).distance >= cornerRadius - epsilon &&
              (point - topLeftCenter).distance <= cornerRadius + epsilon;
        }
        if (point.dx > rightCorner && point.dy < topCorner) {
          return (point - topRightCenter).distance >= cornerRadius - epsilon &&
              (point - topRightCenter).distance <= cornerRadius + epsilon;
        }
        if (point.dx < leftCorner && point.dy > bottomCorner) {
          return (point - bottomLeftCenter).distance >=
                  cornerRadius - epsilon &&
              (point - bottomLeftCenter).distance <= cornerRadius + epsilon;
        }
        if (point.dx > rightCorner && point.dy > bottomCorner) {
          return (point - bottomRightCenter).distance >=
                  cornerRadius - epsilon &&
              (point - bottomRightCenter).distance <= cornerRadius + epsilon;
        }
      }
    }
    return false;
  }
}
