import '../../style/paint_style.dart';
import '../component_theme.dart';
import '../marker/axis_marker_theme.dart';
import '../marker/overlay_marker_theme.dart';

/// Base theme for graph components.
class GGraphTheme extends GComponentTheme {
  /// Theme for axis markers.
  final GAxisMarkerTheme? axisMarkerTheme;

  /// Theme for overlay markers.
  final GOverlayMarkerTheme? overlayMarkerTheme;

  /// Theme for highlight markers.
  final GGraphHighlightMarkerTheme? highlightMarkerTheme;

  /// Creates a graph theme.
  const GGraphTheme({
    this.axisMarkerTheme,
    this.overlayMarkerTheme,
    this.highlightMarkerTheme,
  });
}

/// Theme for graph highlight markers.
class GGraphHighlightMarkerTheme extends GComponentTheme {
  /// Style for highlight markers.
  final PaintStyle style;

  /// Size of highlight markers in pixels.
  final double size;

  /// Interval between highlight markers in pixels.
  final double interval;

  /// Style for crosshair highlight markers.
  final PaintStyle? crosshairHighlightStyle;

  /// Size of crosshair highlight markers in pixels.
  final double crosshairHighlightSize;

  /// Creates a graph highlight marker theme.
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
