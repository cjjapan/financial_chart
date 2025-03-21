import 'package:example/data/sample_data.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

class ChartPlaygroundDemoPage extends StatefulWidget {
  const ChartPlaygroundDemoPage({super.key});

  @override
  ChartPlaygroundDemoPageState createState() => ChartPlaygroundDemoPageState();
}

class ChartPlaygroundDemoPageState extends State<ChartPlaygroundDemoPage>
    with TickerProviderStateMixin {
  ChartPlaygroundDemoPageState();

  GChart? chart;
  late final GChartController controller;
  late Future<GDataSource> dataSourceFuture;

  void repaint() {}

  @override
  void initState() {
    super.initState();
    controller = GChartController();
    loadData();
  }

  void loadData() async {
    loadSampleData().then((value) {
      setState(() {
        buildChart(value);
      });
    });
  }

  void buildChart(GDataSource dataSource) {
    final chartTheme = GThemeDark();
    List<GPanel> panels = [
      GPanel(
        heightWeight: 0.7,
        valueAxes: [
          GValueAxis(
            viewPortId: 'vp-volume',
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.select,
          ),
          GValueAxis(
            viewPortId: 'vp-price',
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
        valueViewPorts: [
          GValueViewPort(
            id: "vp-price",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ['high', 'low'],
            ),
          ),
          GValueViewPort(
            id: "vp-volume",
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ['volume'],
              marginStart: GSize.viewSize(0),
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "g-grids", valueViewPortId: 'vp-price'),
          GGraphLine(
            id: "g-line",
            valueViewPortId: "vp-price",
            valueKey: "sma",
          ),
          GGraphBar(
            id: "g-bar",
            valueViewPortId: "vp-volume",
            valueKey: "volume",
            baseValue: 0,
          ),
          GGraphOhlc(
            id: "g-ohlc",
            visible: true,
            valueViewPortId: "vp-price",
            ohlcValueKeys: const ["open", "high", "low", "close"],
          ),
          GGraphGroup(
            id: "ichi",
            valueViewPortId: "vp-price",
            graphs: [
              GGraphLine(
                id: "ichi-base",
                valueViewPortId: "vp-price",
                valueKey: "ichimokuBase",
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
                valueViewPortId: "vp-price",
                valueKey: "ichimokuConversion",
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
                valueViewPortId: "vp-price",
                valueKey: "ichimokuSpanA",
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
                valueViewPortId: "vp-price",
                valueKey: "ichimokuSpanB",
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
                valueViewPortId: "vp-price",
                valueKey: "ichimokuLagging",
                theme: (chartTheme.graphThemes[GGraphLine.typeName]!
                        as GGraphLineTheme)
                    .copyWith(
                      lineStyle: PaintStyle(
                        strokeColor: Colors.purple,
                        strokeWidth: 1.0,
                      ),
                    ),
              ),
            ],
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          dataKeys: const [
            "open",
            "high",
            "low",
            "close",
            "volume",
            "sma",
            "ichimokuBase",
            "ichimokuConversion",
            "ichimokuSpanA",
            "ichimokuSpanB",
            "ichimokuLagging",
          ],
          followValueKey: "close",
          followValueViewPortId: "vp-price",
        ),
      ),
      GPanel(
        heightWeight: 0.3,
        valueAxes: [
          GValueAxis(viewPortId: 'vp-macd', position: GAxisPosition.end),
          GValueAxis(
            viewPortId: 'vp-macd',
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.move,
          ),
        ],
        pointAxes: [
          GPointAxis(
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.move,
          ),
        ],
        valueViewPorts: [
          GValueViewPort(
            id: "vp-macd",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: ['macd'],
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "g-grids2", valueViewPortId: 'vp-macd'),
          GGraphLine(
            id: "g-macd",
            valueViewPortId: "vp-macd",
            valueKey: "macd",
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.topLeft,
          dataKeys: const ["macd"],
          followValueKey: "macd",
          followValueViewPortId: "vp-macd",
        ),
      ),
    ];
    setState(() {
      chart = GChart(
        dataSource: dataSource,
        pointViewPort: GPointViewPort(),
        panels: panels,
        theme: chartTheme,
        preRender: (GChart chart, Size size) {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart demo')),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 60,
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (chart != null) {
                  if (chart!.theme.name == GThemeLight.themeName) {
                    chart!.theme = GThemeDark();
                  } else {
                    chart!.theme = GThemeLight();
                  }
                }
              },
              child: const Text("theme"),
            ),
          ),
          Expanded(
            child:
                chart == null
                    ? const CircularProgressIndicator()
                    : Padding(
                      padding: const EdgeInsets.all(10),
                      child: GChartWidget(chart: chart!),
                    ),
          ),
        ],
      ),
    );
  }
}
