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
import 'shape_marker.dart';

class GShapeMarkerRender
    extends GGraphMarkerRender<GShapeMarker, GGraphMarkerTheme> {
  const GShapeMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GShapeMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isNotEmpty) {
      // radius with anchor point and alignment
      final anchor = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final radius = marker.radiusSize.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );

      final alignment =
          marker
              .alignment; // where anchor point located on the bound rect of the circle
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: radius * 2,
        height: radius * 2,
        alignment: alignment,
      );
      final center = rect.center;
      //Path path = addOvalPath(rect: rect);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      if (marker.rotation != 0) {
        canvas.rotate(marker.rotation);
      }
      Path path = marker.pathGenerator(radius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
      canvas.restore();
    }
  }
}
