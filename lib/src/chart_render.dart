import 'package:flutter/material.dart';
import 'chart.dart';
import 'components/render_util.dart';

class GChartRender {
  const GChartRender();
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

  void renderBackground({required Canvas canvas, required GChart chart}) {
    chart.background.getRender().render(
      canvas: canvas,
      chart: chart,
      area: chart.area,
      component: chart.background,
      theme: chart.background.theme ?? chart.theme.backgroundTheme,
    );
  }

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

  void renderCrosshair({required Canvas canvas, required GChart chart}) {
    chart.crosshair.getRender().render(
      canvas: canvas,
      chart: chart,
      area: chart.area,
      component: chart.crosshair,
      theme: chart.crosshair.theme ?? chart.theme.crosshairTheme,
    );
  }

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
