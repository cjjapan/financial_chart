import '../../style/paint_style.dart';
import '../component_theme.dart';
import '../axis/axis_theme.dart';
import 'crosshair.dart';

/// Theme for crosshair components.
class GCrosshairTheme extends GComponentTheme {
  /// Style for crosshair lines.
  final PaintStyle lineStyle;

  /// Theme for value axis labels.
  final GAxisLabelTheme valueLabelTheme;

  /// Theme for point axis labels.
  final GAxisLabelTheme pointLabelTheme;

  /// Creates a crosshair theme.
  const GCrosshairTheme({
    required this.lineStyle,
    required this.valueLabelTheme,
    required this.pointLabelTheme,
  });

  GCrosshairTheme copyWith({
    PaintStyle? lineStyle,
    GAxisLabelTheme? valueLabelTheme,
    GAxisLabelTheme? pointLabelTheme,
  }) {
    return GCrosshairTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      valueLabelTheme: valueLabelTheme ?? this.valueLabelTheme,
      pointLabelTheme: pointLabelTheme ?? this.pointLabelTheme,
    );
  }
}
