import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_theme.dart';
import '../../style/paint_style.dart';

/// Theme for grid lines
class GGraphBarTheme extends GGraphTheme {
  final PaintStyle barStyleAboveBase;
  final PaintStyle barStyleBelowBase;
  final double barWidthRatio;
  const GGraphBarTheme({
    required this.barStyleAboveBase,
    required this.barStyleBelowBase,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.graphMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphBarTheme copyWith({
    PaintStyle? barStyleAboveBase,
    PaintStyle? barStyleBelowBase,
    double? barWidthRatio,
    GAxisMarkerTheme? axisMarkerTheme,
    GGraphMarkerTheme? graphMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphBarTheme(
      barStyleAboveBase: barStyleAboveBase ?? this.barStyleAboveBase,
      barStyleBelowBase: barStyleBelowBase ?? this.barStyleBelowBase,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      graphMarkerTheme: graphMarkerTheme ?? this.graphMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
