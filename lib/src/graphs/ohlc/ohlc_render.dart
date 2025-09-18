import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_math/vector_math.dart';

import '../../chart.dart';
import '../../components/component.dart';
import '../../components/graph/graph_render.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'ohlc.dart';
import 'ohlc_theme.dart';

class GGraphOhlcRender extends GGraphRender<GGraphOhlc, GGraphOhlcTheme> {
  GGraphOhlcRender();
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphOhlc graph,
    required Rect area,
    required GGraphOhlcTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final dataSource = chart.dataSource;
    double barRenderWidth =
        pointViewPort.pointSize(area.width) * theme.barWidthRatio;
    _hitTestLines.clear();
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    final List<Vector2> highlightMarks = <Vector2>[];
    List<List<double>> graphValues = [];
    for (
      int point = pointViewPort.startPoint.floor();
      point <= pointViewPort.endPoint.ceil();
      point++
    ) {
      double? o = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[0],
      );
      double? h = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[1],
      );
      double? l = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[2],
      );
      double? c = dataSource.getSeriesValue(
        point: point,
        key: graph.ohlcValueKeys[3],
      );
      if (o == null || h == null || l == null || c == null) {
        continue;
      }
      double barPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );

      double op = valueViewPort.valueToPosition(area, o);
      double hp = valueViewPort.valueToPosition(area, h);
      double lp = valueViewPort.valueToPosition(area, l);
      double cp = valueViewPort.valueToPosition(area, c);
      graphValues.add([barPosition, op, hp, lp, cp]);

      if (chart.hitTestEnable && graph.hitTestMode != GHitTestMode.none) {
        if (graph.drawAsCandle) {
          _hitTestLines.addAll([
            [Vector2(barPosition, hp), Vector2(barPosition, lp)],
            [
              Vector2(barPosition - barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition + barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition + barRenderWidth / 2, max(op, cp)),
              Vector2(barPosition - barRenderWidth / 2, min(op, cp)),
              Vector2(barPosition - barRenderWidth / 2, max(op, cp)),
            ],
          ]);
        } else {
          _hitTestLines.addAll([
            [
              Vector2(barPosition - barRenderWidth / 2, op),
              Vector2(barPosition + barRenderWidth / 2, op),
            ],
            [Vector2(barPosition, hp), Vector2(barPosition, lp)],
            [
              Vector2(barPosition, cp),
              Vector2(barPosition + barRenderWidth / 2, cp),
            ],
          ]);
        }
      }
      if (graph.highlighted && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(barPosition, (hp + lp) / 2));
      }
    }

    if (graph.drawAsCandle) {
      _drawCandlesGraph(canvas, graph, theme, barRenderWidth, graphValues);
    } else {
      _drawOhlcGraph(canvas, graph, theme, barRenderWidth, graphValues);
    }

    drawGraphHighlightMarks(
      canvas: canvas,
      graph: graph,
      area: area,
      theme: theme,
      highlightMarks: highlightMarks,
    );
  }

  void _drawCandlesGraph(
    Canvas canvas,
    GGraphOhlc graph,
    GGraphOhlcTheme theme,
    double barRenderWidth,
    List<List<double>> graphValues,
  ) {
    if (theme.barStyleMinus.isSimple && theme.barStylePlus.isSimple) {
      // use batch drawing when possible
      List<double> borderPlus = [];
      List<double> borderMinus = [];
      List<double> fillPlus = [];
      List<double> fillMinus = [];

      final bool strokePlus =
          theme.barStylePlus.getStrokePaint() != null &&
          theme.barStylePlus.strokeColor != theme.barStylePlus.fillColor;
      final bool strokeMinus =
          theme.barStyleMinus.getStrokePaint() != null &&
          theme.barStyleMinus.strokeColor != theme.barStyleMinus.fillColor;
      for (int i = 0; i < graphValues.length; i++) {
        double x = graphValues[i][0];
        double x1 = x - barRenderWidth / 2;
        double x2 = x + barRenderWidth / 2;
        double open = graphValues[i][1]; // this is position not price value
        double high = graphValues[i][2];
        double low = graphValues[i][3];
        double close = graphValues[i][4];

        if (open >= close) {
          if (strokePlus) {
            // high and low and bar borders
            borderPlus.addAll([
              ...[x, high, x, close],
              ...[x, low, x, open],
              ...[x1, close, x2, close],
              ...[x1, open, x2, open],
              ...[x1, open, x1, close],
              ...[x2, close, x2, open],
            ]);
          } else {
            // high and low only
            borderPlus.addAll([
              ...[x, high, x, close],
              ...[x, low, x, open],
            ]);
          }
          if (theme.barStylePlus.getFillPaint() != null) {
            if ((open - close).abs() < 1) {
              // make sure a least 1 pixel is drawn
              final adjust = (1.0 - (open - close).abs()) * 0.5;
              fillPlus.addAll([x, open + adjust, x, close - adjust]);
            } else {
              fillPlus.addAll([x, open, x, close]);
            }
          }
        } else {
          if (strokeMinus) {
            // high and low and bar borders
            borderMinus.addAll([
              ...[x, high, x, open],
              ...[x, low, x, close],
              ...[x1, open, x2, open],
              ...[x1, close, x2, close],
              ...[x1, close, x1, open],
              ...[x2, open, x2, close],
            ]);
          } else {
            // high and low only
            borderMinus.addAll([
              ...[x, high, x, open],
              ...[x, low, x, close],
            ]);
          }
          if (theme.barStyleMinus.getFillPaint() != null) {
            if ((open - close).abs() < 1) {
              // make sure a least 1 pixel is drawn
              final adjust = (1.0 - (open - close).abs()) * 0.5;
              fillMinus.addAll([x, open - adjust, x, close + adjust]);
            } else {
              fillMinus.addAll([x, open, x, close]);
            }
          }
        }
      }
      // draw the bars
      if (fillPlus.isNotEmpty) {
        Paint fillPlusPaint = Paint()
          ..color =
              theme.barStylePlus.fillColor ?? const Color.fromARGB(0, 0, 0, 0)
          ..style = PaintingStyle.fill
          ..strokeWidth = barRenderWidth;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(fillPlus),
          fillPlusPaint,
        );
      }
      if (fillMinus.isNotEmpty) {
        Paint fillMinusPaint = Paint()
          ..color =
              theme.barStyleMinus.fillColor ?? const Color.fromARGB(0, 0, 0, 0)
          ..style = PaintingStyle.fill
          ..strokeWidth = barRenderWidth;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(fillMinus),
          fillMinusPaint,
        );
      }
      // draw the lines
      if (borderPlus.isNotEmpty) {
        Paint borderPlusPaint = Paint()
          ..color =
              (theme.barStylePlus.strokeColor ??
              theme.barStylePlus.fillColor ??
              const Color.fromARGB(0, 0, 0, 0))
          ..strokeWidth = min(
            max(1.0, theme.barStylePlus.strokeWidth ?? 1.0),
            barRenderWidth,
          )
          ..strokeCap = theme.barStylePlus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderPlus),
          borderPlusPaint,
        );
      }
      if (borderMinus.isNotEmpty) {
        Paint borderMinusPaint = Paint()
          ..color =
              (theme.barStyleMinus.strokeColor ??
              theme.barStyleMinus.fillColor ??
              const Color.fromARGB(0, 0, 0, 0))
          ..strokeWidth = min(
            max(1.0, theme.barStyleMinus.strokeWidth ?? 1.0),
            barRenderWidth,
          )
          ..strokeCap = theme.barStyleMinus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderMinus),
          borderMinusPaint,
        );
      }
      return;
    }
    for (int i = 0; i < graphValues.length; i++) {
      double barPosition = graphValues[i][0];
      double op = graphValues[i][1];
      double hp = graphValues[i][2];
      double lp = graphValues[i][3];
      double cp = graphValues[i][4];

      if (op >= cp) {
        Path fillPath = Path()
          ..moveTo(barPosition - barRenderWidth / 2, cp)
          ..lineTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition + barRenderWidth / 2, op)
          ..lineTo(barPosition + barRenderWidth / 2, cp)
          ..close();
        drawPath(
          canvas: canvas,
          path: fillPath,
          style: theme.barStylePlus,
          fillOnly: true,
        );
        Path strokePath = Path()
          ..moveTo(barPosition, hp)
          ..lineTo(barPosition, cp)
          ..lineTo(barPosition - barRenderWidth / 2, cp)
          ..lineTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition + barRenderWidth / 2, op)
          ..lineTo(barPosition + barRenderWidth / 2, cp)
          ..lineTo(barPosition, cp)
          ..moveTo(barPosition, op)
          ..lineTo(barPosition, lp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStylePlus,
          strokeOnly: true,
        );
      } else {
        Path fillPath = Path()
          ..moveTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition - barRenderWidth / 2, cp)
          ..lineTo(barPosition + barRenderWidth / 2, cp)
          ..lineTo(barPosition + barRenderWidth / 2, op)
          ..close();
        drawPath(
          canvas: canvas,
          path: fillPath,
          style: theme.barStyleMinus,
          fillOnly: true,
        );
        Path strokePath = Path()
          ..moveTo(barPosition, hp)
          ..lineTo(barPosition, op)
          ..lineTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition - barRenderWidth / 2, cp)
          ..lineTo(barPosition + barRenderWidth / 2, cp)
          ..lineTo(barPosition + barRenderWidth / 2, op)
          ..lineTo(barPosition, op)
          ..moveTo(barPosition, cp)
          ..lineTo(barPosition, lp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStyleMinus,
          strokeOnly: true,
        );
      }
    }
  }

  void _drawOhlcGraph(
    Canvas canvas,
    GGraphOhlc graph,
    GGraphOhlcTheme theme,
    double barRenderWidth,
    List<List<double>> graphValues,
  ) {
    if (theme.barStyleMinus.isSimple && theme.barStylePlus.isSimple) {
      List<double> borderPlus = [];
      List<double> borderMinus = [];
      for (int i = 0; i < graphValues.length; i++) {
        double x = graphValues[i][0];
        double x1 = x - barRenderWidth / 2;
        double x2 = x + barRenderWidth / 2;
        double open = graphValues[i][1]; // this is position not price value
        double high = graphValues[i][2];
        double low = graphValues[i][3];
        double close = graphValues[i][4];
        // ohlc needs only lines
        (open >= close ? borderPlus : borderMinus).addAll([
          ...[x1, open, x, open],
          ...[x, high, x, low],
          ...[x, close, x2, close],
        ]);
      }
      // batch draw the ohlc lines
      if (borderPlus.isNotEmpty) {
        Paint borderPlusPaint = Paint()
          ..color =
              (theme.barStylePlus.strokeColor ??
              theme.barStylePlus.fillColor ??
              const Color.fromARGB(0, 0, 0, 0))
          ..strokeWidth = min(
            max(1.0, theme.barStylePlus.strokeWidth ?? 1.0),
            barRenderWidth,
          )
          ..strokeCap = theme.barStylePlus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderPlus),
          borderPlusPaint,
        );
      }
      if (borderMinus.isNotEmpty) {
        Paint borderMinusPaint = Paint()
          ..color =
              (theme.barStyleMinus.strokeColor ??
              theme.barStyleMinus.fillColor ??
              const Color.fromARGB(0, 0, 0, 0))
          ..strokeWidth = min(
            max(1.0, theme.barStyleMinus.strokeWidth ?? 1.0),
            barRenderWidth,
          )
          ..strokeCap = theme.barStyleMinus.strokeCap ?? StrokeCap.round;
        canvas.drawRawPoints(
          PointMode.lines,
          Float32List.fromList(borderMinus),
          borderMinusPaint,
        );
      }
      return;
    }

    for (int i = 0; i < graphValues.length; i++) {
      double barPosition = graphValues[i][0];
      double op = graphValues[i][1];
      double hp = graphValues[i][2];
      double lp = graphValues[i][3];
      double cp = graphValues[i][4];

      if (op >= cp) {
        Path strokePath = Path()
          ..moveTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition, op)
          ..moveTo(barPosition, hp)
          ..lineTo(barPosition, lp)
          ..moveTo(barPosition, cp)
          ..lineTo(barPosition + barRenderWidth / 2, cp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStylePlus,
          strokeOnly: true,
        );
      } else {
        Path strokePath = Path()
          ..moveTo(barPosition - barRenderWidth / 2, op)
          ..lineTo(barPosition, op)
          ..moveTo(barPosition, hp)
          ..lineTo(barPosition, lp)
          ..moveTo(barPosition, cp)
          ..lineTo(barPosition + barRenderWidth / 2, cp);
        drawPath(
          canvas: canvas,
          path: strokePath,
          style: theme.barStyleMinus,
          strokeOnly: true,
        );
      }
    }
  }

  final List<List<Vector2>> _hitTestLines = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLines.isEmpty) {
      return false;
    }
    return super.hitTestLines(
      lines: _hitTestLines,
      position: position,
      epsilon: epsilon,
    );
  }
}
