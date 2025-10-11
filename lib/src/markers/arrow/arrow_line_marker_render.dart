import 'dart:math';
import 'dart:ui';

import '../../chart.dart';
import '../../components/components.dart';
import '../../style/paint_style.dart';
import 'arrow_line_marker.dart';

class GArrowLineMarkerRender
    extends GOverlayMarkerRender<GArrowLineMarker, GOverlayMarkerTheme> {
  GArrowLineMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GArrowLineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length != 2) {
      return;
    }
    final start = marker.keyCoordinates[0].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    final end = marker.keyCoordinates[1].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );

    // draw the arrow triangle along the line direction
    drawArrow(
      canvas: canvas,
      start: start,
      end: end,
      startHead: marker.startHead,
      endHead: marker.endHead,
      arrowStyle: theme.markerStyle,
      lineStyle: theme.markerStyle,
    );
  }

  static void drawArrow({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required GArrowHead startHead,
    required GArrowHead endHead,
    bool drawLine = true,
    required PaintStyle arrowStyle,
    required PaintStyle lineStyle,
  }) {
    Offset lineEnd = end;
    if (endHead.type != GArrowHeadType.none) {
      final (arrowLeft, arrowMiddle, arrowRight) = drawArrowHead(
        canvas: canvas,
        start: start,
        end: end,
        style: arrowStyle,
        head: endHead,
      );
      lineEnd = arrowMiddle;
    }

    Offset lineStart = start;
    if (startHead.type != GArrowHeadType.none) {
      final (arrowLeft, arrowMiddle, arrowRight) = drawArrowHead(
        canvas: canvas,
        start: end,
        end: start,
        head: startHead,
        style: arrowStyle,
      );
      lineStart = arrowMiddle;
    }

    if (drawLine) {
      final linePath = Path();
      linePath.moveTo(lineStart.dx, lineStart.dy);
      linePath.lineTo(lineEnd.dx, lineEnd.dy);
      GRenderUtil.drawPath(canvas: canvas, path: linePath, style: lineStyle);
    }
  }

  static (Offset left, Offset middle, Offset right) drawArrowHead({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required GArrowHead head,
    required PaintStyle style,
  }) {
    final arrowType = head.type;
    double headLength = head.length;
    double headWidth = head.width;
    if (arrowType == GArrowHeadType.diamond ||
        arrowType == GArrowHeadType.oval) {
      headLength = headLength / 2; // Adjust width for diamond and oval arrows
    }
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    Offset arrowMiddle = Offset(
      end.dx - headLength * cos(angle),
      end.dy - headLength * sin(angle),
    );
    final arrowLeft = Offset(
      arrowMiddle.dx + headWidth * cos(angle + pi / 2),
      arrowMiddle.dy + headWidth * sin(angle + pi / 2),
    );
    final arrowRight = Offset(
      arrowMiddle.dx + headWidth * cos(angle - pi / 2),
      arrowMiddle.dy + headWidth * sin(angle - pi / 2),
    );

    if (arrowType == GArrowHeadType.triangle) {
      final arrowPath = Path()
        ..moveTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(end.dx, end.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..close();
      GRenderUtil.drawPath(canvas: canvas, path: arrowPath, style: style);
    } else if (arrowType == GArrowHeadType.open) {
      arrowMiddle = end;
      final arrowPath = Path()
        ..moveTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(end.dx, end.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy);
      GRenderUtil.drawPath(
        canvas: canvas,
        path: arrowPath,
        style: style,
        strokeOnly: true,
      );
    } else if (arrowType == GArrowHeadType.stealth) {
      arrowMiddle = (end + arrowMiddle) / 2;
      final arrowPath = Path()
        ..moveTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowMiddle.dx, arrowMiddle.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..lineTo(end.dx, end.dy)
        ..close();
      GRenderUtil.drawPath(canvas: canvas, path: arrowPath, style: style);
    } else if (arrowType == GArrowHeadType.diamond) {
      arrowMiddle = arrowMiddle - (end - arrowMiddle);
      final arrowPath = Path()
        ..moveTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowMiddle.dx, arrowMiddle.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..lineTo(end.dx, end.dy)
        ..close();
      GRenderUtil.drawPath(canvas: canvas, path: arrowPath, style: style);
    } else if (arrowType == GArrowHeadType.oval) {
      arrowMiddle = arrowMiddle - (end - arrowMiddle);
      drawDiamondWrappingOval(
        canvas: canvas,
        diamondVertices: [arrowMiddle, arrowLeft, arrowRight, end],
        style: style,
      );
    }

    return (arrowLeft, arrowMiddle, arrowRight);
  }

  static void drawDiamondWrappingOval({
    required Canvas canvas,
    required List<Offset> diamondVertices,
    required PaintStyle style,
  }) {
    if (diamondVertices.length != 4) {
      throw ArgumentError('should have exactly 4 vertices');
    }

    double centerX = 0;
    double centerY = 0;
    for (final vertex in diamondVertices) {
      centerX += vertex.dx;
      centerY += vertex.dy;
    }
    centerX /= 4;
    centerY /= 4;
    final center = Offset(centerX, centerY);

    List<Offset> centeredVertices = diamondVertices
        .map((vertex) => Offset(vertex.dx - centerX, vertex.dy - centerY))
        .toList();

    final angle = atan2(centeredVertices[0].dy, centeredVertices[0].dx);

    final cosAngle = cos(-angle);
    final sinAngle = sin(-angle);
    List<Offset> rotatedVertices = centeredVertices.map((vertex) {
      final rotatedX = vertex.dx * cosAngle - vertex.dy * sinAngle;
      final rotatedY = vertex.dx * sinAngle + vertex.dy * cosAngle;
      return Offset(rotatedX, rotatedY);
    }).toList();

    double maxX = 0;
    double maxY = 0;
    for (final vertex in rotatedVertices) {
      maxX = max(maxX, vertex.dx.abs());
      maxY = max(maxY, vertex.dy.abs());
    }
    final rect = Rect.fromCenter(
      center: center,
      width: maxX * 2,
      height: maxY * 2,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    GRenderUtil.drawPath(
      canvas: canvas,
      path: Path()..addOval(rect),
      style: style,
    );
    canvas.restore();
  }
}
