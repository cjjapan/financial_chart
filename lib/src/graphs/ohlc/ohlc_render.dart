import 'dart:math';
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
    final Path linesPath = Path();
    final Path barsPath = Path();
    double barRenderWidth =
        pointViewPort.pointSize(area.width) * theme.barWidthRatio;
    _hitTestLines.clear();
    double highlightInterval = theme.highlightMarkerTheme?.interval ?? 1000.0;
    int highlightIntervalPoints =
        (highlightInterval / pointViewPort.pointSize(area.width)).round();
    final List<Vector2> highlightMarks = <Vector2>[];
    for (
      var point = pointViewPort.startPoint.floor();
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

      linesPath.reset();
      barsPath.reset();
      if (o < c) {
        if (graph.drawAsCandle) {
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: hp,
            x2: barPosition,
            y2: min(op, cp),
          );
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: max(op, cp),
            x2: barPosition,
            y2: lp,
          );
          drawPath(canvas: canvas, path: linesPath, style: theme.lineStylePlus);
          addRectPath(
            toPath: barsPath,
            rect: Rect.fromLTRB(
              barPosition - barRenderWidth / 2,
              cp,
              barPosition + barRenderWidth / 2,
              op,
            ),
          );
          drawPath(canvas: canvas, path: barsPath, style: theme.barStylePlus);
        } else {
          addLinePath(
            toPath: linesPath,
            x1: barPosition - barRenderWidth / 2,
            y1: op,
            x2: barPosition,
            y2: op,
          );
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: hp,
            x2: barPosition,
            y2: lp,
          );
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: cp,
            x2: barPosition + barRenderWidth / 2,
            y2: cp,
          );
          drawPath(canvas: canvas, path: linesPath, style: theme.lineStylePlus);
        }
      } else {
        if (graph.drawAsCandle) {
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: hp,
            x2: barPosition,
            y2: lp,
          );
          drawPath(
            canvas: canvas,
            path: linesPath,
            style: theme.lineStyleMinus,
          );
          addRectPath(
            toPath: barsPath,
            rect: Rect.fromLTRB(
              barPosition - barRenderWidth / 2,
              op,
              barPosition + barRenderWidth / 2,
              cp,
            ),
          );
          drawPath(canvas: canvas, path: barsPath, style: theme.barStyleMinus);
        } else {
          addLinePath(
            toPath: linesPath,
            x1: barPosition - barRenderWidth / 2,
            y1: cp,
            x2: barPosition,
            y2: cp,
          );
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: hp,
            x2: barPosition,
            y2: lp,
          );
          addLinePath(
            toPath: linesPath,
            x1: barPosition,
            y1: op,
            x2: barPosition + barRenderWidth / 2,
            y2: op,
          );
          drawPath(
            canvas: canvas,
            path: linesPath,
            style: theme.lineStyleMinus,
          );
        }
      }

      if (graph.hitTestMode() != HitTestMode.none) {
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
      if (graph.highlight() && (point % highlightIntervalPoints == 0)) {
        highlightMarks.add(Vector2(barPosition, (hp + lp) / 2));
      }
    }
    drawHighlightMarks(
      canvas: canvas,
      graph: graph,
      theme: theme,
      highlightMarks: highlightMarks,
    );
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
