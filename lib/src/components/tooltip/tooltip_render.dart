import 'package:flutter/widgets.dart';

import '../../chart.dart';
import '../components.dart';

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
      _removeWidget(chart);
      return;
    }
    final crossPosition = chart.crosshair.getCrossPosition();
    if (crossPosition == null) {
      _removeWidget(chart);
      return;
    }
    if (area.left > crossPosition.dx || area.right < crossPosition.dx) {
      _removeWidget(chart);
      return;
    }
    if (!chart.pointViewPort.isValid ||
        chart.pointViewPort.isAnimating ||
        chart.isScaling ||
        chart.splitter.resizingPanelIndex != null) {
      // skip rendering if point view port is animating or scaling or resizing a panel
      _removeWidget(chart);
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
        if (valueViewPort.isValid) {
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
      _removeWidget(chart, tooltip);
      return;
    }
    final tooltipPosition = tooltip.position;
    if (tooltipPosition == GTooltipPosition.none) {
      _removeWidget(chart, tooltip);
      return;
    }
    final area = panel.graphArea();
    final dataSource = chart.dataSource;
    final pointViewPort = chart.pointViewPort;
    if (!pointViewPort.isValid) {
      _removeWidget(chart, tooltip);
      return;
    }
    final point = pointViewPort.nearestPoint(area, crossPosition);
    final pointValue = dataSource.getPointValue(point);
    if (pointValue == null) {
      _removeWidget(chart, tooltip);
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
          final valuePosition = valueViewPort.valueToPosition(
            area,
            value.toDouble(),
          );
          anchorPosition = Offset(pointPosition, valuePosition);
        }
      } else {
        anchorPosition = crossPosition;
      }
    }
    if (tooltip.tooltipNotifier != null) {
      WidgetsBinding.instance.addPostFrameCallback((f) {
        tooltip.tooltipNotifier?.value = GToolTipWidgetContext(
          panel: panel,
          area: area,
          tooltip: tooltip,
          point: point,
          anchorPosition: anchorPosition,
        );
      });
      return;
    }
    final dataKeyValues = dataSource.getSeriesValueAsMap(
      point: point,
      keys: tooltip.dataKeys,
    );
    if (dataKeyValues.isEmpty) {
      return;
    }

    List<List<GTableItemPainter>> texts = [];
    List<GTableItemSpanPainter> spanTexts = [];
    if (tooltip.showPointValue) {
      texts.add([
        GTablePlaceHolderItemPainter(),
        GTablePlaceHolderItemPainter(),
      ]);
      spanTexts.add(
        GTableItemSpanPainter(
          rowStart: 0,
          rowEnd: 0,
          colStart: 0,
          colEnd: 1,
          item: GTableTextItemPainter(
            text: dataSource.pointValueFormater(point, pointValue),
            style: theme.pointStyle.textStyle!,
            alignment: theme.pointStyle.align ?? Alignment.centerLeft,
            padding: EdgeInsets.fromLTRB(0, 0, 0, theme.pointRowSpacing),
          ),
        ),
      );
    }
    for (final key in tooltip.dataKeys) {
      final prop = dataSource.getSeriesProperty(key);
      final label = prop.label;
      final value = dataKeyValues[key];
      final valueText =
          (value != null)
              ? (prop.valueFormater != null)
                  ? prop.valueFormater!(value)
                  : dataSource.seriesValueFormater(value, prop.precision)
              : '';
      texts.add([
        GTableTextItemPainter(
          text: label,
          style: theme.labelStyle.textStyle!,
          alignment: theme.labelStyle.align ?? Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(
            0,
            tooltip.showPointValue ? theme.rowSpacing : 0,
            theme.labelValueSpacing,
            0,
          ),
        ),
        GTableTextItemPainter(
          text: valueText,
          style: theme.valueStyle.textStyle!,
          alignment: theme.valueStyle.align ?? Alignment.centerRight,
          padding: EdgeInsets.fromLTRB(
            0,
            tooltip.showPointValue ? theme.rowSpacing : 0,
            0,
            0,
          ),
        ),
      ]);
    }

    GTableLayoutPainter tablePainter = GTableLayoutPainter(
      items: texts,
      spanItems: spanTexts,
      padding: EdgeInsets.all(theme.framePadding),
      margin: EdgeInsets.all(theme.frameMargin),
      blockCornerRadius: theme.frameCornerRadius,
      blockStyle: theme.frameStyle,
      anchor: anchorPosition,
      alignment: Alignment.bottomRight,
    );
    final size = tablePainter.size;
    final ttWidth = size.width;
    final ttHeight = size.height;

    Rect tooltipArea = Rect.fromPoints(
      anchorPosition,
      anchorPosition.translate(ttWidth, ttHeight),
    );
    if (tooltipArea.right > area.right) {
      anchorPosition = Offset(area.right - ttWidth, anchorPosition.dy);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(ttWidth, ttHeight),
      );
    }
    if (tooltipArea.bottom > area.bottom) {
      anchorPosition = Offset(anchorPosition.dx, area.bottom - ttHeight);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(ttWidth, ttHeight),
      );
    }
    if (tooltipArea.top < area.top) {
      anchorPosition = Offset(anchorPosition.dx, area.top);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(ttWidth, ttHeight),
      );
    }
    if (tooltipArea.left < area.left) {
      anchorPosition = Offset(area.left, anchorPosition.dy);
      tooltipArea = Rect.fromPoints(
        anchorPosition,
        anchorPosition.translate(ttWidth, ttHeight),
      );
    }
    tablePainter.paint(canvas, forceOffset: anchorPosition);
  }

  void _removeWidget(GChart chart, [GTooltip? tooltip]) {
    if (tooltip != null && tooltip.tooltipNotifier == null) {
      return;
    }
    final panels = chart.panels.where(
      (p) => p.tooltip?.tooltipNotifier != null,
    );
    if (panels.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((f) {
      for (final panel in panels) {
        if (panel.tooltip?.tooltipNotifier != null) {
          panel.tooltip!.tooltipNotifier!.value = null;
        }
      }
    });
  }
}
