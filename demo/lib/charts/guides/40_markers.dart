part of "../charts.dart";

GChart chartGuideMarkers(GDataSource dataSource, String themeName) {
  final theme = themeName == "dark" ? GThemeDark() : GThemeLight();
  return GChart(
    dataSource: dataSource,
    theme: theme,
    pointViewPort: GPointViewPort(autoScaleStrategy: GPointViewPortAutoScaleStrategyLatest(endSpacingPoints: 10)),
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
          // Add a value viewport for volume graph and axis
          GValueViewPort(
            id: "volumeViewPort",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ["volume"],
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        // Y Axes
        valueAxes: [
          GValueAxis(),
          GValueAxis(
            id: "volume",
            viewPortId: "volumeViewPort",
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.none,
          ),
        ],
        // X Axes
        pointAxes: [GPointAxis()],
        graphs: [
          GGraphGrids(),
          GGraphOhlc(
            ohlcValueKeys: const ["open", "high", "low", "close"],
            // add overlay markers to the OHLC graph
            overlayMarkers: [
              // A label marker pinned at the left top corner of the graph area
              GLabelMarker(
                text: "Stock chart for AAPL",
                anchorCoord: GPositionCoord.absolute(x: 10, y: 10),
                alignment: Alignment.bottomRight,
                hitTestMode: GHitTestMode.none,
                theme: theme.overlayMarkerTheme.copyWith(
                  labelStyle: theme.overlayMarkerTheme.labelStyle!.copyWith(
                    textStyle: theme.overlayMarkerTheme.labelStyle!.textStyle!
                        .copyWith(fontSize: 16),
                  ),
                ),
              ),
              // A star marker pinned at the last close data point of the graph
              GShapeMarker(
                anchorCoord: GViewPortCoord(
                  point: dataSource.lastPoint.toDouble(),
                  value: dataSource.getSeriesValue(
                    point: dataSource.lastPoint,
                    key: "close",
                  )!,
                ),
                radiusSize: GSize.pointSize(5),
                pathGenerator: (r) => GShapes.star(r, vertexCount: 5),
                rotation: pi / 10, // Rotate the star marker
              ),
            ],
          ),
          GGraphBar(valueKey: "volume", valueViewPortId: "volumeViewPort"),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          followValueKey: "close",
          followValueViewPortId: "",
          dataKeys: ["open", "high", "low", "close", "volume"],
        ),
      ),
    ],
  );
}
