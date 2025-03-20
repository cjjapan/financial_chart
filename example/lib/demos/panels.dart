import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoPanelsPage extends DemoBasePage {
  const DemoPanelsPage({super.key}) : super(title: 'Panels and splitter');

  @override
  DemoPanelsPageState createState() => DemoPanelsPageState();
}

class DemoPanelsPageState extends DemoBasePageState {
  DemoPanelsPageState();

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
    List<GPanel> panels = [
      GPanel(
        heightWeight: 0.7,
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
          ),
        ],
        pointAxes: [
          GPointAxis(
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.select,
          ),
          GPointAxis(position: GAxisPosition.end),
        ],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            valueViewPortId: "price",
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
          ),
          GGraphLine(id: "line", valueViewPortId: "price", valueKey: keySMA),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          dataKeys: const [
            keyOpen,
            keyHigh,
            keyLow,
            keyClose,
            keyVolume,
            keySMA,
          ],
          followValueKey: keyClose,
          followValueViewPortId: "price",
        ),
      ),
      GPanel(
        heightWeight: 0.3,
        valueAxes: [
          GValueAxis(viewPortId: 'macd', position: GAxisPosition.end),
        ],
        pointAxes: [
          GPointAxis(
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.move,
          ),
        ],
        valueViewPorts: [
          GValueViewPort(
            id: "macd",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyMACD],
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "grids2", valueViewPortId: 'macd'),
          GGraphLine(
            id: "macd",
            valueViewPortId: "macd",
            valueKey: keyMACD,
            graphMarkers: [
              GCalloutMarker(
                text: "drag here to resize",
                anchorCoord: GPositionCoord.rational(
                  x: 0.5,
                  y: 0,
                  xOffset: defaultVAxisSize / 2,
                  yOffset: 5,
                ),
                alignment: Alignment.bottomCenter,
                theme: chartTheme.graphMarkerTheme.copyWith(
                  labelStyle: chartTheme.graphMarkerTheme.labelStyle!.copyWith(
                    textStyle: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.topLeft,
          dataKeys: const [keyMACD],
          followValueKey: keyMACD,
          followValueViewPortId: "macd",
        ),
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(),
      panels: panels,
      theme: chartTheme,
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "Panel resizable",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].resizable = selected;
              chart!.panels[1].resizable = selected;
              repaintChart();
            },
            selected: chart!.panels[0].resizable,
          ),
        ),
        AppLabelWidget(
          label: "Second panel visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[1].visible = selected;
              repaintChart();
            },
            selected: chart!.panels[1].visible,
          ),
        ),
        AppLabelWidget(
          label: "Pointer scroll mode",
          child: AppPopupMenu<GPointerScrollMode>(
            items: GPointerScrollMode.values,
            onSelected: (GPointerScrollMode selected) {
              chart?.pointerScrollMode = selected;
              repaintChart();
            },
            selected: chart!.pointerScrollMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "Markers visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (var marker
                  in chart!.panels[1].findGraphById("macd")!.graphMarkers) {
                marker.visible = selected;
              }
              for (var marker
                  in chart!.panels[1].findGraphById("macd")!.axisMarkers) {
                marker.visible = selected;
              }
              repaintChart();
            },
            selected:
                chart!.panels[1].findGraphById("macd")!.graphMarkers[0].visible,
          ),
        ),
      ],
    );
  }
}
