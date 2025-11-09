part of "../charts.dart";

GChart chartStackedBarGraph(
    GDataSource dataSource, String themeName, String target) {
  final theme = themeName == "dark" ? GThemeDark() : GThemeLight();
  final isDark = themeName == "dark";

  // Define colors for different segments
  final buyColor = isDark ? Color(0xFF4CAF50) : Color(0xFF2E7D32);
  final sellColor = isDark ? Color(0xFFEF5350) : Color(0xFFC62828);
  final neutralColor = isDark ? Color(0xFF90CAF9) : Color(0xFF1976D2);

  // Create paint styles for segments
  final barStyles = [
    PaintStyle(fillColor: buyColor, strokeColor: buyColor),
    PaintStyle(fillColor: sellColor, strokeColor: sellColor),
    PaintStyle(fillColor: neutralColor, strokeColor: neutralColor),
  ];

  switch (target) {
    case "1":
      // Example 1: Basic stacked bar with volume data
      return GChart(
        dataSource: dataSource,
        theme: theme,
        panels: [
          GPanel(
            valueViewPorts: [
              GValueViewPort(
                valuePrecision: 0,
                autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                  dataKeys: ["volume"],
                ),
              ),
            ],
            valueAxes: [GValueAxis()],
            pointAxes: [GPointAxis()],
            graphs: [
              GGraphGrids(),
              GGraphStackedBar(
                valueKeys: ["buyVolume", "sellVolume", "neutralVolume"],
                theme: GGraphStackedBarTheme(
                  barStyles: barStyles,
                  barWidthRatio: 0.8,
                ),
                basePosition: 1.0,
              ),
            ],
          ),
        ],
      );

    case "2":
      // Example 2: Stacked bar with baseValue
      return GChart(
        dataSource: dataSource,
        theme: theme,
        panels: [
          GPanel(
            valueViewPorts: [
              GValueViewPort(
                valuePrecision: 0,
                autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                  dataKeys: ["volume"],
                ),
              ),
            ],
            valueAxes: [GValueAxis()],
            pointAxes: [GPointAxis()],
            graphs: [
              GGraphGrids(),
              GGraphStackedBar(
                valueKeys: ["buyVolume", "sellVolume", "neutralVolume"],
                baseValue: 100 * 1_000_000,
                theme: GGraphStackedBarTheme(
                  barStyles: barStyles,
                  barWidthRatio: 0.8,
                ),
              ),
            ],
          ),
        ],
      );

    case "3":
      // Example 3: Stacked bar with basePosition at top
      return GChart(
        dataSource: dataSource,
        theme: theme,
        panels: [
          GPanel(
            valueViewPorts: [
              GValueViewPort(
                valuePrecision: 0,
                autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                  dataKeys: ["volume"],
                ),
              ),
            ],
            valueAxes: [GValueAxis()],
            pointAxes: [GPointAxis()],
            graphs: [
              GGraphGrids(),
              GGraphStackedBar(
                valueKeys: ["buyVolume", "sellVolume", "neutralVolume"],
                basePosition: 0,
                theme: GGraphStackedBarTheme(
                  barStyles: barStyles,
                  barWidthRatio: 0.8,
                ),
              ),
            ],
          ),
        ],
      );

    default:
      throw Exception("Target '$target' is not implemented.");
  }
}
