part of "../charts.dart";

GChart chartAreaGraph(GDataSource dataSource, String themeName, String target) {
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
          GGraphArea(
            valueKey: "high",
            baseValue: (target == "2") ? 200 : null,
            baseValueKey: (target == "3") ? "low" : null,
          ),
        ],
      ),
    ],
  );
}
