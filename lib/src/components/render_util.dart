import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../style/dash_path.dart';
import '../style/label_style.dart';
import '../style/paint_style.dart';
import 'axis/axis.dart';
import 'axis/axis_theme.dart';

enum GArcCloseType {
  /// The arc is not closed, it is just a segment of a circle.
  none,

  /// The arc is closed by two lines connecting the start and end to the center.
  center,

  /// The arc is closed by single line connecting the start to end.
  direct,
}

/// Utility class for rendering.
class GRenderUtil {
  static void renderClipped({
    required Canvas canvas,
    required Rect clipRect,
    required void Function() render,
  }) {
    canvas.save();
    canvas.clipRect(clipRect);
    render();
    canvas.restore();
  }

  static void renderRotated({
    required Canvas canvas,
    required Offset center,
    required double theta,
    required void Function() render,
  }) {
    if (theta == 0) {
      render();
      return;
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(theta);
    canvas.translate(-center.dx, -center.dy);
    render();
    canvas.restore();
  }

  static void drawPath({
    required Canvas canvas,
    required Path path,
    required PaintStyle style,
    Rect? gradientBounds,
    bool ignoreDash = false,
    bool fillOnly = false,
    bool strokeOnly = false,
  }) {
    if (!strokeOnly) {
      final fillBounds = (style.fillGradient == null)
          ? null
          : (gradientBounds ?? style.gradientBounds ?? path.getBounds());
      final fillPaint = style.getFillPaint(gradientBounds: fillBounds);
      if (fillPaint != null) {
        canvas.drawPath(path, fillPaint);
      }
    }

    if (!fillOnly) {
      final strokeBounds = (style.strokeGradient == null)
          ? null
          : (gradientBounds ?? style.gradientBounds ?? path.getBounds());
      final strokePaint = style.getStrokePaint(gradientBounds: strokeBounds);
      if (strokePaint != null) {
        Path? theDashPath;
        if (!ignoreDash && style.dash != null) {
          theDashPath = dashPath(
            path,
            dashArray: CircularIntervalList(style.dash!),
            dashOffset: style.dashOffset,
          );
        }
        canvas.drawPath(theDashPath ?? path, strokePaint);
      }
    }
  }

  static (TextPainter painter, Offset textPaintPoint, Rect blockArea)
  createTextPainter({
    required String text,
    Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
    required LabelStyle style,
  }) {
    final painter = TextPainter(
      text: style.textStyle != null
          ? TextSpan(text: text, style: style.textStyle)
          : style.span!(text),
      textAlign: style.textAlign ?? TextAlign.start,
      textDirection: style.textDirection ?? TextDirection.ltr,
      textScaler: style.textScaler ?? TextScaler.noScaling,
      maxLines: style.maxLines,
      ellipsis: style.ellipsis,
      locale: style.locale,
      strutStyle: style.strutStyle,
      textWidthBasis: style.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: style.textHeightBehavior,
    );
    painter.layout(
      minWidth: style.minWidth ?? 0.0,
      maxWidth: style.maxWidth ?? double.infinity,
    );
    final rotationAxis = style.offset == null ? anchor : anchor + style.offset!;
    final padding = style.backgroundPadding?.resolve(style.textDirection);
    final width = painter.width + (padding?.left ?? 0) + (padding?.right ?? 0);
    final height =
        painter.height + (padding?.top ?? 0) + (padding?.bottom ?? 0);
    final point = getBlockPaintPoint(
      rotationAxis,
      width,
      height,
      style.align ?? defaultAlign,
    );
    final textPaintPoint =
        point + Offset((padding?.left ?? 0), (padding?.top ?? 0));
    return (
      painter,
      textPaintPoint,
      Rect.fromLTWH(point.dx, point.dy, width, height),
    );
  }

  static Rect drawText({
    required Canvas canvas,
    required String text,
    Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
    required LabelStyle style,
  }) {
    final (painter, textPaintPoint, blockArea) = createTextPainter(
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: style,
    );
    renderRotated(
      canvas: canvas,
      center: anchor,
      theta: style.rotation ?? 0,
      render: () {
        if (style.backgroundStyle != null) {
          final Path blockPath = addRectPath(
            rect: blockArea,
            cornerRadius: style.backgroundCornerRadius ?? 0,
          );
          drawPath(
            canvas: canvas,
            path: blockPath,
            style: style.backgroundStyle!,
          );
        }
        painter.paint(canvas, textPaintPoint);
      },
    );
    return blockArea;
  }

  static Rect drawValueAxisLabel({
    required Canvas canvas,
    required String text,
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    final anchor = valueAxisLabelAnchor(
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
    final defaultAlign = valueAxisLabelAlignment(axis: axis);
    return drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: labelTheme.labelStyle,
    );
  }

  static Rect drawPointAxisLabel({
    required Canvas canvas,
    required String text,
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    final anchor = pointAxisLabelAnchor(
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
    final defaultAlign = pointAxisLabelAlignment(axis: axis);
    return drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: labelTheme.labelStyle,
    );
  }

  static Rect drawSvg({
    required PictureInfo pictureInfo,
    required Offset anchor,
    Alignment alignment = Alignment.center,
    Size? size,
    required Canvas canvas,
  }) {
    final drawSize = size ?? pictureInfo.size;
    final rect = GRenderUtil.rectFromAnchorAndAlignment(
      anchor: anchor,
      width: drawSize.width,
      height: drawSize.height,
      alignment: alignment,
    );
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.scale(
      drawSize.width / pictureInfo.size.width,
      drawSize.height / pictureInfo.size.height,
    );
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
    return rect;
  }

  static Offset getTextBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align, {
    EdgeInsets? padding,
  }) => getBlockPaintPoint(axis, width, height, align, padding: padding);

  static Path addLinePath({
    Path? toPath,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    Rect? area,
    bool startRay = false,
    bool endRay = false,
    List<double>? resultPathPoints,
  }) {
    if (area != null && (startRay || endRay)) {
      return _addLinePathRayTo(
        toPath: toPath,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        area: area,
        startRay: startRay,
        endRay: endRay,
        resultPathPoints: resultPathPoints,
      );
    }
    Path path = Path();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
    toPath?.addPath(path, Offset.zero);
    if (resultPathPoints != null) {
      resultPathPoints.clear();
      resultPathPoints.addAll([x1, y1, x2, y2]);
    }
    return toPath ?? path;
  }

  /// Creates a line path from (x1, y1) to (x2, y2).
  /// If startRay is true, extends the line from startPosition to the border of the area.
  /// If endRay is true, extends the line from endPosition to the border of the area.
  static Path _addLinePathRayTo({
    Path? toPath,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required Rect area,
    required bool startRay,
    required bool endRay,
    List<double>? resultPathPoints,
  }) {
    final dx = x2 - x1;
    final dy = y2 - y1;

    // Avoid degenerate case
    if (dx.abs() < 1e-6 && dy.abs() < 1e-6) {
      if (resultPathPoints != null) {
        resultPathPoints.clear();
        resultPathPoints.addAll([x1, y1, x2, y2]);
      }
      return Path()..moveTo(x1, y1);
    }

    Offset startPosition = Offset(x1, y1);
    Offset endPosition = Offset(x2, y2);
    Offset actualStart = startPosition;
    Offset actualEnd = endPosition;

    // Find intersection with area borders if ray extension is needed
    if (startRay || endRay) {
      List<Offset> intersections = [];

      // Left border
      if (dx != 0) {
        double t = (area.left - startPosition.dx) / dx;
        double y = startPosition.dy + t * dy;
        if (y >= area.top && y <= area.bottom) {
          intersections.add(Offset(area.left, y));
        }
      }

      // Right border
      if (dx != 0) {
        double t = (area.right - startPosition.dx) / dx;
        double y = startPosition.dy + t * dy;
        if (y >= area.top && y <= area.bottom) {
          intersections.add(Offset(area.right, y));
        }
      }

      // Top border
      if (dy != 0) {
        double t = (area.top - startPosition.dy) / dy;
        double x = startPosition.dx + t * dx;
        if (x >= area.left && x <= area.right) {
          intersections.add(Offset(x, area.top));
        }
      }

      // Bottom border
      if (dy != 0) {
        double t = (area.bottom - startPosition.dy) / dy;
        double x = startPosition.dx + t * dx;
        if (x >= area.left && x <= area.right) {
          intersections.add(Offset(x, area.bottom));
        }
      }

      // Sort intersections by distance from startPosition
      intersections.sort(
        (a, b) => (a - startPosition).distance.compareTo(
          (b - startPosition).distance,
        ),
      );

      // Extend start if startRay is true
      if (startRay && intersections.isNotEmpty) {
        // Find intersection in the opposite direction (t < 0)
        for (int i = 0; i < intersections.length; i++) {
          final intersection = intersections[i];
          final t = dx != 0
              ? (intersection.dx - startPosition.dx) / dx
              : (intersection.dy - startPosition.dy) / dy;
          if (t < 0) {
            actualStart = intersection;
            break;
          }
        }
      }

      // Extend end if endRay is true
      if (endRay && intersections.isNotEmpty) {
        // Find intersection in the forward direction (t > 0)
        for (int i = intersections.length - 1; i >= 0; i--) {
          final intersection = intersections[i];
          final t = dx != 0
              ? (intersection.dx - startPosition.dx) / dx
              : (intersection.dy - startPosition.dy) / dy;
          if (t > 0) {
            actualEnd = intersection;
            break;
          }
        }
      }
    }

    Path path = Path();
    path.moveTo(actualStart.dx, actualStart.dy);
    path.lineTo(actualEnd.dx, actualEnd.dy);
    toPath?.addPath(path, Offset.zero);
    if (resultPathPoints != null) {
      resultPathPoints.clear();
      resultPathPoints.addAll([
        actualStart.dx,
        actualStart.dy,
        actualEnd.dx,
        actualEnd.dy,
      ]);
    }
    return toPath ?? path;
  }

  static Path addLinesPath({Path? toPath, required List<Offset> points}) {
    Path path = toPath ?? Path();
    for (int i = 0; i < points.length - 1; i++) {
      path = addLinePath(
        toPath: path,
        x1: points[i].dx,
        y1: points[i].dy,
        x2: points[i + 1].dx,
        y2: points[i + 1].dy,
      );
    }
    return path;
  }

  static Path addRectPath({
    Path? toPath,
    required Rect rect,
    double cornerRadius = 0,
  }) {
    Path path = toPath ?? Path();
    if (cornerRadius > 0) {
      path.addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      );
    } else {
      path.addRect(rect);
    }
    return path;
  }

  static Path addOvalPath({
    Path? toPath,
    required Rect rect,
    double cornerRadius = 0,
  }) {
    Path path = toPath ?? Path();
    path.addOval(rect);
    return path;
  }

  static Path addPolygonPath({
    Path? toPath,
    required List<Offset> points,
    required bool close,
    double cornerRadius = 0,
  }) {
    Path path = toPath ?? Path();
    path.addPolygon(points, close);
    return path;
  }

  static Path addSplinePath({
    Path? toPath,
    required Offset start,
    required List<List<Offset>> cubicList,
  }) {
    Path path = toPath ?? Path();
    path.moveTo(start.dx, start.dy);
    for (final cubic in cubicList) {
      path.cubicTo(
        cubic[0].dx,
        cubic[0].dy,
        cubic[1].dx,
        cubic[1].dy,
        cubic[2].dx,
        cubic[2].dy,
      );
    }
    return path;
  }

  static Path addArcPath({
    Path? toPath,
    required Offset center,
    required double radius,
    required double startAngle,
    required double endAngle,
    GArcCloseType closeType = GArcCloseType.none,
  }) {
    Path path = toPath ?? Path();
    path.moveTo(
      center.dx + radius * cos(startAngle),
      center.dy + radius * sin(startAngle),
    );
    path.arcToPoint(
      Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      ),
      radius: Radius.circular(radius),
      largeArc: endAngle - startAngle > pi,
      clockwise: true,
    );
    if (closeType != GArcCloseType.none) {
      if (closeType == GArcCloseType.center) {
        path.lineTo(center.dx, center.dy);
      }
      path.close();
    }
    return path;
  }

  static Offset valueAxisLabelAnchor({
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return Offset(
      axis.isAlignLeft
          ? (axisArea.left + labelTheme.spacing)
          : (axisArea.right - labelTheme.spacing),
      position,
    );
  }

  static Alignment valueAxisLabelAlignment({required GValueAxis axis}) {
    return axis.isAlignLeft ? Alignment.centerRight : Alignment.centerLeft;
  }

  static Offset pointAxisLabelAnchor({
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return Offset(
      position,
      axis.isAlignTop
          ? (axisArea.top + labelTheme.spacing)
          : (axisArea.bottom - labelTheme.spacing),
    );
  }

  static Alignment pointAxisLabelAlignment({required GPointAxis axis}) {
    return axis.isAlignTop ? Alignment.bottomCenter : Alignment.topCenter;
  }

  /// return rect will be located at [alignment] to [anchor] point
  static Rect rectFromAnchorAndAlignment({
    required Offset anchor,
    required double width,
    required double height,
    required Alignment alignment,
    EdgeInsets? padding,
  }) {
    Offset pt = getBlockPaintPoint(
      anchor,
      width,
      height,
      alignment,
      padding: padding,
    );
    return Rect.fromPoints(pt, pt + Offset(width, height));
  }

  /// Calculates the real painting offset point for labels.
  static Offset getBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align, {
    EdgeInsets? padding,
  }) => Offset(
    axis.dx -
        (width / 2) +
        ((width / 2) * align.x) +
        (padding?.left ?? 0) * align.x +
        (padding?.right ?? 0) * align.x,
    axis.dy -
        (height / 2) +
        ((height / 2) * align.y) +
        (padding?.top ?? 0) * align.y +
        (padding?.bottom ?? 0) * align.y,
  );
}
