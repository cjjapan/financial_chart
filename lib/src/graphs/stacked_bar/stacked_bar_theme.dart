import '../../components/graph/graph_theme.dart';
import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';

/// Theme for stacked bar graph
class GGraphStackedBarTheme extends GGraphTheme {
  /// Defines rational value of bar width (0 to 1)
  final double barWidthRatio;

  /// Defines style for each bar segment.
  /// Should be same length with graph.valueKeys and mapped by index.
  final List<PaintStyle> barStyles;

  const GGraphStackedBarTheme({
    required this.barStyles,
    this.barWidthRatio = 0.8,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  }) : assert(barWidthRatio > 0 && barWidthRatio <= 1),
       assert(barStyles.length > 0, 'barStyles cannot be empty');

  GGraphStackedBarTheme copyWith({
    List<PaintStyle>? barStyles,
    double? barWidthRatio,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphStackedBarTheme(
      barStyles: barStyles ?? this.barStyles,
      barWidthRatio: barWidthRatio ?? this.barWidthRatio,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
