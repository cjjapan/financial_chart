import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "Tooltip position",
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
        if (chart!.panels[0].tooltip!.position ==
            GTooltipPosition.followPointer)
          AppLabelWidget(
            label: "Follow key",
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
          label: "Point line highlight",
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
          label: "Value line highlight",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].tooltip!.valueLineHighlightVisible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].tooltip!.valueLineHighlightVisible,
          ),
        ),
      ],
    );
  }
}
