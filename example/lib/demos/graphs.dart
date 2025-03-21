import 'package:example/data/sample_data.dart';
import 'package:example/demos/my_graph/step_line.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';
import 'my_graph/step_line_theme.dart';

class DemoGraphsPage extends DemoBasePage {
  const DemoGraphsPage({super.key, String? title})
    : super(title: title ?? 'Graphs');

  @override
  DemoGraphsPageState createState() => DemoGraphsPageState();
}

class DemoGraphsPageState extends DemoBasePageState {
  DemoGraphsPageState() {
    for (final theme in themes) {
      theme.graphThemes[GGraphStepLine.typeName] = GGraphStepLineTheme(
        lineUpStyle: PaintStyle(strokeColor: Colors.green, strokeWidth: 2),
        lineDownStyle: PaintStyle(strokeColor: Colors.red, strokeWidth: 2),
      );
    }
  }

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
              dataKeys: [
                keyHigh,
                keyLow,
                keySMA,
                keyIchimokuSpanA,
                keyIchimokuSpanB,
              ],
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
        pointAxes: [
          GPointAxis(position: GAxisPosition.start),
          GPointAxis(position: GAxisPosition.end),
        ],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            valueViewPortId: "price",
            drawAsCandle: true,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
          ),
          GGraphBar(
            id: "bar",
            valueViewPortId: "volume",
            valueKey: keyVolume,
            baseValue: 0,
          ),
          GGraphLine(id: "line", valueViewPortId: "price", valueKey: keySMA),
          GGraphArea(
            id: "area",
            valueKey: keyIchimokuSpanA,
            baseValueKey: keyIchimokuSpanB,
            valueViewPortId: "price",
          ),
          GGraphStepLine(
            id: "stepLine",
            valueViewPortId: "price",
            valueKey: keyEMA,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "OHLC graph style",
          child: AppPopupMenu<String>(
            items: const ["candle", "ohlc"],
            onSelected: (String selected) {
              (chart!.panels[0].findGraphById("ohlc")! as GGraphOhlc)
                  .drawAsCandle = (selected == "candle");
              repaintChart();
            },
            selected:
                (chart!.panels[0].findGraphById("ohlc")! as GGraphOhlc)
                        .drawAsCandle
                    ? "candle"
                    : "ohlc",
            labelResolver: (item) => item,
          ),
        ),
        AppLabelWidget(
          label: "OHLC visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("ohlc")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("ohlc")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "Bar visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("bar")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("bar")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "Line visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("line")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("line")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "Area visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("area")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("area")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "Area layer",
          child: AppPopupMenu<String>(
            items: const ["top", "bottom"],
            onSelected: (String selected) {
              chart!.panels[0].findGraphById("area")!.layer =
                  (selected == "top")
                      ? (GGraph.kDefaultLayer + 1)
                      : (GGraph.kDefaultLayer - 1);
              repaintChart();
            },
            selected:
                (chart!.panels[0].findGraphById("area")!.layer <
                        GGraph.kDefaultLayer)
                    ? "bottom"
                    : "top",
            labelResolver: (item) => item,
          ),
        ),
      ],
    );
  }
}
