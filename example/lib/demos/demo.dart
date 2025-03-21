import 'package:example/data/sample_data.dart';
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

  GChart? chart;
  late Future<GDataSource<int, GData<int>>> dataSourceFuture;

  final themes = [GThemeDark(), GThemeLight()];

  void repaint() {}

  int get simulateDataLatencyMillis => 0;
  bool get simulateEmptyData => false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    loadSampleData(
      simulateLatencyMillis: simulateDataLatencyMillis,
      simulateEmpty: simulateEmptyData,
    ).then((value) {
      setState(() {
        chart = buildChart(value);
      });
    });
  }

  GChart buildChart(GDataSource dataSource);

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
            height: 70,
            alignment: Alignment.center,
            child: chart == null ? Container() : buildControlPanel(context),
          ),
          Expanded(
            child:
                chart == null
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(10),
                      child: GChartWidget(chart: chart!),
                    ),
          ),
        ],
      ),
    );
  }

  Widget buildThemeSelectWidget(BuildContext context) {
    return AppLabelWidget(
      label: "Theme",
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
