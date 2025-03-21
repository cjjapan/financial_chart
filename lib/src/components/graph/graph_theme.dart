import '../../style/paint_style.dart';
import '../component_theme.dart';
import '../marker/marker_theme.dart';

/// Base class for graph themes
class GGraphTheme extends GComponentTheme {
  final GAxisMarkerTheme? axisMarkerTheme;
  final GGraphMarkerTheme? graphMarkerTheme;
  final GGraphHighlightMarkerTheme? highlightMarkerTheme;

  const GGraphTheme({
    this.axisMarkerTheme,
    this.graphMarkerTheme,
    this.highlightMarkerTheme,
  });
}

/// Theme for the markers of the graph when highlighted.
class GGraphHighlightMarkerTheme extends GComponentTheme {
  final PaintStyle style;
  final double size;
  final double interval;
  final PaintStyle? crosshairHighlightStyle;
  final double crosshairHighlightSize;

  const GGraphHighlightMarkerTheme({
    required this.style,
    this.size = 4.0,
    this.interval = 100.0,
    this.crosshairHighlightStyle,
    this.crosshairHighlightSize = 4.0,
  });

  GGraphHighlightMarkerTheme copyWith({
    PaintStyle? style,
    PaintStyle? crosshairHighlightStyle,
    double? crosshairHighlightSize,
    double? size,
    double? interval,
  }) {
    return GGraphHighlightMarkerTheme(
      style: style ?? this.style,
      size: size ?? this.size,
      interval: interval ?? this.interval,
      crosshairHighlightStyle:
          crosshairHighlightStyle ?? this.crosshairHighlightStyle,
      crosshairHighlightSize:
          crosshairHighlightSize ?? this.crosshairHighlightSize,
    );
  }
}
