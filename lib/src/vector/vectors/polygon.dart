import 'package:vector_math/vector_math.dart';
import 'extensions.dart';
import 'line.dart';

class PolygonUtil {
  /// Ray-Casting algorithm implementation
  /// Calculate whether a horizontal ray cast eastward from [point]
  /// will intersect with the line between [vertA] and [vertB]
  /// Refer to `https://en.wikipedia.org/wiki/Point_in_polygon` for more explanation
  /// or the example comment bloc at the end of this file
  static Map<String, bool> _rayCastIntersect(
    Vector2 point,
    Vector2 vertA,
    Vector2 vertB,
  ) {
    final Map<String, bool> result = <String, bool>{
      'rayIntersects': false,
      'isOnEdge': false,
    }; // results of running the ray cast function

    final double aY = vertA.y;
    final double bY = vertB.y;
    final double aX = vertA.x;
    final double bX = vertB.x;
    final double pY = point.y;
    final double pX = point.x;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      // The case where the ray does not possibly pass through the polygon edge,
      // because both points A and B are above/below the line,
      // or both are to the left/west of the starting point
      // (as the line travels eastward into the polygon).
      // Therefore we should not perform the check and simply return false.
      // If we did not have this check we would get false positives.
      return result;
    }

    // y = mx + b : Standard linear equation
    // (y-b)/m = x : Formula to solve for x

    // M is rise over run -> the slope or angle between vertices A and B.
    final double m = (aY - bY) / (aX - bX);

    // case when polygon edge is vertical
    if (m == double.infinity || m == double.negativeInfinity) {
      final double lowerBound = (aY < bY) ? aY : bY;
      final double upperBound = (aY < bY) ? bY : aY;
      // check if ray cast from point intersects the polygon edge
      if ((pY >= lowerBound) && (pY <= upperBound)) {
        result['rayIntersects'] = true;
        // check if point is lying on this edge
        if (pX == aX) {
          result['isOnEdge'] = true;
        }
      }
      return result;
    }

    // B is the Y-intercept of the line between vertices A and B
    final double b = ((aX * -1) * m) + aY;

    // case when the polygon edge is horizontal
    if (m == 0) {
      final double lowerBound = (aX < bX) ? aX : bX;
      final double upperBound = (aX < bX) ? bX : aX;
      result['rayIntersects'] =
          true; // this is because there can only be one horizontal line that can exist that doesn't satisfy the first condition of this function
      if ((pX >= lowerBound) && (pX <= upperBound)) {
        // check if point is on the edge
        result['isOnEdge'] = true;
      }
      return result;
    }

    // We want to find the X location at which a flat horizontal ray at Y height
    // of pY would intersect with the line between A and B.
    // So we use our rearranged Y = MX+B, but we use pY as our Y value
    final double x = (pY - b) / m;

    // If the value of X
    // (the x point at which the ray intersects the line created by points A and B)
    // is "ahead" of the point's X value, then the ray can be said to intersect with the polygon.
    if (x > pX) {
      result['rayIntersects'] = true;
    }
    return result;
  }

  static double distanceTo({
    required List<Vector2> vertices,
    required double px,
    required double py,
  }) {
    double minDistance = double.infinity;
    for (int i = 0; i < vertices.length - 1; i++) {
      double distance = LineUtil.distanceTo(
        x1: vertices[i].x,
        y1: vertices[i].y,
        x2: vertices[i + 1].x,
        y2: vertices[i + 1].y,
        px: px,
        py: py,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }

  static Vector2 nearestPointOn({
    required List<Vector2> vertices,
    required double px,
    required double py,
  }) {
    double minDistance = double.infinity;
    Vector2 nearestPoint = Vector2.zero();
    for (int i = 0; i < vertices.length - 1; i++) {
      Vector2 nearest = LineUtil.nearestPointOn(
        x1: vertices[i].x,
        y1: vertices[i].y,
        x2: vertices[i + 1].x,
        y2: vertices[i + 1].y,
        px: px,
        py: py,
      );
      final distance = Vector2(px, py).distanceTo(nearestPoint);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = nearest;
      }
    }
    return nearestPoint;
  }

  /// https://github.com/aa-cee/point_in_polygon/blob/feature-fixes/lib/point_in_polygon.dart
  /// function to check if a given Point [point] is inside or on the boundary of the polygon object represented by  List of Point [vertices]
  /// by using a Ray-Casting algorithm
  static bool isInside({
    required List<Vector2> vertices,
    required double px,
    required double py,
  }) {
    Vector2 point = Vector2(px, py);
    int intersectCount = 0;
    for (int i = 0; i < vertices.length; i += 1) {
      // if point is same as vertex then consider it part of the polygon
      if (point.isSame(vertices[i])) {
        return true;
      }
      final Vector2 vertB = i == vertices.length - 1
          ? vertices[0]
          : vertices[i + 1];
      final Map<String, bool> rayCastIntersection = _rayCastIntersect(
        point,
        vertices[i],
        vertB,
      );
      if (rayCastIntersection['isOnEdge']!) {
        return true;
      }
      if (rayCastIntersection['rayIntersects']!) {
        intersectCount += 1;
      }
    }
    return (intersectCount % 2) == 1;
  }

  static bool hitTest({
    required List<Vector2> vertices,
    required double px,
    required double py,
    bool testArea = false,
    double epsilon = 5.0,
  }) {
    if (testArea) {
      return isInside(vertices: vertices, px: px, py: py);
    }
    final distance = distanceTo(vertices: vertices, px: px, py: py);
    return distance <= epsilon;
  }
}
