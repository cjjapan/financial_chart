import 'dart:ui';

import 'package:vector_math/vector_math.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/graph/graph_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'area.dart';
import 'area_theme.dart';

class GGraphAreaRender extends GGraphRender<GGraphArea, GGraphAreaTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphArea graph,
    required Rect area,
    required GGraphAreaTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    // the area will be filled between the value line and the base line
    // if graph.baseValueKey being specified, the base line will be the value of the baseValueKey
    // else if graph.baseValue being specified, the base line will be the fix value
    // else the base line will be the bottom of the valueViewPort
    final List<Offset> valuePoints = [];
    final List<Offset> basePoints = [];
    _hitTestLinePoints1.clear();
    _hitTestLinePoints2.clear();

    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();

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
      double valuePosition = valueViewPort.valueToPosition(area, value);
      double? baseValue;
      if (graph.baseValueKey != null) {
        baseValue = dataSource.getSeriesValue(
          point: point,
          key: graph.baseValueKey!,
        );
      } else {
        baseValue = graph.baseValue ?? valueViewPort.startValue;
      }
      double basePosition = valueViewPort.valueToPosition(area, baseValue!);
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      valuePoints.add(Offset(x, valuePosition));
      basePoints.add(Offset(x, basePosition));
      if (graph.highlight() && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, valuePosition));
        if (graph.baseValueKey != null || graph.baseValue != null) {
          highlightMarks.add(Vector2(x, basePosition));
        }
      }
    }

    if (graph.hitTestMode() != HitTestMode.none) {
      _hitTestLinePoints1.addAll(valuePoints.map((e) => Vector2(e.dx, e.dy)));
      if (graph.baseValueKey != null || graph.baseValue != null) {
        _hitTestLinePoints2.addAll(basePoints.map((e) => Vector2(e.dx, e.dy)));
      }
    }

    final List<Offset> valueLinePoints = [];
    final List<Offset> baseLinePoints = [];
    final List<Offset> areaPoints = [];
    if (valuePoints.isNotEmpty) {
      areaPoints.add(valuePoints.first);
      areaPoints.add(basePoints.first);
      valueLinePoints.add(valuePoints.first);
      baseLinePoints.add(basePoints.first);
      for (int i = 0; i < valuePoints.length - 1; i++) {
        // find cross point of value line and base line so we can apply different style for above and below
        final Offset p1 = valuePoints[i];
        final Offset p2 = valuePoints[i + 1];
        final Offset p3 = basePoints[i];
        final Offset p4 = basePoints[i + 1];
        final intersection = findIntersectionPointOfTwoLineSegments(
          p1,
          p2,
          p3,
          p4,
        );
        if (intersection == null) {
          areaPoints.insert(0, p2);
          areaPoints.add(p4);
          valueLinePoints.add(p2);
          baseLinePoints.add(p4);
        } else {
          final isAbove = p1.dy < p3.dy;
          areaPoints.insert(0, intersection);
          areaPoints.add(intersection);
          valueLinePoints.add(intersection);
          baseLinePoints.add(intersection);

          Path areaPath = addPolygonPath(points: areaPoints, close: true);
          drawPath(
            canvas: canvas,
            path: areaPath,
            style: isAbove ? theme.styleAboveArea : theme.styleBelowArea,
          );
          Path valueLinesPath = addPolygonPath(
            points: valueLinePoints,
            close: false,
          );
          drawPath(
            canvas: canvas,
            path: valueLinesPath,
            style:
                isAbove ? theme.styleValueAboveLine : theme.styleValueBelowLine,
          );
          Path baseLinesPath = addPolygonPath(
            points: baseLinePoints,
            close: false,
          );
          drawPath(
            canvas: canvas,
            path: baseLinesPath,
            style: theme.styleBaseLine,
          );

          areaPoints
            ..clear()
            ..addAll([p2, intersection, p4]);
          valueLinePoints
            ..clear()
            ..addAll([intersection, p2]);
          baseLinePoints
            ..clear()
            ..addAll([intersection, p4]);
        }
      }
      if (areaPoints.isNotEmpty) {
        Path areaPath = addPolygonPath(points: areaPoints, close: true);
        drawPath(
          canvas: canvas,
          path: areaPath,
          style:
              valuePoints.last.dy < basePoints.last.dy
                  ? theme.styleAboveArea
                  : theme.styleBelowArea,
        );
        areaPoints.clear();
      }
      if (valueLinePoints.isNotEmpty) {
        Path valueLinesPath = addPolygonPath(
          points: valueLinePoints,
          close: false,
        );
        drawPath(
          canvas: canvas,
          path: valueLinesPath,
          style:
              valuePoints.last.dy < basePoints.last.dy
                  ? theme.styleValueAboveLine
                  : theme.styleValueBelowLine,
        );
        valueLinePoints.clear();
      }
      if (baseLinePoints.isNotEmpty) {
        Path baseLinesPath = addPolygonPath(
          points: baseLinePoints,
          close: false,
        );
        drawPath(
          canvas: canvas,
          path: baseLinesPath,
          style: theme.styleBaseLine,
        );
        baseLinePoints.clear();
      }

      drawHighlightMarks(
        canvas: canvas,
        graph: graph,
        theme: theme,
        highlightMarks: highlightMarks,
      );
    }
  }

  Offset? findIntersectionPointOfTwoLineSegments(
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
  ) {
    final double x1 = p1.dx;
    final double y1 = p1.dy;
    final double x2 = p2.dx;
    final double y2 = p2.dy;
    final double x3 = p3.dx;
    final double y3 = p3.dy;
    final double x4 = p4.dx;
    final double y4 = p4.dy;

    final double denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denominator == 0) {
      return null;
    }
    final double x =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
        denominator;
    final double y =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
        denominator;

    final intersection = Offset(x, y);
    if (x < p1.dx || x > p2.dx || x < p3.dx || x > p4.dx) {
      return null;
    }
    return intersection;
  }

  final List<Vector2> _hitTestLinePoints1 = [];
  final List<Vector2> _hitTestLinePoints2 = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints1.isEmpty && _hitTestLinePoints2.isEmpty) {
      return false;
    }
    // currently only support hit test for the border lines (HitTestMode.border
    return super.hitTestLines(
      lines: [_hitTestLinePoints1, _hitTestLinePoints2],
      position: position,
      epsilon: epsilon,
    );
  }
}
