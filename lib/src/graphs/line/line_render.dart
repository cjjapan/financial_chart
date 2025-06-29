import 'dart:typed_data';
import 'dart:ui';

import '../../chart.dart';
import '../../components/components.dart';
import '../../vector/vectors.dart';
import '../graphs.dart';

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

    final List<Vector2> linePoints = <Vector2>[];
    final List<Vector2> highlightMarks = <Vector2>[];
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    _hitTestLinePoints.clear();
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
      double x = pointViewPort.pointToPosition(area, point.toDouble());
      double y = valueViewPort.valueToPosition(area, value);
      linePoints.add(Vector2(x, y));
      if (graph.highlighted && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(x, y));
      }
    }

    final hitTestLinePoints = _drawGraph(
      canvas: canvas,
      area: area,
      theme: theme,
      linePoints: linePoints,
      smoothing: graph.smoothing,
    );

    if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
      _hitTestLinePoints.addAll(hitTestLinePoints);
    }

    drawGraphHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  // draw graph use raw styles in the theme (optimized batch draw)
  List<Vector2> _drawGraph({
    required Canvas canvas,
    required Rect area,
    required GGraphLineTheme theme,
    required List<Vector2> linePoints,
    required bool smoothing,
  }) {
    List<Vector2> resultLinePoints = [];
    Paint? linePaint = theme.lineStyle.getStrokePaint(
      gradientBounds: theme.lineStyle.gradientBounds ?? area,
    );
    Paint? pointStrokePaint = theme.pointStyle.getStrokePaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    Paint? pointFillPaint = theme.pointStyle.getFillPaint(
      gradientBounds: theme.pointStyle.gradientBounds ?? area,
    );
    if (pointFillPaint != null) {
      pointFillPaint.strokeWidth = theme.pointRadius * 2;
      pointFillPaint.style = PaintingStyle.fill;
      pointFillPaint.strokeCap = pointStrokePaint?.strokeCap ?? StrokeCap.round;
    }

    // batch draw line segments
    List<double> linesToDraw = [];
    if (smoothing) {
      final spline = SplineUtil.catmullRomSpline(linePoints, false);
      final splinePoints = SplineUtil.sampleSplines(spline, 10, false);
      for (int i = 0; i < splinePoints.length; i++) {
        linesToDraw.add(splinePoints[i].x);
        linesToDraw.add(splinePoints[i].y);
      }
      resultLinePoints.addAll(splinePoints);
    } else {
      for (int i = 0; i < linePoints.length; i++) {
        if (linePaint != null) {
          linesToDraw.add(linePoints[i].x);
          linesToDraw.add(linePoints[i].y);
        }
      }
      resultLinePoints.addAll(linePoints);
    }
    if (linePaint != null) {
      canvas.drawRawPoints(
        PointMode.polygon,
        Float32List.fromList(linesToDraw),
        linePaint,
      );
    }

    List<double> pointsToDraw = [];
    // batch draw points fill
    for (int i = 0; i < linePoints.length; i++) {
      if (theme.pointRadius > 0 &&
          theme.pointStyle.isNotEmpty &&
          i < linePoints.length - 1) {
        pointsToDraw.addAll([
          linePoints[i].x,
          linePoints[i].y,
          linePoints[i + 1].x,
          linePoints[i + 1].y,
        ]);
      }
    }
    if (pointFillPaint != null) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(pointsToDraw),
        pointFillPaint,
      );
    }

    // draw points stroke
    if (pointStrokePaint != null) {
      for (int i = 0; i < linePoints.length; i++) {
        canvas.drawCircle(
          Offset(linePoints[i].x, linePoints[i].y),
          theme.pointRadius,
          pointStrokePaint,
        );
      }
    }

    return resultLinePoints;
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
