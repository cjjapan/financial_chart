import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../data/indicator_providers.dart';
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
            overlayMarkers: [
              GCalloutMarker(
                text: "drag here to resize",
                anchorCoord: GPositionCoord.rational(
                  x: 0.5,
                  y: 0,
                  xOffset: defaultVAxisSize / 2,
                  yOffset: 5,
                ),
                alignment: Alignment.bottomCenter,
                theme: chartTheme.overlayMarkerTheme.copyWith(
                  labelStyle: chartTheme.overlayMarkerTheme.labelStyle!
                      .copyWith(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
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
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GPanel.resizable",
          description:
              "Enable/disable resizing of the panels. "
              "\nOnly when both panels are resizable, the resizing splitter will be shown.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].resizable = selected;
              chart!.panels[1].resizable = selected;
              for (final marker
                  in chart!.panels[1].findGraphById("macd")!.overlayMarkers) {
                marker.visible = selected;
              }
              for (final marker
                  in chart!.panels[1].findGraphById("macd")!.overlayMarkers) {
                marker.visible = selected;
              }
              repaintChart();
            },
            selected: chart!.panels[0].resizable,
          ),
        ),
        AppLabelWidget(
          label: "GPanel.visible",
          description: "Show/hide a panel.",
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
          label: "GChart.pointerScrollMode",
          description: "Change the behavior when scrolling the mouse wheel.",
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
          label: "GPanel.graphPanMode",
          description:
              "Change the behavior when dragging the graph area."
              "\nnone means no dragging allowed. "
              "\nauto means allow dragging, dragging vertically is enabled ony when GValueViewPort.autoScale is off.",
          child: AppPopupMenu<GGraphPanMode>(
            items: GGraphPanMode.values,
            onSelected: (GGraphPanMode selected) {
              for (final panel in chart!.panels) {
                panel.graphPanMode = selected;
              }
              repaintChart();
            },
            selected: chart!.panels[0].graphPanMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GPanel.momentumScrollSpeed",
          description:
              "Change the speed of the momentum scroll when drag and release the graph area. "
              "\nA value between 0 and 1 the smaller value means slower scrolling, 0 to disable.",
          child: AppPopupMenu<double>(
            items: const [0, 0.1, 0.5, 1.0],
            onSelected: (double selected) {
              for (final panel in chart!.panels) {
                panel.momentumScrollSpeed = selected;
              }
              repaintChart();
            },
            selected: chart!.panels[0].momentumScrollSpeed,
            labelResolver: (item) => item.toString(),
          ),
        ),
      ],
    );
  }
}
