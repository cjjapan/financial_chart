import '../../data/indicator_providers.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../widgets/label_widget.dart';
import '../demo.dart';

class DemoGraphGroupPage extends DemoBasePage {
  const DemoGraphGroupPage({super.key}) : super(title: 'Graph group');

  @override
  DemoGraphGroupPageState createState() => DemoGraphGroupPageState();
}

class DemoGraphGroupPageState extends DemoBasePageState {
  DemoGraphGroupPageState();

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
          GValueViewPort(
            id: "volume",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ['volume'],
              marginStart: GSize.viewSize(0),
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(
            viewPortId: 'volume',
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.none,
          ),
          GValueAxis(
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
          ),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphGroup(
            id: "ichimoku",
            graphs: [
              GGraphLine(
                id: "ichi-base",
                valueViewPortId: "price",
                valueKey: keyIchimokuBase,
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.red,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
              GGraphLine(
                id: "ichi-conv",
                valueViewPortId: "price",
                valueKey: keyIchimokuConversion,
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.yellow,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
              GGraphLine(
                id: "ichi-spanA",
                valueViewPortId: "price",
                valueKey: keyIchimokuSpanA,
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.green,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
              GGraphLine(
                id: "ichi-spanB",
                valueViewPortId: "price",
                valueKey: keyIchimokuSpanB,
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.orange,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
              GGraphLine(
                id: "ichi-lagging",
                valueViewPortId: "price",
                valueKey: keyIchimokuLagging,
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.purple,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
              GGraphArea(
                id: "area",
                valueViewPortId: "price",
                valueKey: keyIchimokuSpanA,
                baseValueKey: keyIchimokuSpanB,
              ),
            ],
          ),
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
            keyIchimokuSpanA,
            keyIchimokuSpanB,
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
          label: "GGraphGroup.visible",
          description: "Show or hide all graphs in a single group.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("ichimoku")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("ichimoku")!.visible,
          ),
        ),
      ],
    );
  }
}
