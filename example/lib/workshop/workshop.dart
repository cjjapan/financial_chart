import 'workshop_chart.dart';
import 'workshop_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workshop_state.dart';

class WorkshopApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeMode;
  const WorkshopApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkshopState>(
      create: (_) => WorkshopState(themeMode: themeMode),
      child: Consumer<WorkshopState>(
        builder: (_, state, _) {
          return SafeArea(child: ChartWorkshopPage(key: state.workshopViewKey));
        },
      ),
    );
  }
}

class ChartWorkshopPage extends StatefulWidget {
  const ChartWorkshopPage({super.key});

  @override
  ChartWorkshopPageState createState() => ChartWorkshopPageState();
}

class ChartWorkshopPageState extends State<ChartWorkshopPage>
    with TickerProviderStateMixin {
  static const double breakPoint = 720;
  static const double drawerWidth = 360;
  static const double paddingSize = 8;
  late final TabController tabController;

  ChartWorkshopPageState();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: controlTabs.length, vsync: this);
    Provider.of<WorkshopState>(context, listen: false).loadData();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workshopState = Provider.of<WorkshopState>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 56, title: const Text('Chart workshop')),
      drawer: size.width < breakPoint
          ? Padding(
              padding: const EdgeInsets.only(top: 56, bottom: paddingSize),
              child: Drawer(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                width: drawerWidth,
                child: drawer(context, workshopState, true),
              ),
            )
          : null,
      body: size.width < breakPoint
          ? body(context, workshopState)
          : Row(
              children: [
                drawer(context, workshopState, false),
                Expanded(child: body(context, workshopState)),
              ],
            ),
    );
  }

  Widget body(BuildContext context, WorkshopState workshopState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        paddingSize,
        0,
        paddingSize,
        paddingSize,
      ),
      child: WorkshopChartView(workshopState: workshopState),
    );
  }

  Widget drawer(
    BuildContext context,
    WorkshopState workshopState,
    bool isDrawer,
  ) {
    return Container(
      width: drawerWidth,
      padding: const EdgeInsets.fromLTRB(paddingSize, 0, 0, paddingSize),
      child: WorkshopControlView(
        workshopState: workshopState,
        isDrawer: isDrawer,
        tabController: tabController,
      ),
    );
  }
}
