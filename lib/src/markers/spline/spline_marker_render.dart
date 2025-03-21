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
import '../../vector/vectors.dart';
import 'spline_marker.dart';

class GSplineMarkerRender
    extends GGraphMarkerRender<GSplineMarker, GGraphMarkerTheme> {
  const GSplineMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GSplineMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    } else if (marker.keyCoordinates.length == 2) {
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
      Path path = addLinePath(
        x1: start.dx,
        y1: start.dy,
        x2: end.dx,
        y2: end.dy,
      );
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
    } else {
      final points = marker.keyCoordinates
          .map(
            (c) =>
                c
                    .toPosition(
                      area: area,
                      valueViewPort: valueViewPort,
                      pointViewPort: pointViewPort,
                    )
                    .toVector2(),
          )
          .toList(growable: false);
      final splinePoints = SplineUtil.catmullRomSpline(points, marker.close)
          .map((l) => l.map((v) => v.toOffset()).toList(growable: false))
          .toList(growable: false);
      Path path = GRenderUtil.addSplinePath(
        start: points[0].toOffset(),
        cubicList: splinePoints,
      );
      GRenderUtil.drawPath(
        canvas: canvas,
        path: path,
        style: theme.markerStyle,
      );
    }
  }

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}
