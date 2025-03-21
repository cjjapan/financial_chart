import 'dart:ui';

import '../../../financial_chart.dart';

class GGraphGridsRender extends GGraphRender<GGraphGrids, GGraphGridsTheme> {
  const GGraphGridsRender();
  @override
  void doRenderGraph({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraphGrids graph,
    required Rect area,
    required GGraphGridsTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    final Path tickLinesPath = Path();
    graph.pointTickerStrategy
        .pointTicks(viewSize: area.width, viewPort: pointViewPort)
        .forEach((point) {
          double dx = pointViewPort.pointToPosition(area, point.toDouble());
          addLinePath(
            toPath: tickLinesPath,
            x1: dx,
            y1: area.top,
            x2: dx,
            y2: area.bottom,
          );
        });
    graph.valueTickerStrategy
        .valueTicks(viewSize: area.height, viewPort: valueViewPort)
        .forEach((value) {
          double dy = valueViewPort.valueToPosition(area, value);
          addLinePath(
            toPath: tickLinesPath,
            x1: area.left,
            y1: dy,
            x2: area.right,
            y2: dy,
          );
        });
    drawPath(canvas: canvas, path: tickLinesPath, style: theme.lineStyle);
  }
}
