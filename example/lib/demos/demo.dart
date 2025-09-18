import 'package:example/data/data_source_builder.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import '../widgets/popup_menu.dart';

abstract class DemoBasePage extends StatefulWidget {
  final String title;
  const DemoBasePage({super.key, required this.title});

  @override
  DemoBasePageState createState();
}

abstract class DemoBasePageState extends State<DemoBasePage>
    with TickerProviderStateMixin {
  DemoBasePageState();

  final scrollController = ScrollController();
  GChart? chart;
  late Future<GDataSource<int, GData<int>>> dataSourceFuture;

  final themes = [GThemeDark(), GThemeLight()];

  int get simulateDataLatencyMillis => 0;
  bool get simulateEmptyData => false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    chart?.dispose();
    super.dispose();
  }

  void loadData() async {
    createDataSource(asyncDelayMillis: simulateDataLatencyMillis).then((
      dataSource,
    ) {
      setState(() {
        chart = buildChart(dataSource);
      });
    });
  }

  GChart buildChart(GDataSource dataSource);

  GChartWidget buildChartWidget(GChart chart, TickerProvider tickerProvider) {
    return GChartWidget(chart: chart, tickerProvider: tickerProvider);
  }

  Widget buildControlPanel(BuildContext context) {
    return ElevatedButton(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            //height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: chart == null ? Container() : _buildControlPanel(context),
          ),
          Expanded(
            child: chart == null
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: buildChartWidget(chart!, this),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
            left: 16,
            right: 16,
            top: 0,
          ),
          child: buildControlPanel(context),
        ),
      ),
    );
  }

  Widget buildThemeSelectWidget(BuildContext context) {
    return AppLabelWidget(
      label: "GChart.theme",
      description: "Change the theme of the chart",
      child: AppPopupMenu<GTheme>(
        items: themes,
        onSelected: (GTheme selected) {
          chart!.theme = selected;
          repaintChart();
        },
        selected: chart!.theme,
        labelResolver: (GTheme item) => item.name,
      ),
    );
  }

  void repaintChart() {
    setState(() {
      chart?.repaint();
    });
  }
}
