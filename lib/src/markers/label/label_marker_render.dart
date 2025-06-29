import 'dart:ui';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'label_marker.dart';

class GLabelMarkerRender
    extends GOverlayMarkerRender<GLabelMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GLabelMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isEmpty) {
      return;
    }
    final anchor = marker.keyCoordinates[0].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    textRect = drawText(
      canvas: canvas,
      text: marker.text,
      anchor: anchor,
      defaultAlign: marker.alignment,
      style: theme.labelStyle!,
    );
    super.controlHandles.clear();
    if (chart.hitTestEnable && marker.hitTestEnable) {
      super.controlHandles.addAll({
        "align": GControlHandle(
          position: Offset(
            textRect!.center.dx + textRect!.width / 2 * marker.alignment.x,
            textRect!.center.dy + textRect!.height / 2 * marker.alignment.y,
          ),
          type: GControlHandleType.align,
        ),
        "anchor": GControlHandle(
          position: anchor,
          type: GControlHandleType.move,
          keyCoordinateIndex: 0,
        ),
      });
    }

    super.drawControlHandles(
      canvas: canvas,
      marker: marker,
      theme: theme,
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
  }

  Rect? textRect;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }

    if (textRect != null) {
      if (textRect!.contains(position)) {
        return true;
      }
    }

    return false;
  }
}
