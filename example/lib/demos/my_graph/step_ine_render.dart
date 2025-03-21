import 'dart:ui';

import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';

import 'step_line.dart';
import 'step_line_theme.dart';

class GGraphStepLineRender
    extends GGraphRender<GGraphStepLine, GGraphStepLineTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphStepLine graph,
    required Rect area,
    required GGraphStepLineTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    final Path upLinesPath = Path();
    final Path downLinesPath = Path();

    double previousX = double.nan;
    double previousY = double.nan;
    for (
      var point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      double? value = dataSource.getSeriesValue(
        point: point,
        key: graph.valueKey,
      );
      if (value == null) {
        continue;
      }
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      double y = valueViewPort.valueToPosition(area, value);
      if (!previousX.isNaN && point % graph.pointInterval == 0) {
        addLinePath(
          toPath: (y < previousY) ? upLinesPath : downLinesPath,
          x1: previousX,
          y1: previousY,
          x2: x,
          y2: previousY,
        );
        addLinePath(
          toPath: (y < previousY) ? upLinesPath : downLinesPath,
          x1: x,
          y1: previousY,
          x2: x,
          y2: y,
        );
      }
      if (point % graph.pointInterval == 0) {
        previousX = x;
        previousY = y;
      }
    }
    drawPath(canvas: canvas, path: upLinesPath, style: theme.lineUpStyle);
    drawPath(canvas: canvas, path: downLinesPath, style: theme.lineDownStyle);
  }
}
