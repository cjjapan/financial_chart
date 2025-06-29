import 'dart:ui';

import 'package:financial_chart/src/vector/vectors.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'polyline_marker.dart';

class GPolyLineMarkerRender
    extends GOverlayMarkerRender<GPolyLineMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GPolyLineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    super.controlHandles.clear();
    _hitTestPoints.clear();
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
      if (chart.hitTestEnable && marker.hitTestEnable) {
        if (i == 0) {
          super.controlHandles[i.toString()] = GControlHandle(
            position: startPosition,
            type: GControlHandleType.resize,
            keyCoordinateIndex: i,
          );
          _hitTestPoints.add(startPosition.toVector2());
        }
        super.controlHandles[(i + 1).toString()] = GControlHandle(
          position: endPosition,
          type: GControlHandleType.resize,
          keyCoordinateIndex: i + 1,
        );
        _hitTestPoints.add(endPosition.toVector2());
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

  final List<Vector2> _hitTestPoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (controlHandles.length < 2) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (_hitTestPoints.isEmpty) {
      return false;
    }
    return PolygonUtil.hitTest(
      vertices: _hitTestPoints,
      px: position.dx,
      py: position.dy,
      epsilon: epsilon ?? kDefaultHitTestEpsilon,
      testArea: false,
    );
  }
}
