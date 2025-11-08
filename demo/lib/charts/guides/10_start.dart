

part of "../charts.dart";

GChart chartGuideStart(GDataSource dataSource, String themeName) {
  final theme = themeName == "dark" ? GThemeDark() : GThemeLight();
  return GChart(
    // the data source for the chart.
    dataSource: dataSource,
    // the theme.
    theme: theme,
    // One or more panels.
    panels: [
      GPanel(
        valueViewPorts: [
          // A value viewport controls visible range along Y axis.
          // It is being used by axes and graphs to render on canvas correctly.
          GValueViewPort(
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["high", "low"],
            ),
          ),
        ],
        // Y Axes
        valueAxes: [GValueAxis()],
        // X Axes
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          // valuesKeys should be valid keys defined in dataSource seriesProperties.
          GGraphOhlc(ohlcValueKeys: const ["open", "high", "low", "close"]),
        ],
      ),
    ],
  );
}
