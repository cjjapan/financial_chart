import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/indicator_providers.dart';
import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class GraphsControlView extends StatefulWidget {
  const GraphsControlView({super.key});

  @override
  State<GraphsControlView> createState() => _GraphsControlViewState();
}

class _GraphsControlViewState extends State<GraphsControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    return ExpansionPanelList.radio(
      elevation: 0,
      expandedHeaderPadding: const EdgeInsets.all(0),
      children: [
        ExpansionPanelRadio(
          value: "grid",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Grids"),
              ),
            );
          },
          body: grid(context, state),
        ),
        ExpansionPanelRadio(
          value: "ohlc",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("OHLC"),
              ),
            );
          },
          body: ohlc(context, state),
        ),
        ExpansionPanelRadio(
          value: "bar",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(alignment: Alignment.centerLeft, child: Text("Bar")),
            );
          },
          body: bar(context, state),
        ),
        ExpansionPanelRadio(
          value: "stacked_bar",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Stacked Bar"),
              ),
            );
          },
          body: stackedBar(context, state),
        ),
        ExpansionPanelRadio(
          value: "line",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Line"),
              ),
            );
          },
          body: line(context, state),
        ),
        ExpansionPanelRadio(
          value: "area",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Area"),
              ),
            );
          },
          body: area(context, state),
        ),
        ExpansionPanelRadio(
          value: "group",
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Group"),
              ),
            );
          },
          body: group(context, state),
        ),
      ],
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          //state.graphsExpanded = !isExpanded;
        });
      },
    );
  }

  Widget grid(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph = panel.findGraphById("g-grids")! as GGraphGrids;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              final t =
                  state.chart!.theme.graphThemes[GGraphGrids.typeName]!
                      as GGraphGridsTheme;
              graph.theme = t.copyWith(
                lineStyle: PaintStyle(
                  strokeColor: Colors.deepPurpleAccent,
                  strokeWidth: 0.5,
                  dash: const [2, 2],
                ),
              );
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget ohlc(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph = panel.findGraphById("g-ohlc")! as GGraphOhlc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "drawAsCandle",
          description: "draw as candlestick or ohlc",
        ),
        AppToggleButtonsBoolean(
          selected: graph.drawAsCandle,
          labelResolver: (b) => b ? "CandleStick" : "OHLC",
          onSelected: (b) {
            graph.drawAsCandle = b;
            state.notify();
          },
        ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              final t =
                  state.chart!.theme.graphThemes[GGraphOhlc.typeName]!
                      as GGraphOhlcTheme;
              graph.theme = t.copyWith(
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
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget bar(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph = panel.findGraphById("g-bar")! as GGraphBar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "baseValue",
          description:
              "'baseValue' decides start position where first bar segment draw from",
        ),
        AppToggleButtonsBoolean(
          selected: graph.baseValue != null,
          onSelected: (b) {
            graph.baseValue = b ? 0 : null;
            state.notify();
          },
        ),
        Slider(
          value: ((graph.baseValue ?? 0) / 1_000_000).round().toDouble(),
          onChanged: (graph.baseValue == null)
              ? null
              : (value) {
                  graph.baseValue = value.round().toDouble() * 1_000_000;
                  state.notify();
                },
          min: 0,
          max: 200,
          divisions: 10,
          label: "${((graph.baseValue ?? 0) / 1_000_000).round().toDouble()}M",
        ),
        const ControlLabel(
          label: "basePosition",
          description:
              "'basePosition' decides start position where the first bar segment draws from (0=top, 0.5=middle, 1=bottom).",
        ),
        Slider(
          value: graph.basePosition,
          onChanged: (graph.baseValue != null)
              ? null
              : (value) {
                  graph.basePosition = value;
                  state.notify();
                },
          min: 0,
          max: 1,
          divisions: 10,
          label: graph.basePosition.toStringAsFixed(1),
        ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              final t =
                  state.chart!.theme.graphThemes[GGraphBar.typeName]!
                      as GGraphBarTheme;
              graph.theme = t.copyWith(
                barWidthRatio: 0.7,
                barStyleAboveBase: PaintStyle(
                  fillColor: Colors.blue,
                  strokeColor: Colors.orange,
                  strokeWidth: 0.5,
                ),
                barStyleBelowBase: PaintStyle(
                  fillColor: Colors.purple,
                  strokeColor: Colors.blueGrey,
                  strokeWidth: 0.5,
                ),
              );
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget stackedBar(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph = panel.findGraphById("g-stacked-bar")! as GGraphStackedBar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "baseValue",
          description:
              "'baseValue' decides start position where first bar segment draw from",
        ),
        AppToggleButtonsBoolean(
          selected: graph.baseValue != null,
          onSelected: (b) {
            graph.baseValue = b ? 0 : null;
            state.notify();
          },
        ),
        Slider(
          value: (graph.baseValue ?? 0),
          onChanged: (graph.baseValue == null)
              ? null
              : (value) {
                  graph.baseValue = value;
                  state.notify();
                },
          min: 0,
          max: 500,
          divisions: 10,
          label: "${(graph.baseValue ?? 0)}",
        ),
        const ControlLabel(
          label: "basePosition",
          description:
              "'basePosition' decides start position where the first bar segment draws from (0=top, 0.5=middle, 1=bottom).",
        ),
        AppToggleButtonsBoolean(
          selected: graph.basePosition != null,
          onSelected: (b) {
            graph.basePosition = b ? 0 : null;
            state.notify();
          },
        ),
        Slider(
          value: graph.basePosition ?? 0,
          onChanged: (graph.basePosition == null)
              ? null
              : (value) {
                  graph.basePosition = value;
                  state.notify();
                },
          min: 0,
          max: 1,
          divisions: 10,
          label: graph.basePosition?.toStringAsFixed(1),
        ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              final t =
                  state.chart!.theme.graphThemes[GGraphStackedBar.typeName]!
                      as GGraphStackedBarTheme;
              graph.theme = t.copyWith(
                barWidthRatio: 0.6,
                barStyles: [
                  PaintStyle(
                    fillColor: Colors.blue.withAlpha(200),
                    strokeColor: Colors.blueAccent,
                    strokeWidth: 1,
                  ),
                  PaintStyle(
                    fillColor: Colors.orange.withAlpha(200),
                    strokeColor: Colors.orangeAccent,
                    strokeWidth: 1,
                  ),
                  PaintStyle(
                    fillColor: Colors.purple.withAlpha(200),
                    strokeColor: Colors.purpleAccent,
                    strokeWidth: 1,
                  ),
                ],
              );
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget line(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph =
        (panel.findGraphById("g-group")! as GGraphGroup).findGraphById(
              "ichi-lagging",
            )!
            as GGraphLine;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "smoothing",
          description: "apply smoothing to the line",
        ),
        AppToggleButtonsBoolean(
          selected: graph.smoothing,
          onSelected: (b) {
            graph.smoothing = b;
            state.notify();
          },
        ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              final t =
                  state.chart!.theme.graphThemes[GGraphLine.typeName]!
                      as GGraphLineTheme;
              graph.theme = t.copyWith(
                lineStyle: PaintStyle(strokeColor: Colors.red, strokeWidth: 2),
                pointRadius: 3,
                pointStyle: PaintStyle(fillColor: Colors.orange),
              );
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget area(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph =
        (panel.findGraphById("g-group")! as GGraphGroup).findGraphById(
              "ichi-ab",
            )!
            as GGraphArea;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "baseValueKey",
          description:
              "the area will be the space between 'valueKey' and 'baseValueKey' when 'baseValueKey' set."
              "\nor the area will be the space between 'valueKey' and 'baseValue'.",
        ),
        AppToggleButtonsBoolean(
          selected: graph.baseValueKey != null,
          labelResolver: (b) => b ? keyIchimokuSpanB : "null",
          onSelected: (b) {
            graph.baseValueKey = b ? keyIchimokuSpanB : null;
            state.notify();
          },
        ),
        if (graph.baseValueKey == null)
          const ControlLabel(
            label: "baseValue",
            description:
                "the area will be the space between 'valueKey' and 'baseValue' when 'baseValueKey' not being set.",
          ),
        if (graph.baseValueKey == null)
          Slider(
            value: (graph.baseValue ?? 0).round().toDouble(),
            onChanged: (value) {
              graph.baseValue = value.round().toDouble();
              state.notify();
            },
            min: 0,
            max: 300,
            divisions: 30,
            label: "${(graph.baseValue ?? 0).round().toDouble()}",
          ),
        const ControlLabel(label: "theme", description: "use custom theme"),
        AppToggleButtonsBoolean(
          selected: graph.theme != null,
          labelResolver: (b) => b ? "Custom" : "Default",
          onSelected: (b) {
            if (b) {
              graph.theme = GGraphAreaTheme(
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
            } else {
              graph.theme = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }

  Widget group(BuildContext context, WorkshopState state) {
    final panel = state.chart!.panels[0];
    final graph = panel.findGraphById("g-group")! as GGraphGroup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "visible",
          description: "show/hide the graph",
        ),
        AppToggleButtonsBoolean(
          selected: graph.visible,
          onSelected: (b) {
            graph.visible = b;
            state.notify();
          },
        ),
      ],
    );
  }
}
