import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../data/sample_data_loader.dart';

class BasicDemoPage extends StatefulWidget {
  const BasicDemoPage({super.key});

  @override
  BasicDemoPageState createState() => BasicDemoPageState();
}

class BasicDemoPageState extends State<BasicDemoPage> {
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

  Future<void> initializeChart() async {
    const String ticker = 'GOOGL';
    loadYahooFinanceData(ticker).then((response) {
      final dataSource = GDataSource<int, GData<int>>(
        dataList:
            response.candlesData.map((candle) {
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

  GChart buildChart(GDataSource dataSource) {
    const valueViewPortId = "price";
    return GChart(
      dataSource: dataSource,
      theme: GThemeDark(),
      panels: [
        GPanel(
          valueViewPorts: [
            GValueViewPort(
              id: valueViewPortId,
              valuePrecision: 2,
              autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
                dataKeys: ["high", "low"],
              ),
            ),
          ],
          valueAxes: [GValueAxis(viewPortId: valueViewPortId)],
          pointAxes: [GPointAxis()],
          graphs: [
            GGraphGrids(valueViewPortId: valueViewPortId),
            GGraphOhlc(
              valueViewPortId: valueViewPortId,
              ohlcValueKeys: const ["open", "high", "low", "close"],
            ),
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
        child:
            chart == null
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(10),
                  child: GChartWidget(chart: chart!),
                ),
      ),
    );
  }
}
