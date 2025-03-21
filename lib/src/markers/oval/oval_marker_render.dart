import 'dart:ui';

import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/render_util.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'oval_marker.dart';

class GOvalMarkerRender
    extends GGraphMarkerRender<GOvalMarker, GGraphMarkerTheme> {
  const GOvalMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GOvalMarker marker,
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
      Path path = addOvalPath(rect: Rect.fromPoints(start, end));
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    } else if (marker.keyCoordinates.length == 1 &&
        marker.pointRadiusSize != null &&
        marker.valueRadiusSize != null) {
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final pointRadius = marker.pointRadiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final valueRadius = marker.valueRadiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      Rect rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: pointRadius * 2,
        height: valueRadius * 2,
        alignment: marker.alignment,
      );
      Path path = addOvalPath(rect: rect);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    }
  }
}
