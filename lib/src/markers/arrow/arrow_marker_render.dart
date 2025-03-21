import 'dart:math';
import 'dart:ui';

import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'arrow_marker.dart';

class GArrowMarkerRender
    extends GGraphMarkerRender<GArrowMarker, GGraphMarkerTheme> {
  const GArrowMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GArrowMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
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

      // draw the arrow triangle along the line direction
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
    }
  }
}
