import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoAxesPage extends DemoBasePage {
  const DemoAxesPage({super.key}) : super(title: 'Axes');

  @override
  DemoBasePageState createState() => DemoAxesPageState();
}

class DemoAxesPageState extends DemoBasePageState {
  DemoAxesPageState();

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
          ),
          GGraphLine(id: "line", valueViewPortId: "price", valueKey: keySMA),
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
          label: "Point axis position",
          child: AppPopupMenu<GAxisPosition>(
            items: GAxisPosition.values,
            onSelected: (GAxisPosition selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.position = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].position,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "Value axis position",
          child: AppPopupMenu<GAxisPosition>(
            items: GAxisPosition.values,
            onSelected: (GAxisPosition selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.position = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].position,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "Point axis scale mode",
          child: AppPopupMenu<GAxisScaleMode>(
            items: GAxisScaleMode.values,
            onSelected: (GAxisScaleMode selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.scaleMode = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].scaleMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "Value axis scale mode",
          child: AppPopupMenu<GAxisScaleMode>(
            items: GAxisScaleMode.values,
            onSelected: (GAxisScaleMode selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.scaleMode = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].scaleMode,
            labelResolver: (item) => item.name,
          ),
        ),
        AppLabelWidget(
          label: "Point axis size",
          child: AppPopupMenu<double>(
            items: const [30, 40],
            onSelected: (double selected) {
              for (GPanel panel in chart!.panels) {
                for (GPointAxis axis in panel.pointAxes) {
                  axis.size = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].pointAxes[0].size,
            labelResolver: (item) => item.toStringAsFixed(0),
          ),
        ),
        AppLabelWidget(
          label: "Value axis size",
          child: AppPopupMenu<double>(
            items: const [60, 80],
            onSelected: (double selected) {
              for (GPanel panel in chart!.panels) {
                for (GValueAxis axis in panel.valueAxes) {
                  axis.size = selected;
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].size,
            labelResolver: (item) => item.toStringAsFixed(0),
          ),
        ),
      ],
    );
  }
}
