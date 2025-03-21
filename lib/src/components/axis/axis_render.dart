import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../panel/panel.dart';
import 'axis_theme.dart';
import 'axis.dart';
import '../render.dart';

abstract class GAxisRender<C extends GAxis> extends GRender<C, GAxisTheme> {
  const GAxisRender();
}

/// render for value axis lay on vertical direction.
class GValueAxisRender extends GAxisRender<GValueAxis> {
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
    final valueViewPort = panel!.findValueViewPortById(axis.viewPortId)!;
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

      addLinePath(
        toPath: tickLinesPath,
        x1: axis.isAlignLeft ? area.left : (area.right - theme.tickerLength),
        y1: valuePosition,
        x2: axis.isAlignLeft ? (area.left + theme.tickerLength) : area.right,
        y2: valuePosition,
      );
      final labelText = (axis.valueFormatter ??
              chart.dataSource.seriesValueFormater)
          .call(value, valueViewPort.valuePrecision);
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
    }
  }
}

/// render for point axis lay on horizontal direction.
class GPointAxisRender extends GAxisRender<GPointAxis> {
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
        y1:
            component.isAlignTop
                ? area.top
                : (area.bottom - theme.tickerLength),
        x2: pointPosition,
        y2:
            component.isAlignTop
                ? (area.top + theme.tickerLength)
                : area.bottom,
      );

      final labelText = (component.pointFormatter ??
              chart.dataSource.pointValueFormater)
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
    }
  }
}
