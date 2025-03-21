import 'dart:ui';

import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'polygon_marker.dart';

class GPolygonMarkerRender
    extends GGraphMarkerRender<GPolygonMarker, GGraphMarkerTheme> {
  const GPolygonMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GPolygonMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final points = marker.keyCoordinates
        .map(
          (e) => e.toPosition(
            area: area,
            valueViewPort: valueViewPort,
            pointViewPort: pointViewPort,
          ),
        )
        .toList(growable: false);
    Path path = addPolygonPath(points: points, close: marker.close);
    drawPath(canvas: canvas, path: path, style: theme.markerStyle);
  }
}
