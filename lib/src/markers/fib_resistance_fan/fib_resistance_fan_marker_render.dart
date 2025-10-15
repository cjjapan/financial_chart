import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/painting.dart';

class GFibonacciResistanceFanMarkerRender
    extends GOverlayMarkerRender<GFibResistanceFanMarker, GOverlayMarkerTheme> {
  GFibonacciResistanceFanMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GFibResistanceFanMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    super.controlHandles.clear();
    _hitTestLinePoints.clear();
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
    final dottedLineStyle = theme.markerStyle.copyWith(dash: [2, 2]);
    if (valueViewPort.isValid && pointViewPort.isValid) {
      if (marker.valueFibLevels.isNotEmpty) {
        final startPrice = valueViewPort.positionToValue(
          area,
          startPosition.dy,
        );
        final endPrice = valueViewPort.positionToValue(area, endPosition.dy);
        final priceRange = startPrice - endPrice;

        for (double level in marker.valueFibLevels) {
          final fibPrice = endPrice + priceRange * level;
          final fibY = valueViewPort.valueToPosition(area, fibPrice);

          // Create fan line endpoint at the Fibonacci level
          final fanEndPosition = Offset(endPosition.dx, fibY);

          // Create path with ray extension from startPosition
          List<double> resultPathPoints = [];
          Path path = addLinePath(
            x1: startPosition.dx,
            y1: startPosition.dy,
            x2: fanEndPosition.dx,
            y2: fanEndPosition.dy,
            area: area,
            startRay: false,
            endRay: marker.extendRay,
            resultPathPoints: resultPathPoints,
          );
          drawPath(canvas: canvas, path: path, style: theme.markerStyle);
          controlHandles.addAll({
            "value-$level": GControlHandle(
              position: Offset(fanEndPosition.dx, fanEndPosition.dy),
              type: GControlHandleType.view,
            ),
          });
          // add path start and end to hit test lines
          if (resultPathPoints.length >= 4) {
            _hitTestLinePoints.add([
              Vector2(resultPathPoints[0], resultPathPoints[1]),
              Vector2(resultPathPoints[2], resultPathPoints[3]),
            ]);
          }

          if (marker.showValueLevelLines) {
            // Draw the Fibonacci level line
            Path linePath = Path();
            linePath.moveTo(startPosition.dx, fanEndPosition.dy);
            linePath.lineTo(endPosition.dx, fanEndPosition.dy);
            drawPath(canvas: canvas, path: linePath, style: dottedLineStyle);
          }

          if (marker.showValueLevelStartLabels) {
            // Draw the Fibonacci level label at the start
            String label =
                "${(level * 100).toStringAsFixed(1)}%  ${fibPrice.toStringAsFixed(3)}";
            drawText(
              canvas: canvas,
              text: label,
              anchor: Offset(
                startPosition.dx,
                fibY,
              ).translate((startPosition.dx > fanEndPosition.dx) ? 5 : -5, 0),
              defaultAlign: (startPosition.dx > fanEndPosition.dx)
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              style: theme.labelStyle!,
            );
          }
          if (marker.showValueLevelEndLabels) {
            // Draw the Fibonacci level label at the end
            String label =
                "${(level * 100).toStringAsFixed(1)}%  ${fibPrice.toStringAsFixed(3)}";
            drawText(
              canvas: canvas,
              text: label,
              anchor: Offset(
                endPosition.dx,
                fibY,
              ).translate((startPosition.dx > fanEndPosition.dx) ? -5 : 5, 0),
              defaultAlign: (startPosition.dx > fanEndPosition.dx)
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              style: theme.labelStyle!,
            );
          }
        }
      }

      if (marker.pointFibLevels.isNotEmpty) {
        final startIndex = pointViewPort.positionToPoint(
          area,
          startPosition.dx,
        );
        final endIndex = pointViewPort.positionToPoint(area, endPosition.dx);
        final indexRange = startIndex - endIndex;

        for (double level in marker.pointFibLevels) {
          final fibIndex = endIndex + indexRange * level;
          final fibX = pointViewPort.pointToPosition(area, fibIndex);

          // Create fan line endpoint at the Fibonacci level
          final fanEndPosition = Offset(fibX, endPosition.dy);

          // Create path with ray extension from startPosition
          List<double> resultPathPoints = [];
          Path path = addLinePath(
            x1: startPosition.dx,
            y1: startPosition.dy,
            x2: fanEndPosition.dx,
            y2: fanEndPosition.dy,
            area: area,
            startRay: false,
            endRay: marker.extendRay,
            resultPathPoints: resultPathPoints,
          );
          drawPath(canvas: canvas, path: path, style: theme.markerStyle);
          controlHandles.addAll({
            "point-$level": GControlHandle(
              position: Offset(fanEndPosition.dx, fanEndPosition.dy),
              type: GControlHandleType.view,
            ),
          });
          if (resultPathPoints.length >= 4) {
            _hitTestLinePoints.add([
              Vector2(resultPathPoints[0], resultPathPoints[1]),
              Vector2(resultPathPoints[2], resultPathPoints[3]),
            ]);
          }

          if (marker.showPointLevelLines) {
            // Draw the Fibonacci level line
            Path linePath = Path();
            linePath.moveTo(fanEndPosition.dx, startPosition.dy);
            linePath.lineTo(fanEndPosition.dx, endPosition.dy);
            drawPath(canvas: canvas, path: linePath, style: dottedLineStyle);
          }

          if (marker.showPointLevelStartLabels) {
            // Draw the Fibonacci level label at the start
            String label = "${(level * 100).toStringAsFixed(1)}%";
            drawText(
              canvas: canvas,
              text: label,
              anchor: Offset(
                fibX,
                startPosition.dy,
              ).translate(0, (startPosition.dy > fanEndPosition.dy) ? 5 : -5),
              defaultAlign: (startPosition.dy > fanEndPosition.dy)
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              style: theme.labelStyle!,
            );
          }
          if (marker.showPointLevelEndLabels) {
            // Draw the Fibonacci level label at the end
            String label = "${(level * 100).toStringAsFixed(1)}%";
            drawText(
              canvas: canvas,
              text: label,
              anchor: Offset(
                fibX,
                endPosition.dy,
              ).translate(0, (startPosition.dy > fanEndPosition.dy) ? -5 : 5),
              defaultAlign: (startPosition.dy > fanEndPosition.dy)
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              style: theme.labelStyle!,
            );
          }
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

  final List<List<Vector2>> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    if (super.hitTestLines(lines: _hitTestLinePoints, position: position)) {
      return true;
    }
    return false;
  }
}
