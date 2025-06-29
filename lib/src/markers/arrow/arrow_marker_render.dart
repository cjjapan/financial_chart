import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'arrow_marker.dart';

class GArrowMarkerRender
    extends GOverlayMarkerRender<GArrowMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GArrowMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length == 2) {
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

      // draw the arrow head along the line direction
      final arrowPath = Path();
      final headLength = marker.headLength;
      final headWidth = marker.headWidth;
      final angle = atan2(end.dy - start.dy, end.dx - start.dx);
      final arrowStart = Offset(
        end.dx - headLength * cos(angle),
        end.dy - headLength * sin(angle),
      );
      final arrowEnd = Offset(
        arrowStart.dx + headWidth * cos(angle + pi / 2),
        arrowStart.dy + headWidth * sin(angle + pi / 2),
      );
      final arrowStart2 = Offset(
        end.dx - headLength * cos(angle),
        end.dy - headLength * sin(angle),
      );
      final arrowEnd2 = Offset(
        arrowStart2.dx + headWidth * cos(angle - pi / 2),
        arrowStart2.dy + headWidth * sin(angle - pi / 2),
      );
      arrowPath.moveTo(end.dx, end.dy);
      arrowPath.lineTo(arrowEnd.dx, arrowEnd.dy);
      arrowPath.lineTo(arrowEnd2.dx, arrowEnd2.dy);
      arrowPath.close();
      drawPath(canvas: canvas, path: arrowPath, style: theme.markerStyle);

      // draw the line from start to middle of the arrow head
      final linePath = Path();
      linePath.moveTo(start.dx, start.dy);
      linePath.lineTo(arrowStart.dx, arrowStart.dy);
      drawPath(canvas: canvas, path: linePath, style: theme.markerStyle);

      controlHandles.clear();
      _hitTestLinePoints.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        controlHandles.addAll({
          "start": GControlHandle(
            position: Offset(start.dx, start.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 0,
          ),
          "end": GControlHandle(
            position: Offset(end.dx, end.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 1,
          ),
        });
        _hitTestLinePoints.addAll([
          // line
          [Vector2(start.dx, start.dy), Vector2(arrowStart.dx, arrowStart.dy)],
          // arrow head
          [
            Vector2(end.dx, end.dy),
            Vector2(arrowEnd.dx, arrowEnd.dy),
            Vector2(arrowEnd2.dx, arrowEnd2.dy),
            Vector2(end.dx, end.dy),
          ],
        ]);
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
  }

  final List<List<Vector2>> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (super.hitTestLines(lines: _hitTestLinePoints, position: position)) {
      return true;
    }
    return false;
  }
}
