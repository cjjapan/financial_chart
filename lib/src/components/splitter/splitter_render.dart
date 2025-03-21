import 'dart:ui';

import '../../chart.dart';
import '../panel/panel.dart';
import '../render.dart';
import 'splitter.dart';
import 'splitter_theme.dart';

/// The render for [GSplitter].
class GSplitterRender extends GRender<GSplitter, GSplitterTheme> {
  const GSplitterRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GSplitter component,
    required Rect area,
    required GSplitterTheme theme,
  }) {
    final crossPosition =
        chart.crosshair.getCrossPosition() ??
        const Offset(double.infinity, double.infinity);
    for (int p = 0; p < chart.panels.length - 1; p++) {
      final panel = chart.panels[p];
      if (panel.splitterArea().contains(crossPosition) ||
          p == chart.controller.resizingPanelIndex) {
        if (panel.resizable && chart.panels[p + 1].resizable) {
          renderClipped(
            canvas: canvas,
            clipRect: area,
            render:
                () => doRenderSplitter(
                  canvas: canvas,
                  area: panel.splitterArea(),
                  theme: theme,
                ),
          );
        }
      }
    }
  }

  void doRenderSplitter({
    required Canvas canvas,
    required Rect area,
    required GSplitterTheme theme,
  }) {
    Offset center = area.center;
    double handleLineWidthHalf = theme.handleWidth * 0.5 * 0.6;
    double handleLineOffset = area.height * 0.2;

    Path linePath = Path();
    addLinePath(
      toPath: linePath,
      x1: area.left,
      y1: center.dy,
      x2: area.right,
      y2: center.dy,
    );
    drawPath(canvas: canvas, path: linePath, style: theme.lineStyle);

    Path rectPath = Path();
    addRectPath(
      toPath: rectPath,
      rect: Rect.fromCenter(
        center: center,
        width: theme.handleWidth,
        height: area.height,
      ),
      cornerRadius: theme.handleBorderRadius,
    );
    drawPath(canvas: canvas, path: rectPath, style: theme.handleStyle);

    Path handleLinesPath = Path();
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx - handleLineWidthHalf,
      y1: center.dy,
      x2: center.dx + handleLineWidthHalf,
      y2: center.dy,
    );
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx + handleLineWidthHalf,
      y1: center.dy - handleLineOffset,
      x2: center.dx - handleLineWidthHalf,
      y2: center.dy - handleLineOffset,
    );
    addLinePath(
      toPath: handleLinesPath,
      x1: center.dx + handleLineWidthHalf,
      y1: center.dy + handleLineOffset,
      x2: center.dx - handleLineWidthHalf,
      y2: center.dy + handleLineOffset,
    );
    drawPath(
      canvas: canvas,
      path: handleLinesPath,
      style: theme.handleLineStyle,
    );
  }
}
