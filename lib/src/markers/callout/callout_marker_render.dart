import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../../components/components.dart';
import '../../vector/vectors/circle.dart';
import 'callout_marker.dart';

class GCalloutMarkerRender
    extends GOverlayMarkerRender<GCalloutMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GCalloutMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isEmpty) {
      return;
    }
    final anchor = marker.keyCoordinates[0].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    final (painter, textPaintPoint, blockArea) = GRenderUtil.createTextPainter(
      text: marker.text,
      anchor: anchor,
      defaultAlign: marker.alignment,
      style: theme.labelStyle!,
    );
    super.controlHandles.clear();
    final alignment = marker.alignment;
    double pointerMargin = marker.pointerMargin;
    Rect rect = blockArea.translate(
      alignment.x * pointerMargin,
      alignment.y * pointerMargin,
    );
    center = rect.center;
    backgroundPath = null;
    if (theme.labelStyle?.backgroundStyle != null) {
      backgroundPath = _createBackgroundPath(marker, theme, anchor, rect);
      drawPath(
        canvas: canvas,
        path: backgroundPath!,
        style: theme.labelStyle!.backgroundStyle!,
      );
    } else {
      backgroundPath = Path()..addRect(rect);
    }
    painter.paint(
      canvas,
      textPaintPoint.translate(
        alignment.x * pointerMargin,
        alignment.y * pointerMargin,
      ),
    );
    if (chart.hitTestEnable && marker.hitTestEnable) {
      super.controlHandles.addAll({
        "align": GControlHandle(
          position: Offset(
            rect.center.dx + rect.width / 2 * alignment.x,
            rect.center.dy + rect.height / 2 * alignment.y,
          ),
          type: GControlHandleType.align,
        ),
        "anchor": GControlHandle(
          position: anchor,
          type: GControlHandleType.move,
          keyCoordinateIndex: 0,
        ),
      });
    }
    if (marker.highlighted || marker.selected) {
      super.drawControlHandles(
        canvas: canvas,
        marker: marker,
        theme: theme,
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
    }
  }

  Path _createBackgroundPath(
    GCalloutMarker marker,
    GOverlayMarkerTheme theme,
    Offset anchor,
    Rect textRect,
  ) {
    double pointerSize = marker.pointerSize;
    double borderRadius = theme.labelStyle?.backgroundCornerRadius ?? 0;
    final alignment = marker.alignment;
    Rect rect = textRect;

    Path path1 = Path();
    path1.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
    );

    Path path2 = Path();
    double triangleX1 = 0, triangleY1 = 0, triangleX2 = 0, triangleY2 = 0;
    double cornerCx1 = 0, cornerCy1 = 0, cornerCx2 = 0, cornerCy2 = 0;
    double targetX = anchor.dx;
    double targetY = anchor.dy;
    switch (alignment) {
      case Alignment.topLeft:
        triangleX1 = rect.right - pointerSize;
        triangleY1 = rect.bottom;
        triangleX2 = rect.right;
        triangleY2 = rect.bottom - pointerSize;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.topCenter:
        triangleX1 = rect.left + rect.width / 2 - pointerSize;
        triangleY1 = rect.bottom;
        triangleX2 = rect.left + rect.width / 2 + pointerSize;
        triangleY2 = rect.bottom;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if ((rect.width / 2 - pointerSize) >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.topRight:
        triangleX1 = rect.left;
        triangleY1 = rect.bottom - pointerSize;
        triangleX2 = rect.left + pointerSize;
        triangleY2 = rect.bottom;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.bottom - borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.centerLeft:
        triangleX1 = rect.right;
        triangleY1 = rect.top + rect.height / 2 - pointerSize;
        triangleX2 = rect.right;
        triangleY2 = rect.top + rect.height / 2 + pointerSize;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.centerRight:
        triangleX1 = rect.left;
        triangleY1 = rect.top + rect.height / 2 - pointerSize;
        triangleX2 = rect.left;
        triangleY2 = rect.top + rect.height / 2 + pointerSize;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.bottom - borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.bottomLeft:
        triangleX1 = rect.right;
        triangleY1 = rect.top + pointerSize;
        triangleX2 = rect.right - pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.right - borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.bottomCenter:
        triangleX1 = rect.left + rect.width / 2 + pointerSize;
        triangleY1 = rect.top;
        triangleX2 = rect.left + rect.width / 2 - pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.right - borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if ((rect.width / 2 - pointerSize) >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.bottomRight:
        triangleX1 = rect.left;
        triangleY1 = rect.top + pointerSize;
        triangleX2 = rect.left + pointerSize;
        triangleY2 = rect.top;
        cornerCx1 = rect.left + borderRadius;
        cornerCy1 = rect.top + borderRadius;
        cornerCx2 = rect.left + borderRadius;
        cornerCy2 = rect.top + borderRadius;
        if (pointerSize >= borderRadius) {
          path2.moveTo(triangleX1, triangleY1);
          path2.lineTo(triangleX2, triangleY2);
        } else {
          final points1 = CircleUtil.intersectionPointsToLine(
            cornerCx1,
            cornerCy1,
            borderRadius,
            triangleX1,
            triangleY1,
            targetX,
            targetY,
          );
          final points2 = CircleUtil.intersectionPointsToLine(
            cornerCx2,
            cornerCy2,
            borderRadius,
            triangleX2,
            triangleY2,
            targetX,
            targetY,
          );
          path2.moveTo(points1[0].x, points1[0].y);
          path2.lineTo(points2[0].x, points2[0].y);
        }
        break;
      case Alignment.center:
        path2.moveTo(targetX, targetY);
    }
    path2.lineTo(targetX, targetY);
    path2.close();

    Path path = Path.combine(PathOperation.union, path1, path2);

    return path;
  }

  Path? backgroundPath;
  Offset? center;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }

    if (backgroundPath != null) {
      if (backgroundPath!.contains(position)) {
        return true;
      }
      /*
      // test by border segments
      final it = _backgroundPath!.computeMetrics().iterator;
      while (it.moveNext()) {
        final metric = it.current;
        final segments = (metric.length / 5).round();
        for (int i = 0; i < segments; i++) {
          final tangent = metric.getTangentForOffset(
            (i * metric.length) / segments,
          );
          if (tangent != null &&
              (tangent.position - position).distance <=
                  (epsilon ?? kDefaultHitTestEpsilon)) {
            return true;
          }
        }
      }*/
    }

    return false;
  }
}
