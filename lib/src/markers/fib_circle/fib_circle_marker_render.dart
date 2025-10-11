import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/painting.dart';

class GFibCircleMarkerRender
    extends GOverlayMarkerRender<GFibCircleMarker, GOverlayMarkerTheme> {
  GFibCircleMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GFibCircleMarker marker,
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
    _center = startPosition;
    _radii.clear();

    super.controlHandles.clear();
    if (valueViewPort.isValid && pointViewPort.isValid) {
      // draw circles at fibonacci levels
      for (double level in marker.fibLevels) {
        final radius = (endPosition - startPosition).distance * level;
        final path = Path()
          ..addOval(
            Rect.fromCircle(
              center: startPosition,
              radius: radius <= 0 ? 2 : radius,
            ),
          );
        drawPath(
          canvas: canvas,
          path: path,
          style: theme.markerStyle.copyWith(fillColor: Color(0x00000000)),
        );
        _radii.add(radius);
        // add control handle for each circle
        if (chart.hitTestEnable && marker.hitTestEnable) {
          super.controlHandles.addAll({
            "$level": GControlHandle(
              position: Offset(startPosition.dx + radius, startPosition.dy),
              type: GControlHandleType.resize,
            ),
          });
        }
      }
      // draw labels
      for (double level in marker.fibLevels) {
        final radius = (endPosition - startPosition).distance * level;
        final labelPos = Offset(startPosition.dx, startPosition.dy + radius);
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

  Offset _center = Offset.zero;
  final List<double> _radii = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    for (double radius in _radii) {
      final dist = (position - _center).distance;
      if ((dist - radius).abs() <= (epsilon ?? 5.0)) {
        return true;
      }
    }
    return false;
  }
}
