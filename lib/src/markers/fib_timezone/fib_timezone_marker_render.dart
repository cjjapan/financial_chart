import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/painting.dart';

class GFibonacciTimeZoneMarkerRender
    extends GOverlayMarkerRender<GFibTimeZoneMarker, GOverlayMarkerTheme> {
  GFibonacciTimeZoneMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GFibTimeZoneMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    _hitTestLinePoints.clear();
    super.controlHandles.clear();
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    if (!valueViewPort.isValid || !pointViewPort.isValid) {
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
    final startPoint = pointViewPort.positionToPoint(area, startPosition.dx);
    final endPoint = pointViewPort.positionToPoint(area, endPosition.dx);
    if (chart.hitTestEnable && marker.hitTestEnable) {
      super.controlHandles.addAll({
        'start': GControlHandle(
          position: startPosition,
          type: GControlHandleType.resize,
          keyCoordinateIndex: 0,
        ),
        'end': GControlHandle(
          position: endPosition,
          type: GControlHandleType.resize,
          keyCoordinateIndex: 1,
        ),
      });
    }

    double fibInterval = (endPoint - startPoint);
    double fibPrevious = 1; // F(n-1)
    double fibCurrent = 0; // F(n)
    double minPoint = pointViewPort.startPoint;
    double maxPoint = pointViewPort.endPoint;
    while (true) {
      final fibX = startPoint + fibInterval * fibCurrent;
      if (fibX >= minPoint && fibX <= maxPoint) {
        final dx = pointViewPort.pointToPosition(area, fibX);
        final path = addLinePath(x1: dx, y1: area.top, x2: dx, y2: area.bottom);
        drawPath(canvas: canvas, path: path, style: theme.markerStyle);
        _hitTestLinePoints.add([
          Vector2(dx, area.top),
          Vector2(dx, area.bottom),
        ]);

        // draw label
        final labelPosition = marker.labelPosition;
        final label = fibCurrent.toStringAsFixed(0);
        drawText(
          canvas: canvas,
          text: label,
          anchor: Offset(dx, area.top + (area.height * labelPosition)),
          defaultAlign: Alignment.center,
          style: theme.labelStyle!,
        );
      }
      if (fibInterval > 0 && fibX > maxPoint) {
        break;
      }
      if (fibInterval < 0 && fibX < minPoint) {
        break;
      }
      // next value in fibonacci sequence: F(n+1) = F(n) + F(n-1)
      final fibNext = fibCurrent + fibPrevious;
      fibPrevious = fibCurrent;
      fibCurrent = fibNext;
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

  final List<List<Vector2>> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (super.hitTestLines(lines: _hitTestLinePoints, position: position)) {
      return true;
    }
    return false;
  }
}
