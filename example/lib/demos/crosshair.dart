import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoCrosshairPage extends DemoBasePage {
  const DemoCrosshairPage({super.key}) : super(title: 'Crosshair');

  @override
  DemoBasePageState createState() => DemoCrosshairPageState();
}

class DemoCrosshairPageState extends DemoBasePageState {
  DemoCrosshairPageState();

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
            crosshairHighlightValueKeys: [keyOpen, keyClose],
          ),
          GGraphLine(
            id: "line",
            valueViewPortId: "price",
            valueKey: keySMA,
            crosshairHighlightValueKeys: [keySMA],
          ),
        ],
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
          label: "Point snap",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.snapToPoint = selected;
              repaintChart();
            },
            selected: chart!.crosshair.snapToPoint,
          ),
        ),
        AppLabelWidget(
          label: "Point lines",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.pointLinesVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.pointLinesVisible,
          ),
        ),
        AppLabelWidget(
          label: "Value lines",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.valueLinesVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.valueLinesVisible,
          ),
        ),
        AppLabelWidget(
          label: "Point axis labels",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.pointAxisLabelsVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.pointAxisLabelsVisible,
          ),
        ),
        AppLabelWidget(
          label: "Value axis labels",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.crosshair.valueAxisLabelsVisible = selected;
              repaintChart();
            },
            selected: chart!.crosshair.valueAxisLabelsVisible,
          ),
        ),
      ],
    );
  }
}
