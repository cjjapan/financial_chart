import 'dart:math';

import 'package:flutter/painting.dart';

import '../../chart.dart';
import '../../values/pair.dart';
import '../panel/panel.dart';
import '../render.dart';
import '../render_util.dart';
import 'tooltip.dart';
import 'tooltip_theme.dart';

/// [GTooltip] renderer
class GTooltipRender extends GRender<GTooltip, GTooltipTheme> {
  const GTooltipRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GTooltip component,
    required Rect area,
    required GTooltipTheme theme,
  }) {
    final tooltip = component;
    if (tooltip.position == GTooltipPosition.none) {
      return;
    }
    final crossPosition = chart.crosshair.getCrossPosition();
    if (crossPosition == null) {
      return;
    }
    if (area.left > crossPosition.dx || area.right < crossPosition.dx) {
      return;
    }
    if (component.pointLineHighlightVisible ||
        component.valueLineHighlightVisible) {
      doRenderHighlight(
        canvas: canvas,
        chart: chart,
        panel: panel!,
        tooltip: tooltip,
        crossPosition: crossPosition,
        theme: theme,
      );
    }
    doRenderTooltip(
      canvas: canvas,
      chart: chart,
      panel: panel!,
      tooltip: tooltip,
      crossPosition: crossPosition,
      theme: theme,
    );
  }

  void doRenderHighlight({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GTooltip tooltip,
    required Offset crossPosition,
    required GTooltipTheme theme,
  }) {
    if (!tooltip.pointLineHighlightVisible &&
        !tooltip.valueLineHighlightVisible) {
      return;
    }
    if (theme.pointHighlightStyle == null &&
        theme.valueHighlightStyle == null) {
      return;
    }
    final area = panel.graphArea();
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final point = pointViewPort.nearestPoint(area, crossPosition);

    if (tooltip.pointLineHighlightVisible &&
        theme.pointHighlightStyle != null) {
      final pointPosition = pointViewPort.pointToPosition(
        area,
        point.toDouble(),
      );
      if (pointPosition.isNaN) {
        return;
      }
      final pointWidth = pointViewPort.pointSize(area.width);
      if (theme.pointHighlightStyle!.getFillPaint() == null) {
        // when fill paint not set, we draw highlight as line
        final highlightPath = addLinePath(
          x1: pointPosition,
          y1: area.top,
          x2: pointPosition,
          y2: area.bottom,
        );
        drawPath(
          canvas: canvas,
          path: highlightPath,
          style: theme.pointHighlightStyle!,
        );
      } else {
        // when fill paint was set, we draw highlight as area
        final highlightPath = addRectPath(
          rect: Rect.fromCenter(
            center: Offset(pointPosition, area.center.dy),
            width: pointWidth,
            height: area.height,
          ),
        );
        drawPath(
          canvas: canvas,
          path: highlightPath,
          style: theme.pointHighlightStyle!,
        );
      }
    }

    if (tooltip.valueLineHighlightVisible &&
        theme.valueHighlightStyle != null &&
        tooltip.followValueKey != null &&
        tooltip.followValueViewPortId != null) {
      final value = chart.dataSource.getSeriesValue(
        point: point,
        key: tooltip.followValueKey!,
      );
      if (value != null) {
        final valueViewPort = panel.findValueViewPortById(
          tooltip.followValueViewPortId!,
        );
        assert(valueViewPort != null);
        if (valueViewPort!.isValid) {
          final valuePosition = valueViewPort.valueToPosition(
            area,
            value.toDouble(),
          );
          final valueHighlightPath = addLinePath(
            x1: area.left,
            y1: valuePosition,
            x2: area.right,
            y2: valuePosition,
          );
          drawPath(
            canvas: canvas,
            path: valueHighlightPath,
            style: theme.valueHighlightStyle!,
          );
        }
      }
    }
  }

  void doRenderTooltip({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GTooltip tooltip,
    required Offset crossPosition,
    required GTooltipTheme theme,
  }) {
    if (tooltip.dataKeys.isEmpty) {
      return;
    }
    final tooltipPosition = tooltip.position;
    if (tooltipPosition == GTooltipPosition.none) {
      return;
    }
    final area = panel.graphArea();
    final dataSource = chart.dataSource;
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      return;
    }
    final point = pointViewPort.nearestPoint(area, crossPosition);
    final pointValue = dataSource.getPointValue(point);
    if (pointValue == null) {
      return;
    }
    Offset anchorPosition = Offset.zero;
    if (tooltipPosition == GTooltipPosition.topLeft) {
      anchorPosition = area.topLeft;
    } else if (tooltipPosition == GTooltipPosition.topRight) {
      anchorPosition = area.topRight;
    } else if (tooltipPosition == GTooltipPosition.bottomLeft) {
      anchorPosition = area.bottomLeft;
    } else if (tooltipPosition == GTooltipPosition.bottomRight) {
      anchorPosition = area.bottomRight;
    } else {
      // follow
      if (tooltip.followValueKey != null &&
          tooltip.followValueViewPortId != null) {
        double pointPosition = pointViewPort.pointToPosition(
          area,
          point.toDouble(),
        );
        anchorPosition = Offset(pointPosition, crossPosition.dy);
        final value = dataSource.getSeriesValue(
          point: point,
          key: tooltip.followValueKey!,
        );
        if (value != null) {
          final valueViewPort = panel.findValueViewPortById(
            tooltip.followValueViewPortId!,
          );
          assert(valueViewPort != null);
          final valuePosition = valueViewPort!.valueToPosition(
            area,
            value.toDouble(),
          );
          anchorPosition = Offset(pointPosition, valuePosition);
        }
      } else {
        anchorPosition = crossPosition;
      }
    }
    final dataKeyValues = dataSource.getSeriesValueAsMap(
      point: point,
      keys: tooltip.dataKeys,
    );
    if (dataKeyValues.isEmpty) {
      return;
    }
    double labelsWidth = 0;
    double valuesWidth = 0;
    double labelsHeight = 0;
    double valuesHeight = 0;
    List<GPair<TextPainter>> textPainters = [];
    for (var key in tooltip.dataKeys) {
      final prop = dataSource.getSeriesProperty(key);
      final label = prop.label;
      final value = dataKeyValues[key];
      final valueText =
          (value != null)
              ? dataSource.seriesValueFormater(value, prop.precision)
              : '';
      final (labelPainter, _, _) = GRenderUtil.createTextPainter(
        text: label,
        style: theme.labelStyle,
      );
      final (valuePainter, _, _) = GRenderUtil.createTextPainter(
        text: valueText,
        style: theme.valueStyle,
      );
      labelsWidth = max(labelsWidth, labelPainter.size.width);
      valuesWidth = max(valuesWidth, valuePainter.size.width);
      labelsHeight = labelsHeight + labelPainter.size.height + theme.rowSpacing;
      valuesHeight = valuesHeight + valuePainter.size.height + theme.rowSpacing;
      textPainters.add(GPair<TextPainter>.pair(labelPainter, valuePainter));
    }
    labelsHeight = labelsHeight - theme.rowSpacing;
    valuesHeight = valuesHeight - theme.rowSpacing;

    double frameWidth =
        labelsWidth +
        valuesWidth +
        theme.labelValueSpacing +
        theme.framePadding * 2 +
        theme.frameMargin * 2;
    double frameHeight =
        max(labelsHeight, valuesHeight) +
        theme.framePadding * 2 +
        theme.frameMargin * 2;

    Rect tooltipArea = Rect.fromPoints(
      anchorPosition,
      anchorPosition.translate(frameWidth, frameHeight),
    );
    if (tooltipArea.right > area.right) {
      anchorPosition = Offset(area.right - frameWidth, anchorPosition.dy);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    if (tooltipArea.bottom > area.bottom) {
      anchorPosition = Offset(anchorPosition.dx, area.bottom - frameHeight);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(frameWidth, frameHeight),
      );
    }
    final framePath = addRectPath(
      rect: tooltipArea.deflate(theme.frameMargin),
      cornerRadius: theme.frameCornerRadius,
    );
    drawPath(canvas: canvas, path: framePath, style: theme.frameStyle);

    Offset anchor = anchorPosition.translate(
      theme.framePadding + theme.frameMargin,
      theme.framePadding + theme.frameMargin,
    );
    for (var labelValuePair in textPainters) {
      labelValuePair.first!.paint(canvas, anchor);
      labelValuePair.last!.paint(
        canvas,
        anchor.translate(
          labelsWidth +
              theme.labelValueSpacing +
              valuesWidth -
              labelValuePair.last!.size.width,
          0,
        ),
      );
      anchor = anchor.translate(
        0,
        labelValuePair.first!.size.height + theme.rowSpacing,
      );
    }
  }
}
