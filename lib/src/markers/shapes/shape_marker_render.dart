import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'shape_marker.dart';

class GShapeMarkerRender
    extends GOverlayMarkerRender<GShapeMarker, GOverlayMarkerTheme> {
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GShapeMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
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
      radius = marker.radiusSize.toViewSize(
        area: area,
        pointViewPort: pointViewPort,
        valueViewPort: valueViewPort,
      );
      final centerTranslate =
          ((marker.alignment.x.abs() + marker.alignment.y.abs()).round() >= 2)
          ? radius / 1.41421356237
          : radius;
      // calculate the center point from marker.alignment and anchor
      // the alignment is the direction to the anchor point
      center = anchor;
      if (marker.alignment == Alignment.center) {
        center = anchor;
      } else {
        center = Offset(
          anchor.dx + centerTranslate * marker.alignment.x,
          anchor.dy + centerTranslate * marker.alignment.y,
        );
      }

      canvas.save();
      canvas.translate(center.dx, center.dy);
      if (marker.rotation > 1e-6) {
        canvas.rotate(marker.rotation);
      }
      shapePath = marker.pathGenerator(radius);
      drawPath(canvas: canvas, path: shapePath!, style: theme.markerStyle);
      canvas.restore();

      shapePath = shapePath!.shift(Offset(center.dx, center.dy));
      super.controlHandles.clear();
      if (chart.hitTestEnable && marker.hitTestEnable) {
        super.controlHandles.addAll({
          "align": GControlHandle(
            position: center,
            type: GControlHandleType.align,
            keyCoordinateIndex: 0,
          ),
          "anchor": GControlHandle(
            position: anchor,
            type: GControlHandleType.move,
            keyCoordinateIndex: 0,
          ),
          "size": (marker.alignment == Alignment.center)
              ? GControlHandle(
                  position: Offset(center.dx + radius, center.dy),
                  type: GControlHandleType.resize,
                )
              : GControlHandle(
                  position: Offset(
                    center.dx + centerTranslate * marker.alignment.x,
                    center.dy + centerTranslate * marker.alignment.y,
                  ),
                  type: GControlHandleType.resize,
                ),
        });
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

  Offset center = Offset.zero;
  double radius = 0;
  double rotation = 0;
  Path? shapePath;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }

    if (shapePath != null) {
      if (shapePath!.contains(position)) {
        return true;
      }
    }

    return false;
  }
}
