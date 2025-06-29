import 'dart:math';
import 'dart:ui';

import 'package:financial_chart/src/vector/vectors.dart';
import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/render_util.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'rect_marker.dart';

class GRectMarkerRender
    extends GOverlayMarkerRender<GRectMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GRectMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    super.controlHandles.clear();
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
      cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      renderRect = Rect.fromPoints(start, end);
      Path path = addRectPath(rect: renderRect!, cornerRadius: cornerRadius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
      super.controlHandles.addAll({
        if (marker.scaleHandler != null && marker.cornerRadiusSize != null)
          'corner-radius': GControlHandle(
            position: Offset(renderRect!.left + cornerRadius, renderRect!.top),
            type: GControlHandleType.reshape,
          ),
        'start-start': GControlHandle(
          position: Offset(start.dx, start.dy),
          type: GControlHandleType.resize,
        ),
        'start-end': GControlHandle(
          position: Offset(start.dx, end.dy),
          type: GControlHandleType.resize,
        ),
        'end-start': GControlHandle(
          position: Offset(end.dx, start.dy),
          type: GControlHandleType.resize,
        ),
        'end-end': GControlHandle(
          position: Offset(end.dx, end.dy),
          type: GControlHandleType.resize,
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
      cornerRadius =
          marker.cornerRadiusSize?.toViewSize(
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ) ??
          0;
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: pointRadius * 2,
        height: valueRadius * 2,
        alignment: marker.alignment,
      );
      Path path = addRectPath(rect: rect, cornerRadius: cornerRadius);
      drawPath(canvas: canvas, path: path, style: theme.markerStyle);
      renderRect = rect;

      super.controlHandles.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          if (marker.scaleHandler != null && marker.cornerRadiusSize != null)
            'corner-radius': GControlHandle(
              position: Offset(rect.left + cornerRadius, rect.top),
              type: GControlHandleType.reshape,
            ),
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
  double cornerRadius = 0;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (controlHandles.isEmpty) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }

    if (renderRect != null) {
      final rect = renderRect!;
      return RectUtil.hitTestRoundedRect(
        rect: rect,
        cornerRadius: min(cornerRadius, renderRect!.shortestSide / 2),
        point: position,
        epsilon: epsilon ?? 5.0, // Default epsilon value
        testArea: true,
      );
    }

    return false;
  }
}
