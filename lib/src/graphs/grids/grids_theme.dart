import '../../components/marker/marker_theme.dart';
import '../../style/paint_style.dart';
import '../../components/graph/graph_theme.dart';

/// Theme for grid lines
class GGraphGridsTheme extends GGraphTheme {
  final PaintStyle lineStyle;
  const GGraphGridsTheme({
    required this.lineStyle,
    super.axisMarkerTheme,
    super.graphMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphGridsTheme copyWith({
    PaintStyle? lineStyle,
    GAxisMarkerTheme? axisMarkerTheme,
    GGraphMarkerTheme? graphMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphGridsTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      graphMarkerTheme: graphMarkerTheme ?? this.graphMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
