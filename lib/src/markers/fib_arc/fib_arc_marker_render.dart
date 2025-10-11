import 'dart:math';

import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/painting.dart';

class GFibArcMarkerRender
    extends GOverlayMarkerRender<GFibArcMarker, GOverlayMarkerTheme> {
  GFibArcMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GFibArcMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    super.controlHandles.clear();
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    final startPosition = marker.startCoord.toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    final endPosition = marker.endCoord.toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    _center = startPosition;
    _startTheta = marker.startTheta;
    _endTheta = marker.endTheta;
    _radiusList.clear();

    if (valueViewPort.isValid && pointViewPort.isValid) {
      super.controlHandles.addAll({
        "center": GControlHandle(
          position: Offset(_center!.dx, _center!.dy),
          type: GControlHandleType.move,
        ),
      });
      // draw circles at fibonacci levels
      final radiusOne = (endPosition - startPosition).distance;
      for (double level in marker.fibLevels) {
        final radius = radiusOne * level;
        final arcPath = GRenderUtil.addArcPath(
          center: startPosition,
          radius: radius,
          startAngle: marker.startTheta,
          endAngle: marker.endTheta,
          closeType: GArcCloseType.center,
        );
        GRenderUtil.drawPath(
          canvas: canvas,
          path: arcPath,
          style: theme.markerStyle,
          strokeOnly: true,
        );
        _radiusList.add(radius);
        super.controlHandles.addAll({
          "start-$level": GControlHandle(
            position: Offset(
              _center!.dx + radius * cos(marker.startTheta),
              _center!.dy + radius * sin(marker.startTheta),
            ),
            type: GControlHandleType.resize,
          ),
          "end-$level": GControlHandle(
            position: Offset(
              _center!.dx + radius * cos(marker.endTheta),
              _center!.dy + radius * sin(marker.endTheta),
            ),
            type: GControlHandleType.resize,
          ),
        });
      }
      // draw labels
      for (double level in marker.fibLevels) {
        final radius = radiusOne * level;
        // positon at middle of start and end angle
        final labelPos = Offset(
          startPosition.dx +
              radius *
                  cos(
                    marker.startTheta +
                        (marker.endTheta - marker.startTheta) / 2,
                  ),
          startPosition.dy +
              radius *
                  sin(
                    marker.startTheta +
                        (marker.endTheta - marker.startTheta) / 2,
                  ),
        );
        if (area.contains(labelPos)) {
          String label = "${(level * 100).toStringAsFixed(1)}% ";
          drawText(
            canvas: canvas,
            text: label,
            style: theme.labelStyle!,
            anchor: labelPos,
            defaultAlign: Alignment.center,
          );
        }
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

  Offset? _center;
  final List<double> _radiusList = [];
  double? _startTheta;
  double? _endTheta;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_center == null ||
        _radiusList.isEmpty ||
        _startTheta == null ||
        _endTheta == null) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    for (double radius in _radiusList) {
      if (ArcUtil.hitTest(
        cx: _center!.dx,
        cy: _center!.dy,
        r: radius,
        startTheta: _startTheta!,
        endTheta: _endTheta!,
        px: position.dx,
        py: position.dy,
        testArea: false,
      )) {
        return true;
      }
    }
    return false;
  }
}
