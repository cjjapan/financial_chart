import 'package:flutter/widgets.dart';
import 'chart.dart';
import 'components/render_util.dart';

/// Renderer for chart components.
class GChartRender {
  /// Creates a chart renderer.
  const GChartRender();

  /// Renders the chart on the given canvas.
  void render({required Canvas canvas, required GChart chart}) {
    GRenderUtil.renderClipped(
      canvas: canvas,
      clipRect: chart.area,
      render: () {
        renderBackground(canvas: canvas, chart: chart);
        renderPanels(canvas: canvas, chart: chart);
        if (chart.dataSource.isNotEmpty) {
          renderCrosshair(canvas: canvas, chart: chart);
        }
        renderSplitters(canvas: canvas, chart: chart);
      },
    );
  }

  /// Renders the background component.
  void renderBackground({required Canvas canvas, required GChart chart}) {
    chart.background.getRender().render(
      canvas: canvas,
      chart: chart,
      area: chart.area,
      component: chart.background,
      theme: chart.background.theme ?? chart.theme.backgroundTheme,
    );
  }

  /// Renders all panel components.
  void renderPanels({required Canvas canvas, required GChart chart}) {
    for (int p = 0; p < chart.panels.length; p++) {
      final panel = chart.panels[p];
      panel.getRender().render(
        canvas: canvas,
        chart: chart,
        panel: panel,
        area: panel.panelArea(),
        component: panel,
        theme: panel.theme ?? chart.theme.panelTheme,
      );
    }
  }

  /// Renders the crosshair component.
  void renderCrosshair({required Canvas canvas, required GChart chart}) {
    chart.crosshair.getRender().render(
      canvas: canvas,
      chart: chart,
      area: chart.area,
      component: chart.crosshair,
      theme: chart.crosshair.theme ?? chart.theme.crosshairTheme,
    );
  }

  /// Renders all splitter components.
  void renderSplitters({required Canvas canvas, required GChart chart}) {
    chart.splitter.getRender().render(
      canvas: canvas,
      chart: chart,
      area: chart.area,
      component: chart.splitter,
      theme: chart.splitter.theme ?? chart.theme.splitterTheme,
    );
  }
}
