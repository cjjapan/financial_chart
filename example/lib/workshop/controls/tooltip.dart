import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/indicator_providers.dart';
import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class TooltipControlView extends StatefulWidget {
  const TooltipControlView({super.key});

  @override
  State<TooltipControlView> createState() => _TooltipControlViewState();
}

class _TooltipControlViewState extends State<TooltipControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "position",
          description:
              "change the position of the tooltip. "
              "\nmove pointer hover the chart to see the tooltip.",
        ),
        AppToggleButtons<GTooltipPosition>(
          minWidth: 160,
          direction: Axis.vertical,
          items: GTooltipPosition.values,
          labelResolver: (m) => m.name,
          selected: chart.panels[0].tooltip!.position,
          onSelected: (mode) {
            for (var panel in chart.panels) {
              panel.tooltip?.position = mode;
            }
            state.notify();
          },
        ),
        const ControlLabel(
          label: "followValueKey",
          description:
              "config the value key that decides tooltip's vertical position when GTooltip.position is 'followPointer'."
              "\nhere it apply to the first panel.",
        ),
        AppToggleButtons<String>(
          minWidth: 160,
          direction: Axis.vertical,
          items: const ['', keyOpen, keyClose, keyHigh, keyLow, keySMA],
          labelResolver: (m) => m.isEmpty ? "null" : "'$m'",
          selected: chart.panels[0].tooltip!.followValueKey ?? 'null',
          onSelected: (key) {
            chart.panels[0].tooltip!.followValueKey =
                (key.isEmpty || key == "null") ? null : key;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "pointLineHighlightVisible",
          description: "Show/hide the vertical highlight line of current point",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[0].tooltip!.pointLineHighlightVisible,
          onSelected: (enable) {
            for (var panel in state.chart!.panels) {
              panel.tooltip?.pointLineHighlightVisible = enable;
            }
            state.notify();
          },
        ),
        const ControlLabel(
          label: "valueLineHighlightVisible",
          description:
              "Show/hide the horizontal highlight line of value defined by followValueKey",
        ),
        AppToggleButtonsBoolean(
          selected: state.chart!.panels[0].tooltip!.valueLineHighlightVisible,
          onSelected: (enable) {
            for (var panel in state.chart!.panels) {
              panel.tooltip?.valueLineHighlightVisible = enable;
            }
            state.notify();
          },
        ),
        const ControlLabel(
          label: "tooltipWidgetBuilder",
          description: "Use a flutter widget to display tooltip.",
        ),
        AppToggleButtonsBoolean(
          selected: chart.panels[0].tooltip!.tooltipWidgetBuilder != null,
          onSelected: (enable) {
            if (enable) {
              chart.panels[0].tooltip!.tooltipWidgetBuilder =
                  (context, size, tooltip, point) {
                    final values = chart.dataSource.getSeriesValueAsMap(
                      point: point,
                      keys: [keyOpen, keyHigh, keyLow, keyClose],
                    );
                    if (values.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final graphTheme =
                        chart.theme.graphThemes["ohlc"] as GGraphOhlcTheme;
                    final textColor = (values[keyOpen]! > values[keyClose]!
                        ? graphTheme.barStyleMinus.fillColor
                        : graphTheme.barStylePlus.fillColor);
                    return Container(
                      width: 160,
                      height: 100,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          ...values.entries.map((e) {
                            return Row(
                              children: [
                                Text(
                                  e.key.replaceFirst(
                                    e.key[0],
                                    e.key[0].toUpperCase(),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Expanded(child: SizedBox.shrink()),
                                Text(
                                  e.value.toStringAsFixed(2),
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  };
            } else {
              chart.panels[0].tooltip!.tooltipWidgetBuilder = null;
            }
            state.notify();
          },
        ),
      ],
    );
  }
}
