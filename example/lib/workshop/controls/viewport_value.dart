import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/control_label.dart';
import '../../widgets/toggle_buttons.dart';
import '../workshop_state.dart';

class ValueViewPortControlView extends StatefulWidget {
  const ValueViewPortControlView({super.key});

  @override
  State<ValueViewPortControlView> createState() =>
      _ValueViewPortControlViewState();
}

class _ValueViewPortControlViewState extends State<ValueViewPortControlView> {
  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    final viewPort = chart.panels[0].findValueViewPortById("vp-price");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        const ControlLabel(
          label: "range",
          description:
              "update or reset the visible range of Value viewport (on y direction)",
        ),
        AppToggleButtons<String>(
          items: const ["Zoom in"],
          minWidth: 160,
          onSelected: (btn) {
            viewPort.zoom(chart.panels[0].graphArea(), 0.7);
          },
        ),
        AppToggleButtons<String>(
          items: const ["Zoom out"],
          minWidth: 160,
          onSelected: (btn) {
            viewPort.zoom(chart.panels[0].graphArea(), 1.5);
          },
        ),
        AppToggleButtons<String>(
          items: const ["Reset"],
          minWidth: 160,
          onSelected: (btn) {
            viewPort.autoScaleFlg = true;
            chart.autoScaleViewports(
              resetValueViewPort: true,
              resetPointViewPort: false,
            );
            state.notify();
          },
        ),
        const ControlLabel(
          label: "animationMilliseconds",
          description:
              "change scaling animation duration (in milliseconds)"
              "\nclick the 'Zoom in' / 'Zoom out' button to see the animation effect.",
        ),
        Slider(
          value: viewPort.animationMilliseconds.toDouble(),
          onChanged: (value) {
            viewPort.animationMilliseconds = value.toInt();
            state.notify();
          },
          onChangeEnd: (value) {},
          min: 0,
          max: 1000,
          divisions: 10,
          label: "${chart.pointViewPort.animationMilliseconds} ms",
        ),
        const ControlLabel(
          label: "resizeMode",
          description:
              "change the behavior how to update the value view port range when resizing the view size."
              "\nhere it apply to the price viewport in the top panel."
              "\nNOTICE this only works when the viewport's auto scale is off."
              "\nresize the window or panel to see the effect (on y direction).",
        ),
        AppToggleButtons<GViewPortResizeMode>(
          items: GViewPortResizeMode.values,
          labelResolver: (m) => m.name,
          selected: viewPort.resizeMode,
          onSelected: (mode) {
            viewPort.autoScaleFlg = false;
            viewPort.resizeMode = mode;
            state.notify();
          },
        ),
        const ControlLabel(
          label: "scaleType",
          description: "switch the value scale type.",
        ),
        AppToggleButtons<GValueViewPortScaleType>(
          items: GValueViewPortScaleType.values,
          labelResolver: (m) => m.name,
          selected: viewPort.scaleType,
          onSelected: (type) {
            viewPort.scaleType = type;
            state.notify();
          },
        ),
      ],
    );
  }
}
