import 'dart:math';
import 'dart:typed_data';
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
    _hitTestRectangles.clear();
    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    List<Rect> graphValuesAbove = [];
    List<Rect> graphValuesBelow = [];
    for (
      int point = pointViewPort.startPoint.floor();
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
        graphValuesAbove.add(rect);
      } else {
        graphValuesBelow.add(rect);
      }
      if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
        _hitTestRectangles.add(rect);
        _hitTestArea = graph.hitTestMode == GHitTestMode.area;
      }
      if (graph.highlighted && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, barTop));
      }
    }
    if (theme.barStyleAboveBase.isSimple) {
      _drawGraphSimple(
        canvas,
        graph,
        theme.barStyleAboveBase,
        graphValuesAbove,
        barWidth,
      );
    } else {
      _drawGraph(
        canvas,
        graph,
        theme.barStyleAboveBase,
        graphValuesAbove,
        barWidth,
      );
    }
    if (theme.barStyleBelowBase.isSimple) {
      _drawGraphSimple(
        canvas,
        graph,
        theme.barStyleBelowBase,
        graphValuesBelow,
        barWidth,
      );
    } else {
      _drawGraph(
        canvas,
        graph,
        theme.barStyleBelowBase,
        graphValuesBelow,
        barWidth,
      );
    }
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
    GGraphBar graph,
    PaintStyle barStyle,
    List<Rect> graphValues,
    double barWidth,
  ) {
    for (int i = 0; i < graphValues.length; i++) {
      final Path barsAbovePath = Path()..addRect(graphValues[i]);
      drawPath(canvas: canvas, path: barsAbovePath, style: barStyle);
    }
  }

  void _drawGraphSimple(
    Canvas canvas,
    GGraphBar graph,
    PaintStyle barStyle,
    List<Rect> graphValues,
    double barWidth,
  ) {
    final bool drawBorder = barStyle.getStrokePaint() != null;
    final bool drawBars = barStyle.getFillPaint() != null;
    List<double> borderPoints = [];
    List<double> fillPoints = [];
    for (int i = 0; i < graphValues.length; i++) {
      final bar = graphValues[i];
      if (drawBorder) {
        borderPoints.addAll([
          ...[bar.left, bar.top, bar.left, bar.bottom],
          ...[bar.right, bar.top, bar.right, bar.bottom],
          ...[bar.left, bar.top, bar.right, bar.top],
          ...[bar.left, bar.bottom, bar.right, bar.bottom],
        ]);
      }
      if (drawBars) {
        fillPoints.addAll([
          bar.topCenter.dx,
          bar.topCenter.dy,
          bar.bottomCenter.dx,
          bar.bottomCenter.dy,
        ]);
      }
    }
    // draw the rectangles
    if (fillPoints.isNotEmpty) {
      Paint fillAbovePaint = Paint()
        ..color = barStyle.fillColor ?? const Color.fromARGB(0, 0, 0, 0)
        ..style = PaintingStyle.fill
        ..strokeWidth = barWidth;
      canvas.drawRawPoints(
        PointMode.lines,
        Float32List.fromList(fillPoints),
        fillAbovePaint,
      );
    }
    // draw the rectangle borders
    if (borderPoints.isNotEmpty) {
      Paint borderAbovePaint = Paint()
        ..color =
            (barStyle.strokeColor ??
            barStyle.fillColor ??
            const Color.fromARGB(0, 0, 0, 0))
        ..strokeWidth = min(max(1.0, barStyle.strokeWidth ?? 0), barWidth)
        ..strokeCap = barStyle.strokeCap ?? StrokeCap.round;
      canvas.drawRawPoints(
        PointMode.lines,
        Float32List.fromList(borderPoints),
        borderAbovePaint,
      );
    }
  }

  final List<Rect> _hitTestRectangles = [];
  bool _hitTestArea = false;

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestRectangles.isEmpty) {
      return false;
    }
    for (final rect in _hitTestRectangles) {
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
