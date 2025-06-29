import 'package:flutter/material.dart';

import '../widgets/toggle_buttons.dart';
import 'controls/axes.dart';
import 'controls/chart.dart';
import 'controls/crosshair.dart';
import 'controls/graphs.dart';
import 'controls/markers.dart';
import 'controls/panels.dart';
import 'controls/tooltip.dart';
import 'controls/viewports.dart';
import 'workshop_state.dart';

const controlTabs = [
  "Chart",
  "Panels",
  "ViewPorts",
  "Axes",
  "Crosshair",
  "Tooltip",
  "Graphs",
  "Markers",
];

class WorkshopControlView extends StatefulWidget {
  final WorkshopState workshopState;
  final TabController tabController;
  final bool isDrawer;
  const WorkshopControlView({
    super.key,
    required this.workshopState,
    required this.isDrawer,
    required this.tabController,
  });

  @override
  WorkshopControlViewState createState() => WorkshopControlViewState();
}

class WorkshopControlViewState extends State<WorkshopControlView>
    with TickerProviderStateMixin {
  WorkshopControlViewState();

  static const padding = EdgeInsets.all(8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          widget.isDrawer
              ? null
              : BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
              ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ListenableBuilder(
                listenable: widget.tabController,
                builder: (context, child) {
                  return Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        if (widget.tabController.index > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_left_sharp),
                            onPressed: () {
                              widget.tabController.animateTo(
                                widget.tabController.index - 1,
                              );
                            },
                          ),
                        const Expanded(child: SizedBox.shrink()),
                        if (widget.tabController.index < controlTabs.length - 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_right_sharp),
                            onPressed: () {
                              widget.tabController.animateTo(
                                widget.tabController.index + 1,
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: TabBar(
                  controller: widget.tabController,
                  isScrollable: true,
                  padding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  tabs: controlTabs.map((e) => Tab(text: e)).toList(),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children:
                  controlTabs.map((t) {
                        switch (t) {
                          case "Chart":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: ChartControlView(),
                              ),
                            );
                          case "Panels":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: PanelControlView(),
                              ),
                            );
                          case "ViewPorts":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: ViewPortsControlView(),
                              ),
                            );
                          case "Axes":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: AxesControlView(),
                              ),
                            );
                          case "Crosshair":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: CrosshairControlView(),
                              ),
                            );
                          case "Tooltip":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: TooltipControlView(),
                              ),
                            );
                          case "Graphs":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: GraphsControlView(),
                              ),
                            );
                          case "Markers":
                            return Container(
                              padding: padding,
                              child: const SingleChildScrollView(
                                child: MarkersControlView(),
                              ),
                            );
                          default:
                            return Container(
                              padding: padding,
                              child: Center(child: Text(t)),
                            );
                        }
                      }).toList()
                      as List<Widget>,
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  children: [
                    const Text("theme"),
                    const Expanded(child: SizedBox.shrink()),
                    AppToggleButtons<ThemeMode>(
                      direction: Axis.horizontal,
                      items: const [ThemeMode.dark, ThemeMode.light],
                      labelResolver:
                          (m) =>
                              "${m.name[0].toUpperCase()}${m.name.substring(1)}",
                      selected: widget.workshopState.mode,
                      onSelected: (mode) {
                        widget.workshopState.mode = mode;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("reset"),
                    const Expanded(child: SizedBox.shrink()),
                    AppToggleButtons<String>(
                      items: const ["Reset"],
                      minWidth: 160,
                      onSelected: (btn) {
                        widget.workshopState.mode = ThemeMode.light;
                        widget.workshopState.loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
