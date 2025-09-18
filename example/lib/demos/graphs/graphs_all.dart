import '../../data/indicator_providers.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../widgets/label_widget.dart';
import '../demo.dart';
import './my_graph/step_line_theme.dart';
import './my_graph/step_line.dart';

class DemoGraphsPage extends DemoBasePage {
  const DemoGraphsPage({super.key, String? title})
    : super(title: title ?? 'Graphs');

  @override
  DemoGraphsPageState createState() => DemoGraphsPageState();
}

class DemoGraphsPageState extends DemoBasePageState {
  final Stopwatch _stopwatch = Stopwatch();
  final ValueNotifier<double> _renderTime = ValueNotifier(0);
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
            id: "step",
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
      preRender: (_, _, _) {
        _stopwatch
          ..reset()
          ..start();
      },
      postRender: (_, _, _) {
        _stopwatch.stop();
        WidgetsBinding.instance.addPostFrameCallback((f) {
          _renderTime.value = _stopwatch.elapsedMicroseconds / 1000.0;
        });
      },
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLabelWidget(
          label: "Render time",
          child: ValueListenableBuilder<double>(
            valueListenable: _renderTime,
            builder: (context, value, child) {
              return Text(
                "${value.toStringAsFixed(2)} ms",
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GGraphArea.layer",
          description:
              "Change the layer of the Area graph. "
              "\nlayer is a int value that determines the painting order of the graph.",
          child: AppPopupMenu<String>(
            items: const ["top", "bottom"],
            onSelected: (String selected) {
              chart!.panels[0]
                  .findGraphById("area")!
                  .layer = (selected == "top")
                  ? (GComponent.kDefaultLayer + 1)
                  : (GComponent.kDefaultLayer - 1);
              repaintChart();
            },
            selected:
                (chart!.panels[0].findGraphById("area")!.layer <
                    GComponent.kDefaultLayer)
                ? "bottom"
                : "top",
            labelResolver: (item) => item,
          ),
        ),
      ],
    );
  }
}
