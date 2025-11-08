part of "../charts.dart";

GChart chartGuidePanel(GDataSource dataSource, String themeName) {
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
              marginStart: GSize.viewHeightRatio(0.3),
            ),
          ),
          GValueViewPort(
            id: "volumeViewPort",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["volume"],
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(),
          GValueAxis(
            id: "volume",
            viewPortId: "volumeViewPort",
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.none,
          ),
        ],
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          GGraphOhlc(ohlcValueKeys: const ["open", "high", "low", "close"]),
          GGraphBar(valueKey: "volume", valueViewPortId: "volumeViewPort"),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          followValueKey: "close",
          followValueViewPortId: "",
          dataKeys: ["open", "high", "low", "close", "volume"],
        ),
        // set the height weight of the panel to 0.7 (70% of the chart height).
        heightWeight: 0.7,
      ),
      // the second panel with its own valueViewPorts, axes, graphs and tooltip.
      GPanel(
        valueViewPorts: [
          GValueViewPort(
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["high", "low"],
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(),
          GValueAxis(id: "price2", position: GAxisPosition.start),
        ],
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          GGraphLine(valueKey: "close"),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          followValueKey: "close",
          followValueViewPortId: "",
          dataKeys: ["close"],
        ),
        heightWeight: 0.3,
      ),
    ],
  );
}
