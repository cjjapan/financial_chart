import 'dart:ui';

import 'package:financial_chart/src/components/render.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/render_util.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import '../../vector/vectors.dart';
import 'spline_marker.dart';

class GSplineMarkerRender
    extends GOverlayMarkerRender<GSplineMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GSplineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    } else if (marker.keyCoordinates.length == 2) {
      isClose = marker.close;
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
      super.controlHandles.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          'start': GControlHandle(
            position: Offset(start.dx, start.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 0,
          ),
          'end': GControlHandle(
            position: Offset(end.dx, end.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 1,
          ),
        });
      }
    } else {
      final points = marker.keyCoordinates
          .map(
            (c) => c
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
      super.controlHandles.clear();
      splines.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          for (int i = 0; i < marker.keyCoordinates.length; i++)
            'point-$i': GControlHandle(
              position: points[i].toOffset(),
              type: GControlHandleType.resize,
              keyCoordinateIndex: i,
            ),
        });
        splines.addAll(
          splinePoints.map((l) => l.map((v) => v.toVector2()).toList()),
        );
      }
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

  final List<List<Vector2>> splines = [];
  bool isClose = false;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (splines.isNotEmpty) {
      return SplineUtil.hitTest(
        splines,
        position.toVector2(),
        isClose,
        epsilon: epsilon ?? kDefaultHitTestEpsilon,
      );
    }

    return false;
  }
}
