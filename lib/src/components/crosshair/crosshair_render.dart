import 'dart:ui';

import '../../chart.dart';
import '../panel/panel.dart';
import '../render.dart';
import 'crosshair.dart';
import 'crosshair_theme.dart';

/// The render for [GCrosshair].
class GCrosshairRender extends GRender<GCrosshair, GCrosshairTheme> {
  const GCrosshairRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GCrosshair component,
    required Rect area,
    required GCrosshairTheme theme,
  }) {
    final crosshair = component;
    final crossPosition = crosshair.getCrossPosition();
    if (crossPosition == null || !chart.pointViewPort.isValid) {
      return;
    }
    for (int i = 0; i < chart.panels.length; i++) {
      final panel = chart.panels[i];
      if (crosshair.pointLinesVisible || crosshair.valueLinesVisible) {
        doRenderPanelCrossLines(
          canvas: canvas,
          chart: chart,
          panel: panel,
          crosshair: crosshair,
          crossPosition: crossPosition,
          theme: theme,
        );
      }

      if (crosshair.pointAxisLabelsVisible) {
        doRenderPointAxisLabels(
          canvas: canvas,
          chart: chart,
          panel: panel,
          crosshair: crosshair,
          crossPosition: crossPosition,
          theme: theme,
        );
      }

      if (crosshair.valueAxisLabelsVisible) {
        doRenderValueAxisLabels(
          canvas: canvas,
          chart: chart,
          panel: panel,
          crosshair: crosshair,
          crossPosition: crossPosition,
          theme: theme,
        );
      }
    }
  }

  void doRenderPanelCrossLines({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GCrosshair crosshair,
    required Offset crossPosition,
    required GCrosshairTheme theme,
  }) {
    if (!crosshair.pointLinesVisible && !crosshair.valueLinesVisible) {
      return;
    }
    final linesPath = Path();
    final graphArea = panel.graphArea();
    if (crosshair.pointLinesVisible &&
        crossPosition.dx >= graphArea.left &&
        crossPosition.dx <= graphArea.right) {
      // vertical line
      double dx = crossPosition.dx;
      if (crosshair.snapToPoint) {
        final viewPortH = chart.pointViewPort;
        int point = viewPortH.nearestPoint(graphArea, crossPosition);
        dx = viewPortH.pointToPosition(graphArea, point.toDouble());
      }
      if (dx > graphArea.left && dx < graphArea.right) {
        addLinePath(
          toPath: linesPath,
          x1: dx,
          y1: graphArea.top,
          x2: dx,
          y2: graphArea.bottom,
        );
      }
    }
    if (crosshair.valueLinesVisible &&
        crossPosition.dy > graphArea.top &&
        crossPosition.dy < graphArea.bottom) {
      // value line
      addLinePath(
        toPath: linesPath,
        x1: graphArea.left,
        y1: crossPosition.dy,
        x2: graphArea.right,
        y2: crossPosition.dy,
      );
    }
    drawPath(canvas: canvas, path: linesPath, style: theme.lineStyle);
  }

  void doRenderPointAxisLabels({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GCrosshair crosshair,
    required Offset crossPosition,
    required GCrosshairTheme theme,
  }) {
    if (!crosshair.pointAxisLabelsVisible) {
      return;
    }
    final pointViewPort = chart.pointViewPort;
    for (int a = 0; a < panel.pointAxes.length; a++) {
      final pointAxis = panel.pointAxes[a];
      final axisArea = panel.pointAxisArea(a);
      if (axisArea.left > crossPosition.dx ||
          axisArea.right < crossPosition.dx) {
        continue;
      }
      final point = pointViewPort.nearestPoint(axisArea, crossPosition);
      final pointValue = chart.dataSource.getPointValue(point);
      if (pointValue != null) {
        final labelText =
            (pointAxis.pointFormatter ?? chart.dataSource.pointValueFormater)
                .call(point, pointValue);
        if (labelText.isNotEmpty) {
          drawPointAxisLabel(
            canvas: canvas,
            text: labelText,
            axis: pointAxis,
            position: crossPosition.dx,
            axisArea: axisArea,
            labelTheme: theme.pointLabelTheme,
          );
        }
      }
    }
  }

  void doRenderValueAxisLabels({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GCrosshair crosshair,
    required Offset crossPosition,
    required GCrosshairTheme theme,
  }) {
    if (!crosshair.valueAxisLabelsVisible) {
      return;
    }
    for (int a = 0; a < panel.valueAxes.length; a++) {
      final valueAxis = panel.valueAxes[a];
      final valueViewPort = panel.findValueViewPortById(valueAxis.viewPortId);
      final axisArea = panel.valueAxisArea(a);
      if (axisArea.top > crossPosition.dy ||
          axisArea.bottom < crossPosition.dy) {
        continue;
      }
      final value = valueViewPort.positionToValue(axisArea, crossPosition.dy);
      final labelText =
          (valueAxis.valueFormatter ?? chart.dataSource.seriesValueFormater)
              .call(value, valueViewPort.valuePrecision);
      if (labelText.isNotEmpty) {
        drawValueAxisLabel(
          canvas: canvas,
          text: labelText,
          axis: valueAxis,
          position: crossPosition.dy,
          axisArea: axisArea,
          labelTheme: theme.valueLabelTheme,
        );
      }
    }
  }
}
