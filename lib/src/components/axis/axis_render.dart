import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../marker/axis_marker.dart';
import '../panel/panel.dart';
import '../crosshair/crosshair_theme.dart';
import 'axis_theme.dart';
import 'axis.dart';
import '../render.dart';

/// Base renderer for axis components.
abstract class GAxisRender<C extends GAxis> extends GRender<C, GAxisTheme> {
  /// Creates an axis renderer.
  const GAxisRender();
}

/// Renderer for vertical value axes.
class GValueAxisRender extends GAxisRender<GValueAxis> {
  /// Creates a value axis renderer.
  const GValueAxisRender();

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GValueAxis component,
    required Rect area,
    required GAxisTheme theme,
  }) {
    final axis = component;
    final valueViewPort = panel!.findValueViewPortById(axis.viewPortId);
    if (!valueViewPort.isValid) {
      return;
    }
    final List<double> valueTicks = axis.valueTickerStrategy.valueTicks(
      viewSize: area.height,
      viewPort: valueViewPort,
    );

    Path linePath = addLinePath(
      x1: axis.isAlignLeft ? area.left : area.right,
      y1: area.top,
      x2: axis.isAlignLeft ? area.left : area.right,
      y2: area.bottom,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    Path tickLinesPath = Path();
    for (int i = 0; i < valueTicks.length; i++) {
      double value = valueTicks[i];
      double valuePosition = valueViewPort.valueToPosition(area, value);
      if (valuePosition.isNaN || valuePosition.isInfinite) {
        continue;
      }

      addLinePath(
        toPath: tickLinesPath,
        x1: axis.isAlignLeft ? area.left : (area.right - theme.tickerLength),
        y1: valuePosition,
        x2: axis.isAlignLeft ? (area.left + theme.tickerLength) : area.right,
        y2: valuePosition,
      );
      final labelText =
          (axis.valueFormatter ?? chart.dataSource.seriesValueFormater).call(
            value,
            valueViewPort.valuePrecision,
          );
      if (labelText.isNotEmpty) {
        drawValueAxisLabel(
          canvas: canvas,
          text: labelText,
          axis: axis,
          position: valuePosition,
          axisArea: area,
          labelTheme: theme.labelTheme,
        );
      }
    }
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.tickerStyle);

    // draw axis markers
    if (axis.axisMarkers.isNotEmpty) {
      final axisMarkers = [...axis.axisMarkers];
      axisMarkers.sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in axisMarkers) {
        if (marker is GValueAxisMarker) {
          marker.getRender().renderMarker(
            canvas: canvas,
            chart: chart,
            panel: panel,
            component: component,
            marker: marker,
            area: area,
            theme:
                marker.theme ??
                theme.axisMarkerTheme ??
                chart.theme.axisMarkerTheme,
            valueViewPort: valueViewPort,
          );
        }
      }
    }

    // draw overlay markers
    if (axis.overlayMarkers.isNotEmpty) {
      final overlayMarkers = [...axis.overlayMarkers];
      overlayMarkers.sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in overlayMarkers) {
        marker.getRender().renderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel,
          component: component,
          marker: marker,
          area: area,
          theme:
              marker.theme ??
              theme.overlayMarkerTheme ??
              chart.theme.overlayMarkerTheme,
          valueViewPort: valueViewPort,
        );
      }
    }

    // draw selected range
    if (valueViewPort.selectedRange.isNotEmpty) {
      Path selectedRangePath = addRectPath(
        rect: Rect.fromLTRB(
          area.left,
          valueViewPort.valueToPosition(
            area,
            valueViewPort.selectedRange.first!,
          ),
          area.right,
          valueViewPort.valueToPosition(
            area,
            valueViewPort.selectedRange.last!,
          ),
        ),
      );
      drawPath(
        canvas: canvas,
        path: selectedRangePath,
        style: theme.selectionStyle,
      );

      for (final rangeValue in [
        valueViewPort.selectedRange.first,
        valueViewPort.selectedRange.last,
      ]) {
        final value = rangeValue!;
        double valuePosition = valueViewPort.valueToPosition(area, value);
        final labelText =
            (axis.valueFormatter ?? chart.dataSource.seriesValueFormater).call(
              value,
              valueViewPort.valuePrecision,
            );
        if (labelText.isNotEmpty) {
          drawValueAxisLabel(
            canvas: canvas,
            text: labelText,
            axis: axis,
            position: valuePosition,
            axisArea: area,
            labelTheme:
                ((chart.crosshair.theme ?? chart.theme.crosshairTheme)
                        as GCrosshairTheme)
                    .valueLabelTheme,
          );
        }
      }
    }
  }
}

/// Renderer for horizontal point axes.
class GPointAxisRender extends GAxisRender<GPointAxis> {
  /// Creates a point axis renderer.
  const GPointAxisRender();

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GPointAxis component,
    required Rect area,
    required GAxisTheme theme,
  }) {
    final axis = component;
    final dataSource = chart.dataSource;
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    List<int> pointTicks = axis.pointTickerStrategy.pointTicks(
      viewSize: area.width,
      viewPort: pointViewPort,
    );

    Path linePath = addLinePath(
      x1: area.left,
      y1: component.isAlignTop ? area.top : area.bottom,
      x2: area.right,
      y2: component.isAlignTop ? area.top : area.bottom,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    Path tickLinesPath = Path();
    for (int i = 0; i < pointTicks.length; i++) {
      final point = pointTicks[i];
      final pointValue = dataSource.getPointValue(point);
      if (pointValue == null) {
        continue;
      }
      double pointPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );

      addLinePath(
        toPath: tickLinesPath,
        x1: pointPosition,
        y1: component.isAlignTop
            ? area.top
            : (area.bottom - theme.tickerLength),
        x2: pointPosition,
        y2: component.isAlignTop
            ? (area.top + theme.tickerLength)
            : area.bottom,
      );

      final labelText =
          (component.pointFormatter ?? chart.dataSource.pointValueFormater)
              .call(point, pointValue);
      if (labelText.isNotEmpty) {
        drawPointAxisLabel(
          canvas: canvas,
          text: labelText,
          axis: axis,
          position: pointPosition,
          axisArea: area,
          labelTheme: theme.labelTheme,
        );
      }
    }
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.tickerStyle);

    // draw axis markers
    if (axis.axisMarkers.isNotEmpty) {
      final axisMarkers = [...axis.axisMarkers];
      axisMarkers.sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in axisMarkers) {
        if (marker is GPointAxisMarker) {
          marker.getRender().renderMarker(
            canvas: canvas,
            chart: chart,
            panel: panel!,
            component: component,
            marker: marker,
            area: area,
            theme:
                marker.theme ??
                theme.axisMarkerTheme ??
                chart.theme.axisMarkerTheme,
          );
        }
      }
    }

    // draw overlay markers
    if (axis.overlayMarkers.isNotEmpty) {
      final overlayMarkers = [...axis.overlayMarkers];
      overlayMarkers.sort((a, b) => a.layer.compareTo(b.layer));
      for (final marker in overlayMarkers) {
        marker.getRender().renderMarker(
          canvas: canvas,
          chart: chart,
          panel: panel!,
          component: component,
          marker: marker,
          area: area,
          theme:
              marker.theme ??
              theme.overlayMarkerTheme ??
              chart.theme.overlayMarkerTheme,
        );
      }
    }

    // draw selected range
    if (pointViewPort.selectedRange.isNotEmpty) {
      Path selectedRangePath = addRectPath(
        rect: Rect.fromLTRB(
          pointViewPort.pointToPosition(
            area,
            pointViewPort.selectedRange.first!.toDouble(),
          ),
          area.top,
          pointViewPort.pointToPosition(
            area,
            pointViewPort.selectedRange.last!.toDouble(),
          ),
          area.bottom,
        ),
      );
      drawPath(
        canvas: canvas,
        path: selectedRangePath,
        style: theme.selectionStyle,
      );
      // draw selected range label
      for (final rangePoint in [
        pointViewPort.selectedRange.first,
        pointViewPort.selectedRange.last,
      ]) {
        final point = rangePoint!.round();
        final pointValue = dataSource.getPointValue(point);
        if (pointValue != null) {
          double pointPosition = pointViewPort.pointToPosition(
            area,
            point.toDouble(),
          );
          final labelText =
              (component.pointFormatter ?? chart.dataSource.pointValueFormater)
                  .call(point, pointValue);
          if (labelText.isNotEmpty) {
            drawPointAxisLabel(
              canvas: canvas,
              text: labelText,
              axis: axis,
              position: pointPosition,
              axisArea: area,
              labelTheme:
                  ((chart.crosshair.theme ?? chart.theme.crosshairTheme)
                          as GCrosshairTheme)
                      .pointLabelTheme,
            );
          }
        }
      }
    }
  }
}
