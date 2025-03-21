import '../../components/marker/marker_theme.dart';
import '../../style/paint_style.dart';
import '../../components/graph/graph_theme.dart';

/// Theme for OHLC graph
class GGraphOhlcTheme extends GGraphTheme {
  final PaintStyle lineStylePlus;
  final PaintStyle barStylePlus;
  final PaintStyle lineStyleMinus;
  final PaintStyle barStyleMinus;
  final double barWidthRatio;
  const GGraphOhlcTheme({
    required this.lineStylePlus,
    required this.barStylePlus,
    required this.lineStyleMinus,
    required this.barStyleMinus,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.graphMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphOhlcTheme copyWith({
    PaintStyle? lineStylePlus,
    PaintStyle? barStylePlus,
    PaintStyle? lineStyleMinus,
    PaintStyle? barStyleMinus,
    double? barWidthRatio,
    GAxisMarkerTheme? axisMarkerTheme,
    GGraphMarkerTheme? graphMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphOhlcTheme(
      lineStylePlus: lineStylePlus ?? this.lineStylePlus,
      barStylePlus: barStylePlus ?? this.barStylePlus,
      lineStyleMinus: lineStyleMinus ?? this.lineStyleMinus,
      barStyleMinus: barStyleMinus ?? this.barStyleMinus,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      graphMarkerTheme: graphMarkerTheme ?? this.graphMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
