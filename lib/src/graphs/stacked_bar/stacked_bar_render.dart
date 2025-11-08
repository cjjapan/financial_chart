import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import '../../../financial_chart.dart';

class GGraphStackedBarRender
    extends GGraphRender<GGraphStackedBar, GGraphStackedBarTheme> {
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphStackedBar graph,
    required Rect area,
    required GGraphStackedBarTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    final barWidth = pointViewPort.pointSize(area.width) * theme.barWidthRatio;

    // Calculate base position
    double? barBase;
    if (graph.baseValue != null) {
      barBase = min(
        max(graph.baseValue!, valueViewPort.startValue),
        valueViewPort.endValue,
      );
    } else if (graph.basePosition != null) {
      // Use basePosition to calculate the base value
      final valueRange = valueViewPort.endValue - valueViewPort.startValue;
      barBase =
          valueViewPort.startValue + (valueRange * (1.0 - graph.basePosition!));
    }

    _hitTestRectangles.clear();
    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();

    // Organize segments by style
    final segmentsByStyle = <int, List<Rect>>{};
    for (int i = 0; i < theme.barStyles.length; i++) {
      segmentsByStyle[i] = [];
    }

    for (
      int point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      double? previousValue = barBase;
      bool hasValidSegment = false;

      // Draw stacked segments
      for (int i = 0; i < graph.valueKeys.length; i++) {
        double? value = dataSource.getSeriesValue(
          point: point,
          key: graph.valueKeys[i],
        );

        if (value == null) {
          break; // Stop if any value in the stack is missing
        }

        double currentValue = value;
        if (previousValue != null) {
          double segmentBottom = valueViewPort.valueToPosition(
            area,
            previousValue,
          );
          double segmentTop = valueViewPort.valueToPosition(area, currentValue);

          final rect = Rect.fromLTRB(
            x - barWidth / 2,
            segmentTop,
            x + barWidth / 2,
            segmentBottom,
          );

          // Get the style index (cycle if not enough styles)
          int styleIndex = i;
          segmentsByStyle[styleIndex]!.add(rect);

          if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
            _hitTestRectangles.add(rect);
            _hitTestArea = graph.hitTestMode == GHitTestMode.area;
          }
          hasValidSegment = true;
        }
        previousValue = currentValue;
      }

      // Add highlight mark at the top of the stack
      if (hasValidSegment &&
          graph.highlighted &&
          (point % highlightIntervalPoints == 0)) {
        double topPosition = valueViewPort.valueToPosition(
          area,
          previousValue!,
        );
        highlightMarks.add(Vector2(x, topPosition));
      }
    }

    // Draw all segments grouped by style for better performance
    for (
      int styleIndex = 0;
      styleIndex < theme.barStyles.length;
      styleIndex++
    ) {
      final segments = segmentsByStyle[styleIndex]!;
      if (segments.isEmpty) continue;

      final style = theme.barStyles[styleIndex];
      if (style.isSimple) {
        _drawSegmentsSimple(canvas, style, segments, barWidth);
      } else {
        _drawSegments(canvas, style, segments);
      }
    }

    drawGraphHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  void _drawSegments(Canvas canvas, PaintStyle style, List<Rect> segments) {
    for (final segment in segments) {
      final Path segmentPath = Path()..addRect(segment);
      drawPath(canvas: canvas, path: segmentPath, style: style);
    }
  }

  void _drawSegmentsSimple(
    Canvas canvas,
    PaintStyle style,
    List<Rect> segments,
    double barWidth,
  ) {
    final bool drawBorder = style.getStrokePaint() != null;
    final bool drawBars = style.getFillPaint() != null;
    List<double> borderPoints = [];
    List<double> fillPoints = [];

    for (final segment in segments) {
      if (drawBorder) {
        borderPoints.addAll([
          ...[segment.left, segment.top, segment.left, segment.bottom],
          ...[segment.right, segment.top, segment.right, segment.bottom],
          ...[segment.left, segment.top, segment.right, segment.top],
          ...[segment.left, segment.bottom, segment.right, segment.bottom],
        ]);
      }
      if (drawBars) {
        fillPoints.addAll([
          segment.topCenter.dx,
          segment.topCenter.dy,
          segment.bottomCenter.dx,
          segment.bottomCenter.dy,
        ]);
      }
    }

    // Draw the rectangles
    if (fillPoints.isNotEmpty) {
      Paint fillPaint = Paint()
        ..color = style.fillColor ?? const Color.fromARGB(0, 0, 0, 0)
        ..style = PaintingStyle.fill
        ..strokeWidth = barWidth;
      canvas.drawRawPoints(
        PointMode.lines,
        Float32List.fromList(fillPoints),
        fillPaint,
      );
    }

    // Draw the rectangle borders
    if (borderPoints.isNotEmpty) {
      Paint borderPaint = Paint()
        ..color =
            (style.strokeColor ??
            style.fillColor ??
            const Color.fromARGB(0, 0, 0, 0))
        ..strokeWidth = min(max(1.0, style.strokeWidth ?? 0), barWidth)
        ..strokeCap = style.strokeCap ?? StrokeCap.round;
      canvas.drawRawPoints(
        PointMode.lines,
        Float32List.fromList(borderPoints),
        borderPaint,
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
