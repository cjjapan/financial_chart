import 'dart:ui';

import 'package:financial_chart/src/vector/vectors.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'polygon_marker.dart';

class GPolygonMarkerRender
    extends GOverlayMarkerRender<GPolygonMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GPolygonMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length <= 1) {
      return;
    }
    final points = marker.keyCoordinates
        .map(
          (e) => e.toPosition(
            area: area,
            valueViewPort: valueViewPort,
            pointViewPort: pointViewPort,
          ),
        )
        .toList(growable: false);
    super.controlHandles.clear();
    _hitTestPoints.clear();
    if (chart.hitTestEnable && marker.hitTestEnable) {
      super.controlHandles.addEntries(
        points.asMap().entries.map(
          (p) => MapEntry(
            p.key.toString(),
            GControlHandle(
              position: p.value,
              type: GControlHandleType.resize,
              keyCoordinateIndex: p.key,
            ),
          ),
        ),
      );
      _hitTestPoints.addAll(points.map((e) => e.toVector2()));
      if (marker.close) {
        _hitTestPoints.add(_hitTestPoints.first);
      }
    }
    final path = addPolygonPath(points: points, close: marker.close);
    drawPath(canvas: canvas, path: path, style: theme.markerStyle);

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
      epsilon: epsilon ?? 5,
      testArea: true,
    );
  }
}
