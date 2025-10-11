import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/painting.dart';

class GFibRetracementMarkerRender
    extends GOverlayMarkerRender<GFibRetracementMarker, GOverlayMarkerTheme> {
  GFibRetracementMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GFibRetracementMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
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
    _hitTestLinePoints.clear();
    super.controlHandles.clear();
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
    if (valueViewPort.isValid && pointViewPort.isValid) {
      final startPrice = valueViewPort.positionToValue(area, startPosition.dy);
      final endPrice = valueViewPort.positionToValue(area, endPosition.dy);
      final priceRange = endPrice - startPrice;

      for (double level in marker.fibLevels) {
        final fibPrice = startPrice + priceRange * level;
        final fibY = valueViewPort.valueToPosition(area, fibPrice);
        final fibOffset = Offset(startPosition.dx, fibY);
        final x1 = marker.startRay
            ? (startPosition.dx > endPosition.dx ? area.right : area.left)
            : startPosition.dx;
        final x2 = marker.endRay
            ? (startPosition.dx > endPosition.dx ? area.left : area.right)
            : endPosition.dx;
        Path path = addLinePath(x1: x1, y1: fibY, x2: x2, y2: fibY);
        drawPath(canvas: canvas, path: path, style: theme.markerStyle);
        _hitTestLinePoints.add([Vector2(x1, fibY), Vector2(x2, fibY)]);

        // Draw the Fibonacci level label
        String label =
            "${(level * 100).toStringAsFixed(1)}%  ${fibPrice.toStringAsFixed(3)}";
        drawText(
          canvas: canvas,
          text: label,
          anchor: fibOffset.translate(
            startPosition.dx < endPosition.dx ? -5 : 5,
            0,
          ),
          defaultAlign: startPosition.dx < endPosition.dx
              ? Alignment.centerLeft
              : Alignment.centerRight,
          style: theme.labelStyle!,
        );
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
