import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../data/indicator_providers.dart';
import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoTooltipPage extends DemoBasePage {
  const DemoTooltipPage({super.key}) : super(title: 'Tooltip');

  @override
  DemoTooltipPageState createState() => DemoTooltipPageState();
}

class DemoTooltipPageState extends DemoBasePageState {
  DemoTooltipPageState();

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
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
          ),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
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
          label: "GTooltip.position",
          description: "Change the position of the tooltip",
          child: AppPopupMenu<GTooltipPosition>(
            items: GTooltipPosition.values,
            onSelected: (GTooltipPosition selected) {
              chart!.panels[0].tooltip!.position = selected;
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.position,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "GTooltip.followValueKey",
          description:
              "The value key that decides tooltip's vertical position when GTooltip.position is followPointer",
          child: AppPopupMenu<String?>(
            items: const [null, keyOpen, keyHigh, keyLow, keyClose, keySMA],
            onSelected: (String? selected) {
              chart!.panels[0].tooltip!.followValueKey = selected;
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.followValueKey,
            labelResolver: (item) => item == null ? "-" : "\"$item\"",
          ),
        ),
        AppLabelWidget(
          label: "GTooltip.pointLineHighlightVisible",
          description: "Show/hide the vertical highlight line of current point",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].tooltip!.pointLineHighlightVisible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.pointLineHighlightVisible,
          ),
        ),
        AppLabelWidget(
          label: "GTooltip.valueLineHighlightVisible",
          description:
              "Show/hide the horizontal highlight line of value defined by followValueKey",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].tooltip!.valueLineHighlightVisible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.valueLineHighlightVisible,
          ),
        ),
        AppLabelWidget(
          label: "GTooltip.tooltipWidgetBuilder",
          description: "Use a flutter widget to display tooltip.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              if (selected) {
                chart!.panels[0].tooltip!.tooltipWidgetBuilder =
                    (context, size, tooltip, point) {
                      final values = chart!.dataSource.getSeriesValueAsMap(
                        point: point,
                        keys: [keyOpen, keyHigh, keyLow, keyClose],
                      );
                      if (values.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final graphTheme =
                          chart!.theme.graphThemes["ohlc"] as GGraphOhlcTheme;
                      final textColor = (values[keyOpen]! > values[keyClose]!
                          ? graphTheme.barStyleMinus.fillColor
                          : graphTheme.barStylePlus.fillColor);
                      return Container(
                        width: 160,
                        height: 100,
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          children: [
                            ...values.entries.map((e) {
                              return Row(
                                children: [
                                  Text(
                                    e.key.replaceFirst(
                                      e.key[0],
                                      e.key[0].toUpperCase(),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                  Text(
                                    e.value.toStringAsFixed(2),
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      );
                    };
              } else {
                chart!.panels[0].tooltip!.tooltipWidgetBuilder = null;
              }
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.tooltipWidgetBuilder != null,
          ),
        ),
      ],
    );
  }
}
