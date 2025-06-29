import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import '../../chart.dart';
import '../../components/components.dart';
import '../../vector/vectors.dart';
import '../markers.dart';

class GArcMarkerRender
    extends GOverlayMarkerRender<GArcMarker, GOverlayMarkerTheme> {
  GArcMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GArcMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    super.controlHandles.clear();
    if (marker.keyCoordinates.isEmpty) {
      return;
    }
    if (marker.keyCoordinates.length == 2) {
      // center and border points
      this.center = marker.keyCoordinates[0].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final border = marker.keyCoordinates[1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      this.radius = (border - this.center!).distance;
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
      final rect = GRenderUtil.rectFromAnchorAndAlignment(
        anchor: anchor,
        width: radius * 2,
        height: radius * 2,
        alignment: marker.alignment,
      );
      this.center = rect.center;
      this.radius = radius;
    }
    if (this.center == null || this.radius == null) {
      return;
    }
    final center = this.center!;
    final radius = this.radius!;
    if (chart.hitTestEnable && marker.hitTestEnable) {
      startTheta = marker.startTheta;
      endTheta = marker.endTheta;
      super.controlHandles.addAll({
        "center": GControlHandle(
          position: Offset(center.dx, center.dy),
          type: GControlHandleType.move,
        ),
        "start": GControlHandle(
          position: Offset(
            center.dx + radius * cos(marker.startTheta),
            center.dy + radius * sin(marker.startTheta),
          ),
          type: GControlHandleType.resize,
        ),
        "end": GControlHandle(
          position: Offset(
            center.dx + radius * cos(marker.endTheta),
            center.dy + radius * sin(marker.endTheta),
          ),
          type: GControlHandleType.resize,
        ),
      });
    }
    closeType = marker.closeType;
    final arcPath = GRenderUtil.addArcPath(
      center: center,
      radius: radius,
      startAngle: marker.startTheta,
      endAngle: marker.endTheta,
      closeType: marker.closeType,
    );
    GRenderUtil.drawPath(
      canvas: canvas,
      path: arcPath,
      style: theme.markerStyle,
      strokeOnly: marker.closeType == GArcCloseType.none,
    );

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

  Offset? center;
  double? radius;
  double? startTheta;
  double? endTheta;
  GArcCloseType closeType = GArcCloseType.none;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (center == null ||
        radius == null ||
        startTheta == null ||
        endTheta == null) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    return ArcUtil.hitTest(
      cx: center!.dx,
      cy: center!.dy,
      r: radius!,
      startTheta: startTheta!,
      endTheta: endTheta!,
      px: position.dx,
      py: position.dy,
      testArea: closeType != GArcCloseType.none,
    );
  }
}
