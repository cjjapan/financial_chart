import 'dart:math';

import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/rendering.dart';

part 'guides/10_start.dart';
part 'guides/20_graph.dart';
part 'guides/30_tooltip.dart';
part 'guides/40_markers.dart';
part 'guides/50_panel.dart';
part 'graphs/area.dart';
part 'graphs/line.dart';
part 'graphs/bar.dart';
part 'graphs/ohlc.dart';

GChart buildChart(String name, GDataSource dataSource, String theme) {
  switch (name) {
    case "guide_start":
      return chartGuideStart(dataSource, theme);
    case "guide_graph":
      return chartGuideGraph(dataSource, theme);
    case "guide_tooltip":
      return chartGuideTooltip(dataSource, theme);
    case "guide_markers":
      return chartGuideMarkers(dataSource, theme);
    case "guide_panel":
      return chartGuidePanel(dataSource, theme);
    case "graph_area1":
      return chartAreaGraph(dataSource, theme, "1");
    case "graph_area2":
      return chartAreaGraph(dataSource, theme, "2");
    case "graph_area3":
      return chartAreaGraph(dataSource, theme, "3");
    case "graph_line1":
      return chartLineGraph(dataSource, theme, "1");
    case "graph_line2":
      return chartLineGraph(dataSource, theme, "2");
    case "graph_bar1":
      return chartBarGraph(dataSource, theme, "1");
    case "graph_bar2":
      return chartBarGraph(dataSource, theme, "2");
    case "graph_bar3":
      return chartBarGraph(dataSource, theme, "3");
    case "graph_ohlc1":
      return chartOhlcGraph(dataSource, theme, "1");
    case "graph_ohlc2":
      return chartOhlcGraph(dataSource, theme, "2");
    default:
      throw Exception("Chart '$name' is not implemented.");
  }
}
