import 'dart:math';
import 'dart:ui';

import '../../chart.dart';
import '../../values/range.dart';
import '../axis/axis.dart';
import '../graph/graph_theme.dart';
import '../panel/panel.dart';
import '../render.dart';
import '../graph/graph.dart';
import '../viewport_h.dart';
import '../viewport_v.dart';
import 'marker.dart';
import 'marker_theme.dart';

/// Base class for rendering a [GMarker].
///
/// This has different implementations from super [GRender] for it needs an extra [GGraph] parameter for rendering.
/// use [renderMarker] instead of super [GRender.render] to render a [GMarker].
abstract class GMarkerRender<M extends GMarker, T extends GMarkerTheme>
    extends GRender<M, T> {
  const GMarkerRender();

  void renderMarker({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GGraph<GGraphTheme> graph,
    required M marker,
    required Rect area,
    required T theme,
  }) {
    if (graph.visible == false || marker.visible == false) {
      return;
    }
    renderClipped(
      canvas: canvas,
      clipRect: area,
      render: () {
        final pointViewPort = chart.pointViewPort;
        final valueViewPort =
            panel!.findValueViewPortById(graph.valueViewPortId)!;
        if (!pointViewPort.isValid || !valueViewPort.isValid) {
          return;
        }
        doRenderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel,
          graph: graph,
          marker: marker,
          area: area,
          theme: theme,
          pointViewPort: pointViewPort,
          valueViewPort: valueViewPort,
        );
      },
    );
  }

  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
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
    throw UnimplementedError("should call renderMarker for GGraphMarker");
  }
}

/// Render for [GAxisMarker].
class GAxisMarkerRender extends GMarkerRender<GAxisMarker, GAxisMarkerTheme> {
  const GAxisMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GAxisMarker marker,
    required Rect area,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final pointViewPort = chart.pointViewPort;
    final valueViewPort = panel.findValueViewPortById(graph.valueViewPortId)!;
    if (marker.values.isNotEmpty || marker.valueRanges.isNotEmpty) {
      for (int a = 0; a < panel.valueAxes.length; a++) {
        final axis = panel.valueAxes[a];
        final axisArea = panel.valueAxisArea(a);
        if (axis.viewPortId == graph.valueViewPortId) {
          canvas.save();
          canvas.clipPath(Path()..addRect(axisArea));
          if (marker.valueRanges.isNotEmpty) {
            renderValueAxisRangeMarkers(
              canvas: canvas,
              chart: chart,
              panel: panel,
              axis: axis,
              axisArea: axisArea,
              valueRanges: marker.valueRanges,
              theme: theme,
              pointViewPort: pointViewPort,
              valueViewPort: valueViewPort,
            );
          }
          if (marker.values.isNotEmpty) {
            renderValueAxisLabelMarkers(
              canvas: canvas,
              chart: chart,
              panel: panel,
              axis: axis,
              axisArea: axisArea,
              values: marker.values,
              theme: theme,
              pointViewPort: pointViewPort,
              valueViewPort: valueViewPort,
            );
          }
          canvas.restore();
        }
      }
    }
    if (marker.points.isNotEmpty || marker.pointRanges.isNotEmpty) {
      for (int a = 0; a < panel.pointAxes.length; a++) {
        final axis = panel.pointAxes[a];
        final axisArea = panel.pointAxisArea(a);
        canvas.save();
        canvas.clipPath(Path()..addRect(axisArea));
        if (marker.pointRanges.isNotEmpty) {
          renderPointAxisRangeMarkers(
            canvas: canvas,
            chart: chart,
            panel: panel,
            axis: axis,
            axisArea: axisArea,
            pointRanges: marker.pointRanges,
            theme: theme,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          );
        }
        if (marker.points.isNotEmpty) {
          renderPointAxisLabelMarkers(
            canvas: canvas,
            chart: chart,
            panel: panel,
            axis: axis,
            axisArea: axisArea,
            points: marker.points,
            theme: theme,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          );
        }
        canvas.restore();
      }
    }
  }

  void renderValueAxisRangeMarkers({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GValueAxis axis,
    required Rect axisArea,
    required List<GRange> valueRanges,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    Path valueRangePath = Path();
    for (final range in valueRanges) {
      final bottom = valueViewPort.valueToPosition(axisArea, range.begin!);
      final top = valueViewPort.valueToPosition(axisArea, range.end!);
      addRectPath(
        toPath: valueRangePath,
        rect: Rect.fromLTRB(
          axisArea.left,
          max(top, axisArea.top),
          axisArea.right,
          min(bottom, axisArea.bottom),
        ),
      );
    }
    drawPath(
      canvas: canvas,
      path: valueRangePath,
      style: theme.valueRangeStyle!,
    );
  }

  void renderValueAxisLabelMarkers({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GValueAxis axis,
    required Rect axisArea,
    required List<double> values,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    for (final value in values) {
      final position = valueViewPort.valueToPosition(axisArea, value);
      final text = (axis.valueFormatter ?? chart.dataSource.seriesValueFormater)
          .call(value, valueViewPort.valuePrecision);
      drawValueAxisLabel(
        canvas: canvas,
        text: text,
        axis: axis,
        position: position,
        axisArea: axisArea,
        labelTheme: theme.valueAxisLabelTheme!,
      );
    }
  }

  void renderPointAxisRangeMarkers({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GPointAxis axis,
    required Rect axisArea,
    required List<GRange> pointRanges,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    Path pointRangePath = Path();
    for (final range in pointRanges) {
      final start = pointViewPort.pointToPosition(
        axisArea,
        range.begin!.toDouble(),
      );
      final end = pointViewPort.pointToPosition(
        axisArea,
        range.end!.toDouble(),
      );
      addRectPath(
        toPath: pointRangePath,
        rect: Rect.fromLTRB(
          max(start, axisArea.left),
          axisArea.top,
          min(end, axisArea.right),
          axisArea.bottom,
        ),
      );
    }
    drawPath(
      canvas: canvas,
      path: pointRangePath,
      style: theme.pointRangeStyle!,
    );
  }

  void renderPointAxisLabelMarkers({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GPointAxis axis,
    required Rect axisArea,
    required List<int> points,
    required GAxisMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    for (final point in points) {
      final position = pointViewPort.pointToPosition(
        axisArea,
        point.toDouble(),
      );
      final pointValue = chart.dataSource.getPointValue(point);
      if (pointValue == null) {
        continue;
      }
      final text = (axis.pointFormatter ?? chart.dataSource.pointValueFormater)
          .call(point, pointValue);
      drawPointAxisLabel(
        canvas: canvas,
        text: text,
        axis: axis,
        position: position,
        axisArea: axisArea,
        labelTheme: theme.pointAxisLabelTheme!,
      );
    }
  }
}

/// Base class for rendering a [GGraphMarker].
abstract class GGraphMarkerRender<
  M extends GGraphMarker,
  T extends GGraphMarkerTheme
>
    extends GMarkerRender<M, T> {
  const GGraphMarkerRender();
}
