import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/render_util.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'oval_marker.dart';

class GOvalMarkerRender
    extends GOverlayMarkerRender<GOvalMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GOvalMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
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

      renderRect = Rect.fromPoints(start, end);

      super.controlHandles.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          'center': GControlHandle(
            position: renderRect!.center,
            type: GControlHandleType.view,
          ),
          'start-v-center': GControlHandle(
            position: Offset(start.dx, renderRect!.center.dy),
            type: GControlHandleType.resize,
          ),
          'end-v-center': GControlHandle(
            position: Offset(end.dx, renderRect!.center.dy),
            type: GControlHandleType.resize,
          ),
          'start-h-center': GControlHandle(
            position: Offset(renderRect!.center.dx, start.dy),
            type: GControlHandleType.resize,
          ),
          'end-h-center': GControlHandle(
            position: Offset(renderRect!.center.dx, end.dy),
            type: GControlHandleType.resize,
          ),
        });
      }
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
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: pointRadius * 2,
        height: valueRadius * 2,
        alignment: marker.alignment,
      );
      renderRect = rect;
      Path path = addOvalPath(rect: rect);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);

      super.controlHandles.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          "align": GControlHandle(
            position: Offset(rect.center.dx, rect.center.dy),
            type: GControlHandleType.align,
          ),
          'anchor': GControlHandle(
            position: anchor,
            type: GControlHandleType.view,
            keyCoordinateIndex: 0,
          ),
          if (marker.alignment.x <= 0)
            'centerLeft': GControlHandle(
              position: rect.centerLeft,
              type: GControlHandleType.resize,
            ),
          if (marker.alignment.x >= 0)
            'centerRight': GControlHandle(
              position: rect.centerRight,
              type: GControlHandleType.resize,
            ),
          if (marker.alignment.y <= 0)
            'topCenter': GControlHandle(
              position: rect.topCenter,
              type: GControlHandleType.resize,
            ),
          if (marker.alignment.y >= 0)
            'bottomCenter': GControlHandle(
              position: rect.bottomCenter,
              type: GControlHandleType.resize,
            ),
        });
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

  Rect? renderRect;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (controlHandles.isEmpty) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }

    if (renderRect != null) {
      // hit test for oval shape
      final rect = renderRect!;
      final dx = position.dx - rect.center.dx;
      final dy = position.dy - rect.center.dy;
      final a = rect.width / 2;
      final b = rect.height / 2;
      // check if point in the oval area
      if (((dx * dx) / (a * a) + (dy * dy) / (b * b)) <= 1) {
        return true;
      }
    }

    return false;
  }
}
