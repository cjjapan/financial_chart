part of "../charts.dart";

GChart chartLineGraph(GDataSource dataSource, String themeName, String target) {
  final theme = themeName == "dark" ? GThemeDark() : GThemeLight();
  return GChart(
    dataSource: dataSource,
    theme: theme,
    panels: [
      GPanel(
        valueViewPorts: [
          GValueViewPort(
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["high", "low"],
            ),
          ),
        ],
        valueAxes: [GValueAxis()],
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          GGraphLine(valueKey: "close", smoothing: target == "2"),
        ],
      ),
    ],
  );
}
