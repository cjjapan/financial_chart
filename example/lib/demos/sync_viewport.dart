import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../data/sample_data_loader.dart';

class SyncDemoPage extends StatefulWidget {
  const SyncDemoPage({super.key});

  @override
  SyncDemoPageState createState() => SyncDemoPageState();
}

class SyncDemoPageState extends State<SyncDemoPage>
    with TickerProviderStateMixin {
  GChart? chart1;
  GChart? chart2;

  @override
  void initState() {
    super.initState();
    initializeAllCharts();
  }

  @override
  void dispose() {
    chart1?.dispose();
    chart2?.dispose();
    super.dispose();
  }

  Future<void> initializeAllCharts() async {
    final c1 = await initializeChart('AAPL');
    final c2 = await initializeChart('GOOGL');
    c1.pointViewPort.addListener(() => syncCharts(c1, [c2]));
    c2.pointViewPort.addListener(() => syncCharts(c2, [c1]));
    setState(() {
      chart1 = c1;
      chart2 = c2;
    });
  }

  void syncCharts(GChart syncFrom, List<GChart> syncTo) {
    final startPoint = syncFrom.pointViewPort.startPoint;
    final endPoint = syncFrom.pointViewPort.endPoint;
    for (final chart in syncTo) {
      chart.pointViewPort.setRange(
        startPoint: startPoint,
        endPoint: endPoint,
        finished: true,
      );
      chart.autoScaleViewports(
        resetPointViewPort: false,
        resetValueViewPort: true,
        animation: false,
      );
    }
  }

  Future<GChart> initializeChart(String symbol) async {
    // load data
    return loadYahooFinanceData(symbol).then((response) {
      // build data source
      final dataSource = GDataSource<int, GData<int>>(
        dataList: response.candlesData.map((candle) {
          return GData<int>(
            pointValue: candle.date.millisecondsSinceEpoch,
            seriesValues: [
              candle.open,
              candle.high,
              candle.low,
              candle.close,
              candle.volume.toDouble(),
            ],
          );
        }).toList(),
        seriesProperties: const [
          GDataSeriesProperty(key: 'open', label: 'Open', precision: 2),
          GDataSeriesProperty(key: 'high', label: 'High', precision: 2),
          GDataSeriesProperty(key: 'low', label: 'Low', precision: 2),
          GDataSeriesProperty(key: 'close', label: 'Close', precision: 2),
          GDataSeriesProperty(key: 'volume', label: 'Volume', precision: 0),
        ],
      );
      final chart = buildChart(dataSource);
      chart.panels[0].graphs[1].addMarker(
        GLabelMarker(
          text: symbol,
          anchorCoord: GPositionCoord.absolute(x: 10, y: 10),
          alignment: Alignment.bottomRight,
        ),
      );
      return chart;
    });
  }

  GChart buildChart(GDataSource dataSource) {
    // build the chart
    return GChart(
      dataSource: dataSource,
      theme: GThemeDark(),
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
            GValueViewPort(
              id: "volume",
              valuePrecision: 0,
              autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                dataKeys: ["volume"],
                marginStart: GSize.viewSize(0),
                marginEnd: GSize.viewHeightRatio(0.7),
              ),
            ),
          ],
          valueAxes: [
            GValueAxis(),
            GValueAxis(viewPortId: "volume", position: GAxisPosition.start),
          ],
          pointAxes: [GPointAxis()],
          graphs: [
            GGraphGrids(),
            GGraphOhlc(ohlcValueKeys: const ["open", "high", "low", "close"]),
            GGraphBar(valueKey: "volume", valueViewPortId: "volume"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multiple charts"), centerTitle: true),
      body: Container(
        child: (chart1 == null || chart2 == null)
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GChartWidget(chart: chart1!, tickerProvider: this),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 1,
                      child: GChartWidget(chart: chart2!, tickerProvider: this),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
