import 'dart:ui';

import 'package:vector_math/vector_math.dart';

import '../../chart.dart';
import '../panel/panel.dart';
import '../viewport_h.dart';
import '../viewport_v.dart';
import 'graph_theme.dart';
import 'graph.dart';
import '../render.dart';

/// Base class for [GGraph] renderers.
class GGraphRender<C extends GGraph, T extends GGraphTheme>
    extends GRender<C, T> {
  const GGraphRender();
  @override
  void render({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required C component,
    required Rect area,
    required T theme,
  }) {
    if (component.visible == false) {
      return;
    }
    assert(panel != null);
    // Render the graph (will call doRender in super)
    super.render(
      canvas: canvas,
      chart: chart,
      panel: panel,
      component: component,
      area: area,
      theme: theme,
    );

    // Render the markers
    if (component.overlayMarkers.isNotEmpty) {
      Rect area = panel!.graphArea();
      canvas.save();
      canvas.clipRect(area);
      doRenderMarkers(
        canvas: canvas,
        chart: chart,
        panel: panel,
        graph: component,
        area: area,
        theme: theme,
      );
      canvas.restore();
    }

    if (component.crosshairHighlightValueKeys.isNotEmpty) {
      Rect area = panel!.graphArea();
      canvas.save();
      canvas.clipRect(area);
      doRenderCrosshairHighlightValues(
        canvas: canvas,
        chart: chart,
        panel: panel,
        graph: component,
        area: area,
        theme: theme,
      );
      canvas.restore();
    }
  }

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required C component,
    required Rect area,
    required T theme,
  }) {
    assert(panel != null);
    if (component.visible == false) {
      return;
    }
    final graph = component;
    final pointViewPort = chart.pointViewPort;
    final valueViewPort = panel!.findValueViewPortById(graph.valueViewPortId);
    if (!pointViewPort.isValid || !valueViewPort.isValid) {
      return;
    }
    doRenderGraph(
      canvas: canvas,
      chart: chart,
      panel: panel,
      graph: component,
      area: area,
      theme: theme,
      pointViewPort: pointViewPort,
      valueViewPort: valueViewPort,
    );
  }

  void doRenderMarkers({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required C graph,
    required Rect area,
    required T theme,
  }) {
    if (graph.overlayMarkers.isNotEmpty) {
      final markers = [...graph.overlayMarkers];
      markers.sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in markers) {
        marker.getRender().renderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel,
          component: graph,
          marker: marker,
          area: panel.graphArea(),
          theme:
              (marker.theme ??
                  theme.overlayMarkerTheme ??
                  chart.theme.overlayMarkerTheme),
          valueViewPort: panel.findValueViewPortById(graph.valueViewPortId),
        );
      }
    }
  }

  void doRenderCrosshairHighlightValues({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required C graph,
    required Rect area,
    required T theme,
  }) {
    final crossPosition = chart.crosshair.getCrossPosition();
    if (crossPosition == null) {
      return;
    }
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final valueViewPort = panel.findValueViewPortById(graph.valueViewPortId);
    if (!valueViewPort.isValid) {
      return;
    }
    List<Vector2> crosshairHighlightMarks = [];
    for (final valueKey in graph.crosshairHighlightValueKeys) {
      final point = pointViewPort.nearestPoint(area, crossPosition);
      final pointPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );
      final value = chart.dataSource.getSeriesValue(
        point: point,
        key: valueKey,
      );
      if (value == null) {
        continue;
      }
      final valuePosition = valueViewPort.valueToPosition(area, value);
      crosshairHighlightMarks.add(Vector2(pointPosition, valuePosition));
    }
    if (crosshairHighlightMarks.isNotEmpty) {
      drawCrosshairHighlightMarks(
        canvas: canvas,
        graph: graph,
        theme: theme,
        highlightMarks: crosshairHighlightMarks,
      );
    }
  }

  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required C graph,
    required Rect area,
    required T theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    // override this method to render the graph
  }

  /// Draw the highlight marks (when hit test result is true).
  void drawGraphHighlightMarks({
    required Canvas canvas,
    required GGraph graph,
    required Rect area,
    required T theme,
    required List<Vector2> highlightMarks,
  }) {
    drawHighlightMarks(
      canvas: canvas,
      component: graph,
      area: area,
      highlightMarkerTheme: theme.highlightMarkerTheme,
      highlightMarks: highlightMarks,
    );
  }

  /// Draw the crosshair highlight marks (when the pointer moves).
  void drawCrosshairHighlightMarks({
    required Canvas canvas,
    required GGraph graph,
    required T theme,
    required List<Vector2> highlightMarks,
  }) {
    if (graph.visible &&
        highlightMarks.isNotEmpty &&
        theme.highlightMarkerTheme != null &&
        theme.highlightMarkerTheme!.crosshairHighlightSize > 0) {
      for (int i = 0; i < highlightMarks.length; i++) {
        final point = highlightMarks[i];
        final p = addOvalPath(
          rect: Rect.fromCircle(
            center: Offset(point.x, point.y),
            radius: theme.highlightMarkerTheme!.crosshairHighlightSize,
          ),
        );
        drawPath(
          canvas: canvas,
          path: p,
          style:
              theme.highlightMarkerTheme!.crosshairHighlightStyle ??
              theme.highlightMarkerTheme!.style,
        );
      }
    }
  }
}
