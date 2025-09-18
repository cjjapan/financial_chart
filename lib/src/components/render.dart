import 'package:flutter/painting.dart';

import '../chart.dart';
import '../style/label_style.dart';
import '../style/paint_style.dart';
import '../vector/vectors.dart';
import 'components.dart';

const double kDefaultHitTestEpsilon = 5.0;

/// Base class for component renderers.
abstract class GRender<C extends GComponent, T extends GComponentTheme> {
  const GRender({this.hitTestEpsilon = kDefaultHitTestEpsilon});

  final double hitTestEpsilon;

  void render({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required C component,
    required Rect area,
    required T theme,
  }) {
    if (component.visible == false) {
      return;
    }
    renderClipped(
      canvas: canvas,
      clipRect: area,
      render: () => doRender(
        canvas: canvas,
        chart: chart,
        panel: panel,
        component: component,
        area: area,
        theme: theme,
      ),
    );
  }

  void renderClipped({
    required Canvas canvas,
    required Rect clipRect,
    required void Function() render,
  }) {
    GRenderUtil.renderClipped(
      canvas: canvas,
      clipRect: clipRect,
      render: render,
    );
  }

  void renderRotated({
    required Canvas canvas,
    required Offset center,
    required double theta,
    required void Function() render,
  }) {
    GRenderUtil.renderRotated(
      canvas: canvas,
      center: center,
      theta: theta,
      render: render,
    );
  }

  void drawPath({
    required Canvas canvas,
    required Path path,
    required PaintStyle style,
    bool ignoreDash = false,
    bool fillOnly = false,
    bool strokeOnly = false,
  }) {
    GRenderUtil.drawPath(
      canvas: canvas,
      path: path,
      style: style,
      ignoreDash: ignoreDash,
      fillOnly: fillOnly,
      strokeOnly: strokeOnly,
    );
  }

  Rect drawText({
    required Canvas canvas,
    required String text,
    Offset anchor = Offset.zero,
    Alignment defaultAlign = Alignment.center,
    required LabelStyle style,
  }) {
    return GRenderUtil.drawText(
      canvas: canvas,
      text: text,
      anchor: anchor,
      defaultAlign: defaultAlign,
      style: style,
    );
  }

  Rect drawValueAxisLabel({
    required Canvas canvas,
    required String text,
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return GRenderUtil.drawValueAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
  }

  Rect drawPointAxisLabel({
    required Canvas canvas,
    required String text,
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) {
    return GRenderUtil.drawPointAxisLabel(
      canvas: canvas,
      text: text,
      axis: axis,
      position: position,
      axisArea: axisArea,
      labelTheme: labelTheme,
    );
  }

  /// Draw the highlight marks (when hit test result is true).
  void drawHighlightMarks({
    required Canvas canvas,
    required GComponent component,
    required Rect area,
    required GGraphHighlightMarkerTheme? highlightMarkerTheme,
    required List<Vector2> highlightMarks,
  }) {
    if (component.visible &&
        component.highlighted &&
        highlightMarks.isNotEmpty &&
        highlightMarkerTheme != null &&
        highlightMarkerTheme.size > 0) {
      renderClipped(
        canvas: canvas,
        clipRect: area,
        render: () {
          for (int i = 0; i < highlightMarks.length; i++) {
            final point = highlightMarks[i];
            final p = addOvalPath(
              rect: Rect.fromCircle(
                center: Offset(point.x, point.y),
                radius: highlightMarkerTheme.size,
              ),
            );
            drawPath(
              canvas: canvas,
              path: p,
              style: highlightMarkerTheme.style,
            );
          }
        },
      );
    }
  }

  Offset getTextBlockPaintPoint(
    Offset axis,
    double width,
    double height,
    Alignment align,
  ) => GRenderUtil.getTextBlockPaintPoint(axis, width, height, align);

  Path addLinePath({
    Path? toPath,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) => GRenderUtil.addLinePath(toPath: toPath, x1: x1, y1: y1, x2: x2, y2: y2);

  Path addRectPath({
    Path? toPath,
    required Rect rect,
    double cornerRadius = 0,
  }) => GRenderUtil.addRectPath(
    toPath: toPath,
    rect: rect,
    cornerRadius: cornerRadius,
  );

  Path addOvalPath({
    Path? toPath,
    required Rect rect,
    double cornerRadius = 0,
  }) => GRenderUtil.addOvalPath(
    toPath: toPath,
    rect: rect,
    cornerRadius: cornerRadius,
  );

  Path addPolygonPath({
    Path? toPath,
    required List<Offset> points,
    required bool close,
    double cornerRadius = 0,
  }) => GRenderUtil.addPolygonPath(
    toPath: toPath,
    points: points,
    close: close,
    cornerRadius: cornerRadius,
  );

  Offset valueAxisLabelAnchor({
    required GValueAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) => GRenderUtil.valueAxisLabelAnchor(
    axis: axis,
    position: position,
    axisArea: axisArea,
    labelTheme: labelTheme,
  );

  Alignment valueAxisLabelAlignment({required GValueAxis axis}) =>
      GRenderUtil.valueAxisLabelAlignment(axis: axis);

  Offset pointAxisLabelAnchor({
    required GPointAxis axis,
    required double position,
    required Rect axisArea,
    required GAxisLabelTheme labelTheme,
  }) => GRenderUtil.pointAxisLabelAnchor(
    axis: axis,
    position: position,
    axisArea: axisArea,
    labelTheme: labelTheme,
  );

  Alignment pointAxisLabelAlignment({required GPointAxis axis}) =>
      GRenderUtil.pointAxisLabelAlignment(axis: axis);

  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required C component,
    required Rect area,
    required T theme,
  });

  bool hitTestLines({
    required List<List<Vector2>> lines,
    required Offset position,
    double? epsilon,
  }) {
    for (int i = 0; i < lines.length; i++) {
      if (PolygonUtil.hitTest(
        vertices: lines[i],
        px: position.dx,
        py: position.dy,
        epsilon: epsilon ?? hitTestEpsilon,
      )) {
        return true;
      }
    }
    return false;
  }

  bool hitTest({required Offset position, double? epsilon}) {
    return false;
  }
}

class GEmptyRender extends GRender<GComponent, GComponentTheme> {
  const GEmptyRender();

  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GComponent component,
    required Rect area,
    required GComponentTheme theme,
  }) {
    // Do nothing
  }
}
