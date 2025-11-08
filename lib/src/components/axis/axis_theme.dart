import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import '../components.dart';

/// Theme for axis components.
class GAxisTheme extends GComponentTheme {
  /// Style for the main axis line.
  final PaintStyle lineStyle;

  /// Length of tick marks in pixels.
  final double tickerLength;

  /// Style for tick marks.
  final PaintStyle tickerStyle;

  /// Theme for axis labels.
  final GAxisLabelTheme labelTheme;

  /// Style for the selection area during range selection.
  final PaintStyle selectionStyle;

  /// Theme for axis markers.
  GAxisMarkerTheme? axisMarkerTheme;

  /// Theme for overlay markers.
  GOverlayMarkerTheme? overlayMarkerTheme;

  /// Creates an axis theme.
  GAxisTheme({
    required this.lineStyle,
    this.tickerLength = 5.0,
    required this.tickerStyle,
    required this.selectionStyle,
    required this.labelTheme,
    this.axisMarkerTheme,
    this.overlayMarkerTheme,
  });

  GAxisTheme copyWith({
    PaintStyle? lineStyle,
    double? tickerLength,
    PaintStyle? tickerStyle,
    PaintStyle? selectionStyle,
    GAxisLabelTheme? labelTheme,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
  }) {
    return GAxisTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      tickerLength: tickerLength ?? this.tickerLength,
      tickerStyle: tickerStyle ?? this.tickerStyle,
      selectionStyle: selectionStyle ?? this.selectionStyle,
      labelTheme: labelTheme ?? this.labelTheme,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
    );
  }
}

/// Theme for axis labels.
class GAxisLabelTheme {
  /// Style for label text and appearance.
  final LabelStyle labelStyle;

  /// Spacing between labels and the axis line in pixels.
  final double spacing;

  /// Creates an axis label theme.
  const GAxisLabelTheme({required this.labelStyle, this.spacing = 5});

  /// Creates a copy of this theme with modified properties.
  GAxisLabelTheme copyWith({LabelStyle? labelStyle, double? spacing}) {
    return GAxisLabelTheme(
      labelStyle: labelStyle ?? this.labelStyle,
      spacing: spacing ?? this.spacing,
    );
  }
}
