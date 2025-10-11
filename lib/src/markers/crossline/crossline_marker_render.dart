import 'dart:ui';
import 'package:vector_math/vector_math.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'crossline_marker.dart';

class GCrosslineMarkerRender
    extends GOverlayMarkerRender<GCrosslineMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GCrosslineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final anchorPos = marker.anchor.toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    final style = theme.markerStyle;

    // Helper to clamp a value within area
    double clampX(double x) => x.clamp(area.left, area.right);
    double clampY(double y) => y.clamp(area.top, area.bottom);

    _hitTestLinePoints.clear();
    // Horizontal line (left)
    if (marker.leftRay) {
      final path = Path();
      final start = Offset(clampX(area.left), clampY(anchorPos.dy));
      final end = Offset(clampX(anchorPos.dx), clampY(anchorPos.dy));
      if (area.contains(start) || area.contains(end)) {
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        drawPath(canvas: canvas, path: path, style: style);
        _hitTestLinePoints.add([
          Vector2(start.dx, start.dy),
          Vector2(end.dx, end.dy),
        ]);
      }
    }
    // Horizontal line (right)
    if (marker.rightRay) {
      final path = Path();
      final start = Offset(clampX(anchorPos.dx), clampY(anchorPos.dy));
      final end = Offset(clampX(area.right), clampY(anchorPos.dy));
      if (area.contains(start) || area.contains(end)) {
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        drawPath(canvas: canvas, path: path, style: style);
        _hitTestLinePoints.add([
          Vector2(start.dx, start.dy),
          Vector2(end.dx, end.dy),
        ]);
      }
    }
    // Vertical line (top)
    if (marker.topRay) {
      final path = Path();
      final start = Offset(clampX(anchorPos.dx), clampY(area.top));
      final end = Offset(clampX(anchorPos.dx), clampY(anchorPos.dy));
      if (area.contains(start) || area.contains(end)) {
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        drawPath(canvas: canvas, path: path, style: style);
        _hitTestLinePoints.add([
          Vector2(start.dx, start.dy),
          Vector2(end.dx, end.dy),
        ]);
      }
    }
    // Vertical line (bottom)
    if (marker.bottomRay) {
      final path = Path();
      final start = Offset(clampX(anchorPos.dx), clampY(anchorPos.dy));
      final end = Offset(clampX(anchorPos.dx), clampY(area.bottom));
      if (area.contains(start) || area.contains(end)) {
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
        drawPath(canvas: canvas, path: path, style: style);
        _hitTestLinePoints.add([
          Vector2(start.dx, start.dy),
          Vector2(end.dx, end.dy),
        ]);
      }
    }

    controlHandles.clear();
    if (chart.hitTestEnable && marker.hitTestEnable) {
      controlHandles.addAll({
        "anchor": GControlHandle(
          position: anchorPos,
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

  final List<List<Vector2>> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    if (super.hitTestLines(lines: _hitTestLinePoints, position: position)) {
      return true;
    }
    return false;
  }
}
