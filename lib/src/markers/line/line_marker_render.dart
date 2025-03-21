import 'dart:ui';

import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'line_marker.dart';

class GLineMarkerRender
    extends GGraphMarkerRender<GLineMarker, GGraphMarkerTheme> {
  const GLineMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GLineMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    for (int i = 0; i < marker.keyCoordinates.length - 1; i++) {
      final startPosition = marker.keyCoordinates[i].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final endPosition = marker.keyCoordinates[i + 1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      Path path = addLinePath(
        x1: startPosition.dx,
        y1: startPosition.dy,
        x2: endPosition.dx,
        y2: endPosition.dy,
      );
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    }
  }

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}
