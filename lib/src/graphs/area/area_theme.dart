import '../../components/graph/graph_theme.dart';
import '../../components/marker/axis_marker_theme.dart';
import '../../components/marker/overlay_marker_theme.dart';
import '../../style/paint_style.dart';

/// Theme for area graph
class GGraphAreaTheme extends GGraphTheme {
  final PaintStyle styleBaseLine;
  final PaintStyle styleValueAboveLine;
  final PaintStyle styleValueBelowLine;
  final PaintStyle styleAboveArea;
  final PaintStyle styleBelowArea;

  const GGraphAreaTheme({
    required this.styleBaseLine,
    required this.styleValueAboveLine,
    required this.styleValueBelowLine,
    required this.styleAboveArea,
    required this.styleBelowArea,
    super.axisMarkerTheme,
    super.overlayMarkerTheme,
    super.highlightMarkerTheme,
  });

  GGraphAreaTheme copyWith({
    PaintStyle? styleBaseLine,
    PaintStyle? styleValueAboveLine,
    PaintStyle? styleValueBelowLine,
    PaintStyle? styleAboveArea,
    PaintStyle? styleBelowArea,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    GGraphHighlightMarkerTheme? highlightMarkerTheme,
  }) {
    return GGraphAreaTheme(
      styleBaseLine: styleBaseLine ?? this.styleBaseLine,
      styleValueAboveLine: styleValueAboveLine ?? this.styleValueAboveLine,
      styleValueBelowLine: styleValueBelowLine ?? this.styleValueBelowLine,
      styleAboveArea: styleAboveArea ?? this.styleAboveArea,
      styleBelowArea: styleBelowArea ?? this.styleBelowArea,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      highlightMarkerTheme: highlightMarkerTheme ?? this.highlightMarkerTheme,
    );
  }
}
