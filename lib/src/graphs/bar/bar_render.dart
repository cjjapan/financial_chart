import 'dart:math';
import 'dart:ui';

import '../../../financial_chart.dart';

class GGraphBarRender extends GGraphRender<GGraphBar, GGraphBarTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphBar graph,
    required Rect area,
    required GGraphBarTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    final barWidth = pointViewPort.pointSize(area.width) * theme.barWidthRatio;
    final baseValue = min(
      max(
        graph.baseValue ?? valueViewPort.startValue,
        valueViewPort.startValue,
      ),
      valueViewPort.endValue,
    );
    double barBottom = valueViewPort.valueToPosition(area, baseValue);
    final Path barsAbovePath = Path();
    final Path barsBelowPath = Path();
    _hitTestRectangles.clear();
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
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      double barTop = valueViewPort.valueToPosition(area, value);
      final rect = Rect.fromLTRB(
        x - barWidth / 2,
        barTop,
        x + barWidth / 2,
        barBottom,
      );
      if (barTop <= barBottom) {
        barsAbovePath.reset();
        barsAbovePath.addRect(rect);
        drawPath(
          canvas: canvas,
          path: barsAbovePath,
          style: theme.barStyleAboveBase,
        );
      } else {
        barsBelowPath.reset();
        barsBelowPath.addRect(rect);
        drawPath(
          canvas: canvas,
          path: barsBelowPath,
          style: theme.barStyleBelowBase,
        );
      }
      if (graph.hitTestMode() != HitTestMode.none) {
        _hitTestRectangles.add(rect);
        _hitTestArea = graph.hitTestMode() == HitTestMode.area;
      }
      if (graph.highlight() && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, barTop));
      }
    }
    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  final List<Rect> _hitTestRectangles = [];
  bool _hitTestArea = false;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestRectangles.isEmpty) {
      return false;
    }
    for (var rect in _hitTestRectangles) {
      if (RectUtil.hitTest(
        x1: rect.left,
        y1: rect.top,
        x2: rect.right,
        y2: rect.bottom,
        px: position.dx,
        py: position.dy,
        epsilon: epsilon,
        testArea: _hitTestArea,
      )) {
        return true;
      }
    }
    return false;
  }
}
