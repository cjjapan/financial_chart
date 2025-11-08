part of "../charts.dart";

GChart chartGuideGraph(GDataSource dataSource, String themeName) {
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
              // Add a margin to the bottom of the candlestick graph to avoid overlapping with the volume graph.
              marginStart: GSize.viewHeightRatio(0.3),
            ),
          ),
          // Add a value viewport for volume graph and axis
          GValueViewPort(
            id: "volumeViewPort",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["volume"],
              // Add a margin to the top to avoid overlapping with the candlestick graph.
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        // Y Axes
        valueAxes: [
          GValueAxis(),
          // Add a value axis for volume
          GValueAxis(
            // set a id other than using the default one.
            id: "volume",
            // set the viewport id which should match the one defined in valueViewPorts.
            viewPortId: "volumeViewPort",
            // set the position of the axis to start (left side pf the graph).
            position: GAxisPosition.start,
            // disable scaling by dragging.
            scaleMode: GAxisScaleMode.none
          ),
        ],
        // X Axes
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          GGraphOhlc(ohlcValueKeys: const ["open", "high", "low", "close"]),
          // Add a volume graph with correct valueViewPortId and valueKey.
          GGraphBar(valueKey: "volume", valueViewPortId: "volumeViewPort"),
        ],
      ),
    ],
  );
}
