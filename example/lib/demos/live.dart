import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../data/indicator_providers.dart';
import '../widgets/label_widget.dart';
import '../widgets/popup_menu.dart';
import 'demo.dart';

class DemoLiveUpdatePage extends DemoBasePage {
  const DemoLiveUpdatePage({super.key}) : super(title: 'Live update');

  @override
  DemoLiveUpdatePageState createState() => DemoLiveUpdatePageState();
}

class DemoLiveUpdatePageState extends DemoBasePageState {
  int updateIntervalMillis = 200;
  Timer? timer;
  GDataSource? dataSource;
  GPointAxisMarker? pointAxisMarker;
  GValueAxisMarker? valueAxisMarker;
  GPolyLineMarker? lineMarker;

  DemoLiveUpdatePageState();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(milliseconds: updateIntervalMillis),
      timerHandler,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void timerHandler(Timer t) {
    if (chart == null) {
      return;
    }
    final dataSource = chart!.dataSource as GDataSource<int, GData<int>>;
    if (dataSource.length == 0) {
      return;
    }
    GData<int> lastData = dataSource.dataList.last;
    final latestPrice =
        lastData.seriesValues[3] +
        (Random().nextInt(100) - 50) * 0.02; // random price change
    if (t.tick % 10 == 0) {
      // append new data every 10 ticks
      dataSource.dataList.add(
        GData<int>(
          pointValue: lastData.pointValue + 86400000,
          seriesValues: [
            ...[latestPrice, latestPrice, latestPrice, latestPrice], // ohlc
            ...lastData.seriesValues.sublist(
              4,
            ), // here we just copy the rest, in real case we need to set correct volume and indicator values
          ],
        ),
      );
    }
    // update last data high, low, close
    lastData = dataSource.dataList.last;
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyClose)] =
        latestPrice; // close
    final ohlcValues = [
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyOpen)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyHigh)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyLow)],
      lastData.seriesValues[dataSource.seriesKeyToIndex(keyClose)],
    ];
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyHigh)] = ohlcValues
        .reduce(max); // high
    lastData.seriesValues[dataSource.seriesKeyToIndex(keyLow)] = ohlcValues
        .reduce(min); // low
    // update axis marker and line marker
    lineMarker!.keyCoordinates[0] =
        (lineMarker!.keyCoordinates[0] as GCustomCoord).copyWith(
          y: latestPrice,
        );
    lineMarker!.keyCoordinates[1] =
        (lineMarker!.keyCoordinates[1] as GCustomCoord).copyWith(
          y: latestPrice,
        );
    valueAxisMarker!.labelValue = latestPrice;
    pointAxisMarker!.labelPoint = dataSource.lastPoint;
    // reset viewport if allowed and redraw chart
    chart?.autoScaleViewports();
    repaintChart();
  }

  @override
  int get simulateDataLatencyMillis => 0;

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
    valueAxisMarker = GValueAxisMarker.label(
      id: "axis-marker-latest",
      labelValue: dataSource.getSeriesValue(
        point: dataSource.lastPoint,
        key: keyClose,
      )!,
    );
    pointAxisMarker = GPointAxisMarker.label(
      id: "axis-marker-latest",
      point: dataSource.lastPoint,
    );
    if (dataSource.isNotEmpty) {
      lineMarker = GPolyLineMarker(
        id: "line-marker-latest",
        coordinates: [
          GCustomCoord(
            x: 0.0,
            y: dataSource.getSeriesValue(
              point: dataSource.lastPoint,
              key: keyClose,
            )!,
            coordinateConvertor: kCoordinateConvertorXPositionYValue,
            coordinateConvertorReverse:
                kCoordinateConvertorXPositionYValueReverse,
          ),
          GCustomCoord(
            x: 1.0,
            y: dataSource.getSeriesValue(
              point: dataSource.lastPoint,
              key: keyClose,
            )!,
            coordinateConvertor: kCoordinateConvertorXPositionYValue,
            coordinateConvertorReverse:
                kCoordinateConvertorXPositionYValueReverse,
          ),
        ],
        theme: GOverlayMarkerTheme(
          markerStyle: PaintStyle(strokeColor: Colors.orange),
          controlHandleThemes:
              chartTheme.overlayMarkerTheme.controlHandleThemes,
        ),
      );
    }
    List<GPanel> panels = [
      GPanel(
        valueViewPorts: [
          GValueViewPort(
            id: "price",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyHigh, keyLow],
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
            axisMarkers: [valueAxisMarker!],
          ),
        ],
        pointAxes: [
          GPointAxis(
            position: GAxisPosition.end,
            axisMarkers: [pointAxisMarker!],
          ),
        ],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            visible: true,
            valueViewPortId: "price",
            drawAsCandle: true,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
            overlayMarkers: [if (lineMarker != null) lineMarker!],
          ),
          GGraphLine(
            id: "line",
            visible: false, // live update not implemented yet so just hide
            valueViewPortId: "price",
            valueKey: keySMA,
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.none,
          dataKeys: const [
            keyOpen,
            keyHigh,
            keyLow,
            keyClose,
            keyVolume,
            keySMA,
            keyIchimokuSpanA,
            keyIchimokuSpanB,
          ],
          followValueKey: keyClose,
          followValueViewPortId: "price",
          pointLineHighlightVisible: false,
          valueLineHighlightVisible: false,
        ),
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(
        autoScaleStrategy: const GPointViewPortAutoScaleStrategyLatest(
          endSpacingPoints: 10,
        ),
      ),
      panels: panels,
      theme: chartTheme,
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GOverlayMarker.visible",
          description:
              "Show or hide the overlay markers: "
              "\nWhich are the price value line and axis labels indicating the latest price in this example.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (final marker
                  in chart!.panels[0].findGraphById("ohlc")!.overlayMarkers) {
                marker.visible = selected;
              }
              for (final panel in chart!.panels) {
                for (final axis in panel.valueAxes) {
                  for (final marker in axis.axisMarkers) {
                    marker.visible = selected;
                  }
                }
                for (final axis in panel.pointAxes) {
                  for (final marker in axis.axisMarkers) {
                    marker.visible = selected;
                  }
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0]
                .findGraphById("ohlc")!
                .overlayMarkers[0]
                .visible,
          ),
        ),
        AppLabelWidget(
          label: "Live update interval",
          description:
              "Change the update interval of the chart. "
              "\n(This example uses fake update with fixed interval and random price change)",
          child: AppPopupMenu<int>(
            items: const [0, 100, 200, 500, 1000],
            onSelected: (int selected) {
              setState(() {
                updateIntervalMillis = selected;
              });
              if (selected > 0) {
                timer?.cancel();
                timer = Timer.periodic(
                  Duration(milliseconds: selected),
                  timerHandler,
                );
              } else {
                timer?.cancel();
              }
            },
            selected: updateIntervalMillis,
            labelResolver: (item) => item == 0 ? "Off" : "$item ms",
          ),
        ),
      ],
    );
  }
}
