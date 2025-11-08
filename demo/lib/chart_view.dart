import 'dart:convert';

import 'package:charts/charts/charts.dart';
import 'package:charts/yahoo_finance_candle_data.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<YahooFinanceResponse> loadYahooFinanceData(String ticker) async {
  Map<String, dynamic> json = {};
  String fileName = "$ticker.json";
  final content = await rootBundle.loadString('assets/$fileName');
  json = jsonDecode(content);
  return YahooFinanceResponse.fromJson(json);
}

class ChartView extends StatefulWidget {
  final String name;
  final String ticker;
  final String theme;

  const ChartView({
    super.key,
    required this.name,
    required this.ticker,
    this.theme = "dark",
  });

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> with TickerProviderStateMixin {
  late Future<YahooFinanceResponse> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = loadYahooFinanceData(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder:
          (BuildContext context, AsyncSnapshot<YahooFinanceResponse> data) {
            if (data.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (data.hasError) {
              return Center(child: Text('Error: ${data.error}'));
            } else if (!data.hasData || data.data == null) {
              return const Center(child: Text('No data available'));
            }
            final response = data.data!;
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
              seriesProperties: [
                GDataSeriesProperty(key: "open", label: "Open", precision: 2),
                GDataSeriesProperty(key: "high", label: "High", precision: 2),
                GDataSeriesProperty(key: "low", label: "Low", precision: 2),
                GDataSeriesProperty(key: "close", label: "Close", precision: 2),
                GDataSeriesProperty(key: "volume", label: "Volume", precision: 0),
              ],
            );
            try {
              final chart = buildChart(widget.name, dataSource, widget.theme);
              return GChartWidget(chart: chart, tickerProvider: this);
            } catch (e) {
              return Center(
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.transparency,
                  child: Text(
                    kDebugMode ? 'Error building chart: $e' : 'chart is not available',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }
          },
    );
  }
}
