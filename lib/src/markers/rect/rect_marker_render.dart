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
import 'rect_marker.dart';

class GRectMarkerRender
    extends GGraphMarkerRender<GRectMarker, GGraphMarkerTheme> {
  const GRectMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GRectMarker marker,
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
      final cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      Path path = addRectPath(
        rect: Rect.fromPoints(start, end),
        cornerRadius: cornerRadius,
      );
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
      final cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      Rect rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: pointRadius * 2,
        height: valueRadius * 2,
        alignment: marker.alignment,
      );
      Path path = addRectPath(rect: rect, cornerRadius: cornerRadius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    }
  }
}
