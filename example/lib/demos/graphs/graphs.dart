import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../data/indicator_providers.dart';
import '../../widgets/label_widget.dart';
import './my_graph/step_line_theme.dart';
import './my_graph/step_line.dart';
import 'graphs_base.dart';

class DemoGraphOhlcPage extends DemoGraphBasePage {
  const DemoGraphOhlcPage({super.key}) : super(title: 'OHLC/Candlestick Graph');
  @override
  DemoGraphOhlcPageState createState() => DemoGraphOhlcPageState();
}

class DemoGraphOhlcPageState extends DemoGraphBasePageState {
  final GGraphOhlc graph = GGraphOhlc(
    id: "ohlc",
    valueViewPortId: "price",
    ohlcValueKeys: [keyOpen, keyHigh, keyLow, keyClose],
  );
  @override
  GGraph getGraph() => graph;
  @override
  GGraphTheme getGraphTheme() {
    final t = chart!.theme.graphThemes[GGraphOhlc.typeName]! as GGraphOhlcTheme;
    return t.copyWith(
      barWidthRatio: 0.8,
      barStylePlus: PaintStyle(
        fillColor: Colors.blue,
        strokeColor: Colors.orange,
        strokeWidth: 1,
      ),
      barStyleMinus: PaintStyle(
        fillColor: Colors.red,
        strokeColor: Colors.teal,
        strokeWidth: 1,
      ),
    );
  }

  @override
  List<String> tooltipDataKeys() => graph.ohlcValueKeys;
  @override
  String tooltipFollowValueViewPortId() => "price";
  @override
  List<Widget> buildControlActions(BuildContext context) => [
    AppLabelWidget(
      label: "GGraphOhlc.drawAsCandle",
      description: "Change the drawing style of the OHLC graph.",
      child: AppPopupMenu<String>(
        items: const ["candlestick", "ohlc"],
        onSelected: (String selected) {
          graph.drawAsCandle = (selected == "candlestick");
          repaintChart();
        },
        selected: graph.drawAsCandle ? "candlestick" : "ohlc",
        labelResolver: (item) => item,
      ),
    ),
  ];
}

class DemoGraphBarPage extends DemoGraphBasePage {
  const DemoGraphBarPage({super.key}) : super(title: 'Bar Graph');
  @override
  DemoGraphBarPageState createState() => DemoGraphBarPageState();
}

class DemoGraphBarPageState extends DemoGraphBasePageState {
  final GGraphBar graph = GGraphBar(
    id: "bar",
    valueViewPortId: "volume",
    valueKey: keyVolume,
  );
  @override
  GGraph getGraph() => graph;
  @override
  GGraphTheme getGraphTheme() {
    final t = chart!.theme.graphThemes[GGraphBar.typeName]! as GGraphBarTheme;
    return t.copyWith(
      barWidthRatio: 0.4,
      barStyleAboveBase: PaintStyle(
        fillColor: Colors.blue,
        strokeColor: Colors.orange,
        strokeWidth: 1,
      ),
      barStyleBelowBase: PaintStyle(
        fillColor: Colors.purple,
        strokeColor: Colors.blueGrey,
        strokeWidth: 1,
      ),
    );
  }

  @override
  List<String> tooltipDataKeys() => [graph.valueKey];
  @override
  String tooltipFollowValueViewPortId() => graph.valueViewPortId;
  @override
  List<Widget> buildControlActions(BuildContext context) => [
    AppLabelWidget(
      label: "GGraphBar.baseValue",
      description:
          "Change the baseValue of the bar."
          "\nbaseValue decides start position where each bar draw from, GGraphBar.valueKey decides the end position of the bar.",
      child: AppPopupMenu<double>(
        items: const [0, 50_000_000, 100_000_000],
        onSelected: (double selected) {
          graph.baseValue = selected;
          repaintChart();
        },
        selected: graph.baseValue ?? 0,
        labelResolver: (item) =>
            chart!.dataSource.seriesValueFormater.call(item, 0),
      ),
    ),
  ];
}

class DemoGraphLinePage extends DemoGraphBasePage {
  const DemoGraphLinePage({super.key}) : super(title: 'Line Graph');
  @override
  DemoGraphLinePageState createState() => DemoGraphLinePageState();
}

class DemoGraphLinePageState extends DemoGraphBasePageState {
  final GGraphLine graph = GGraphLine(
    id: "line",
    valueViewPortId: "price",
    valueKey: keyClose,
  );
  @override
  GGraph getGraph() => graph;
  @override
  GGraphTheme getGraphTheme() {
    final t = chart!.theme.graphThemes[GGraphLine.typeName]! as GGraphLineTheme;
    return t.copyWith(
      lineStyle: PaintStyle(strokeColor: Colors.red, strokeWidth: 2),
      pointRadius: 4,
      pointStyle: PaintStyle(fillColor: Colors.orange),
    );
  }

  @override
  List<String> tooltipDataKeys() => [graph.valueKey];
  @override
  String tooltipFollowValueViewPortId() => graph.valueViewPortId;

  @override
  List<Widget> buildControlActions(BuildContext context) => [
    AppLabelWidget(
      label: "GGraphLine.smoothing",
      description: "Whether to smooth the line or not.",
      child: AppPopupMenu<bool>(
        items: const [true, false],
        onSelected: (bool selected) {
          graph.smoothing = selected;
          repaintChart();
        },
        selected: graph.smoothing,
        labelResolver: (item) => item.toString(),
      ),
    ),
  ];
}

class DemoGraphAreaPage extends DemoGraphBasePage {
  const DemoGraphAreaPage({super.key}) : super(title: 'Area Graph');
  @override
  DemoGraphAreaPageState createState() => DemoGraphAreaPageState();
}

class DemoGraphAreaPageState extends DemoGraphBasePageState {
  final GGraphArea graph = GGraphArea(
    id: "area",
    valueViewPortId: "price",
    valueKey: keyIchimokuSpanA,
    baseValue: null,
    baseValueKey: keyIchimokuSpanB,
  );
  @override
  GGraph getGraph() => graph;
  @override
  GGraphTheme getGraphTheme() {
    return GGraphAreaTheme(
      styleBaseLine: PaintStyle(
        strokeColor: Colors.orange,
        strokeWidth: 1,
        dash: const [3, 3],
      ),
      styleAboveBase: PaintStyle(
        fillColor: Colors.teal.withAlpha(100),
        strokeWidth: 1,
        strokeColor: Colors.teal,
      ),
      styleBelowBase: PaintStyle(
        fillColor: Colors.purple.withAlpha(100),
        strokeWidth: 1,
        strokeColor: Colors.purple,
      ),
    );
  }

  @override
  List<String> tooltipDataKeys() => [keyIchimokuSpanA, keyIchimokuSpanB];
  @override
  String tooltipFollowValueViewPortId() => graph.valueViewPortId;
  @override
  List<Widget> buildControlActions(BuildContext context) => [
    AppLabelWidget(
      label: "GGraphArea.baseValue",
      description: "Change the baseValue of the area.",
      child: AppPopupMenu<double?>(
        items: const [null, 0, 230, 500],
        onSelected: (double? selected) {
          graph.baseValue = selected;
          if (selected != null) {
            graph.baseValueKey = null;
          }
          repaintChart();
        },
        selected: graph.baseValue,
        labelResolver: (item) => item?.toStringAsFixed(0) ?? "null",
      ),
    ),
    AppLabelWidget(
      label: "GGraphArea.baseValueKey",
      description: "Change the baseValueKey of the area.",
      child: AppPopupMenu<String?>(
        items: const [null, keyIchimokuSpanB],
        onSelected: (String? selected) {
          graph.baseValueKey = selected;
          repaintChart();
        },
        selected: graph.baseValueKey,
        labelResolver: (item) => item ?? "null",
      ),
    ),
  ];
}

class DemoGraphStepPage extends DemoGraphBasePage {
  const DemoGraphStepPage({super.key})
    : super(title: 'Custom graph (Step line graph)');
  @override
  DemoGraphStepPageState createState() => DemoGraphStepPageState();
}

class DemoGraphStepPageState extends DemoGraphBasePageState {
  DemoGraphStepPageState() {
    for (final theme in themes) {
      theme.graphThemes[GGraphStepLine.typeName] = GGraphStepLineTheme(
        lineUpStyle: PaintStyle(strokeColor: Colors.green, strokeWidth: 2),
        lineDownStyle: PaintStyle(strokeColor: Colors.red, strokeWidth: 2),
      );
    }
  }
  final GGraphStepLine graph = GGraphStepLine(
    id: "step",
    valueViewPortId: "price",
    valueKey: keyEMA,
  );

  @override
  GGraph getGraph() => graph;

  @override
  GGraphTheme getGraphTheme() {
    final t =
        chart!.theme.graphThemes[GGraphStepLine.typeName]!
            as GGraphStepLineTheme;
    return t.copyWith(
      lineUpStyle: PaintStyle(
        strokeWidth: 5,
        strokeColor: Colors.teal,
        strokeCap: StrokeCap.round,
      ),
      lineDownStyle: PaintStyle(
        strokeWidth: 5,
        strokeColor: Colors.redAccent,
        strokeCap: StrokeCap.round,
      ),
    );
  }

  @override
  List<String> tooltipDataKeys() => [graph.valueKey];

  @override
  String tooltipFollowValueViewPortId() => graph.valueViewPortId;
}
