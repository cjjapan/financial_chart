import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../financial_chart.dart';

class GGraphLineRender extends GGraphRender<GGraphLine, GGraphLineTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphLine graph,
    required Rect area,
    required GGraphLineTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    final Path tickLinesPath = Path();

    final List<Vector2> points = <Vector2>[];
    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    _hitTestLinePoints.clear();
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
      points.add(Vector2(x, y));
      if (graph.highlight() && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, y));
      }
    }
    for (int i = 0; i < points.length - 1; i++) {
      addLinePath(
        toPath: tickLinesPath,
        x1: points[i].x,
        y1: points[i].y,
        x2: points[i + 1].x,
        y2: points[i + 1].y,
      );
    }
    if (graph.hitTestMode() != HitTestMode.none) {
      _hitTestLinePoints.addAll(points);
    }
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.lineStyle);

    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  final List<Vector2> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    return super.hitTestLines(
      lines: [_hitTestLinePoints],
      position: position,
      epsilon: epsilon,
    );
  }
}
