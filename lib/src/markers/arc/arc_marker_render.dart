import 'dart:ui';

import 'package:flutter/painting.dart';
import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/render_util.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'arc_marker.dart';

class GArcMarkerRender
    extends GGraphMarkerRender<GArcMarker, GGraphMarkerTheme> {
  const GArcMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GArcMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length == 2) {
      // center and border points
      final center = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final border = marker.keyCoordinates[1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = (border - center).distance;
      //ArcHitTest.
      Path path = GRenderUtil.addArcPath(
        center: center,
        radius: radius,
        startAngle: marker.startTheta,
        endAngle: marker.endTheta,
        close: marker.close,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    } else if (marker.keyCoordinates.length == 1 && marker.radiusSize != null) {
      // radius with anchor point and alignment
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = marker.radiusSize!.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final alignment =
          marker
              .alignment; // where anchor point located on the bound rect of the circle
      Rect rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: radius * 2,
        height: radius * 2,
        alignment: alignment,
      );
      Path path = GRenderUtil.addArcPath(
        center: rect.center,
        radius: radius,
        startAngle: marker.startTheta,
        endAngle: marker.endTheta,
        close: marker.close,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    }
  }
}
