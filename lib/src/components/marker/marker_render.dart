import 'dart:ui';

import '../../chart.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../render.dart';
import 'marker.dart';
import 'marker_theme.dart';
import '../viewport_v.dart';
import '../viewport_h.dart';

/// Base renderer for marker components.
abstract class GMarkerRender<M extends GMarker, T extends GMarkerTheme>
    extends GRender<M, T> {
  /// Creates a marker renderer.
  const GMarkerRender();

  /// Renders a marker with additional context parameters.
  void renderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required M marker,
    required Rect area,
    required T theme,
    GValueViewPort? valueViewPort,
  }) {
    if (!component.visible || !marker.visible) {
      return;
    }
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final validValueViewPort = valueViewPort ?? panel.valueViewPorts.first;
    if (!validValueViewPort.isValid) {
      return;
    }
    renderClipped(
      canvas: canvas,
      clipRect: area,
      render: () => doRenderMarker(
        canvas: canvas,
        chart: chart,
        panel: panel,
        component: component,
        marker: marker,
        area: area,
        theme: theme,
        pointViewPort: pointViewPort,
        valueViewPort: validValueViewPort,
      ),
    );
  }

  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required M marker,
    required Rect area,
    required T theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  });

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required M component,
    required Rect area,
    required T theme,
  }) {
    throw UnimplementedError("should call renderMarker for GMarkerRender");
  }
}
