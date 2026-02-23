import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../data/sample_data_loader.dart';

class BasicDemoPage extends StatefulWidget {
  const BasicDemoPage({super.key});

  @override
  BasicDemoPageState createState() => BasicDemoPageState();
}

class BasicDemoPageState extends State<BasicDemoPage>
    with TickerProviderStateMixin {
  GChart? chart;

  @override
  void initState() {
    super.initState();
    initializeChart();
  }

  @override
  void dispose() {
    chart?.dispose();
    super.dispose();
  }

  Future<void> initializeChart0() async {
    // load data
    loadYahooFinanceData('AAPL').then((response) {
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
      setState(() {
        chart = buildChart(dataSource);
      });
    });
  }

  Future initializeChart() async {
    // load data
    loadYahooFinanceData('AAPL').then((response) {
      // build data source
      final dataSource = GDataSource<int, GData<int>>(
        dataList: response.candlesData
            .map((candle) {
              return GData(
                pointValue: candle.date.millisecondsSinceEpoch,
                seriesValues: [
                  candle.open,
                  candle.open,
                  candle.open,
                  candle.open,
                  //candle.high,
                  //candle.low,
                  //candle.close,
                  candle.volume.toDouble(),
                ],
              );
            })
            .toList()
            .sublist(0, 1),
        seriesProperties: const [
          GDataSeriesProperty(key: 'open', label: 'Open', precision: 2),
          GDataSeriesProperty(key: 'high', label: 'High', precision: 2),
          GDataSeriesProperty(key: 'low', label: 'Low', precision: 2),
          GDataSeriesProperty(key: 'close', label: 'Close', precision: 2),
          GDataSeriesProperty(key: 'volume', label: 'Volume', precision: 0),
        ],
      );
      setState(() {
        chart = buildChart(dataSource);
      });
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
      pointViewPort: GPointViewPort(
        minPointWidth: 1,
        defaultPointWidth: 20,
        maxPointWidth: 100,
        startPointMin: -2,
        endPointMax: dataSource.length + 1,
        autoScaleStrategy: GPointViewPortAutoScaleStrategyLatest(),
      ),
    );
  }

  GChart buildChart0(GDataSource dataSource) {
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
      appBar: AppBar(title: const Text("Basic demo"), centerTitle: true),
      body: Container(
        child: chart == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: GChartWidget(chart: chart!, tickerProvider: this),
              ),
      ),
    );
  }
}
