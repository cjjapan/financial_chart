import 'dart:ui';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/graph/graph_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import '../../vector/vectors.dart';
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
    _hitTestLinePoints1.clear(); // value lines for hit test
    _hitTestLinePoints2.clear(); // base lines for hit test

    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();

    for (
      int point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      double? value = dataSource.getSeriesValue(
        point: point,
        key: graph.valueKey,
      );
      if (value == null || value.isNaN || value.isInfinite) {
        continue;
      }
      double valuePosition = valueViewPort.valueToPosition(area, value);
      double? baseValue;
      if (graph.baseValueKey != null) {
        // if baseValueKey is specified, use it to get the base value
        baseValue = dataSource.getSeriesValue(
          point: point,
          key: graph.baseValueKey!,
        );
        if (baseValue == null || baseValue.isNaN || baseValue.isInfinite) {
          continue; // skip if base value is not valid
        }
      } else {
        // if baseValue is specified use that value or use the bottom of the valueViewPort as base value
        baseValue = graph.baseValue ?? valueViewPort.startValue;
      }
      double basePosition = valueViewPort.valueToPosition(area, baseValue);
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      valuePoints.add(Offset(x, valuePosition));
      basePoints.add(Offset(x, basePosition));
      if (graph.highlighted && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, valuePosition));
        if (graph.baseValueKey != null || graph.baseValue != null) {
          highlightMarks.add(Vector2(x, basePosition));
        }
      }
    }

    if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
      _hitTestLinePoints1.addAll(valuePoints.map((e) => Vector2(e.dx, e.dy)));
      if (graph.baseValueKey != null || graph.baseValue != null) {
        _hitTestLinePoints2.addAll(basePoints.map((e) => Vector2(e.dx, e.dy)));
      }
    }

    // add intersection points between value line and base line
    if (valuePoints.isEmpty) {
      return;
    }
    _drawGraph(canvas, theme, valuePoints, basePoints);
    drawGraphHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  void _drawGraph(
    Canvas canvas,
    GGraphAreaTheme theme,
    List<Offset> valuePoints,
    List<Offset> basePoints,
  ) {
    final List<Offset> valueLinePoints = [];
    final List<Offset> baseLinePoints = [];
    final List<Offset> areaPoints = [];
    areaPoints.add(valuePoints.first);
    areaPoints.add(basePoints.first);
    valueLinePoints.add(valuePoints.first);
    baseLinePoints.add(basePoints.first);
    bool? isAbove;
    for (int i = 0; i < valuePoints.length; i++) {
      // find cross point of value line and base line so we can apply different style for above and below
      final Offset p1 = valuePoints[i];
      final Offset p3 = basePoints[i];
      if (isAbove == null && p1.dy != p3.dy) {
        isAbove = p1.dy < p3.dy;
      }

      Offset? intersection;
      Offset? p2, p4;
      if (i < valuePoints.length - 1) {
        p2 = valuePoints[i + 1];
        p4 = basePoints[i + 1];
        if (isAbove != null) {
          if (p2.dy == p4.dy) {
            intersection =
                p2; // if the next point is on the same level, we can use it as intersection
          } else {
            final bool isAboveNext = p2.dy < p4.dy;
            if (isAboveNext != isAbove) {
              // if the next point reverted the direction, we need to find the intersection point
              intersection = LineUtil.findIntersectionPointOfTwoLineSegments(
                p1,
                p2,
                p3,
                p4,
              );
            }
          }
        }
      }
      if (intersection == null) {
        // no intersection, just add the next points
        if (p2 != null && p4 != null) {
          areaPoints.insert(0, p2);
          areaPoints.add(p4);
          valueLinePoints.add(p2);
          baseLinePoints.add(p4);
          if (isAbove == null && p2.dy != p4.dy) {
            isAbove = p2.dy < p4.dy;
          }
        }
      } else {
        areaPoints.insert(0, intersection);
        areaPoints.add(intersection);
        valueLinePoints.add(intersection);
        baseLinePoints.add(intersection);
      }

      if (intersection != null || i == valuePoints.length - 1) {
        final style =
            (isAbove == true) ? theme.styleAboveBase : theme.styleBelowBase;
        isAbove = null;

        Path areaPath = addPolygonPath(points: areaPoints, close: true);
        drawPath(canvas: canvas, path: areaPath, style: style, fillOnly: true);

        Path valueLinesPath = addPolygonPath(
          points: valueLinePoints,
          close: false,
        );
        drawPath(
          canvas: canvas,
          path: valueLinesPath,
          style: style,
          strokeOnly: true,
        );
        if (theme.styleBaseLine != null) {
          Path baseLinesPath = addPolygonPath(
            points: baseLinePoints,
            close: false,
          );
          drawPath(
            canvas: canvas,
            path: baseLinesPath,
            style: theme.styleBaseLine ?? style,
            strokeOnly: true,
          );
        } else if (style.getStrokePaint() != null) {
          Path baseLinesPath = addPolygonPath(
            points: baseLinePoints,
            close: false,
          );
          drawPath(
            canvas: canvas,
            path: baseLinesPath,
            style: style,
            strokeOnly: true,
          );
        }
        if (intersection != null && p2 != null && p4 != null) {
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
    }
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
