import '../../style/paint_style.dart';
import '../component_theme.dart';
import '../axis/axis_theme.dart';
import 'crosshair.dart';

/// Theme for the [GCrosshair] component.
class GCrosshairTheme extends GComponentTheme {
  /// Style of the lines.
  final PaintStyle lineStyle;

  /// Theme for the value labels.
  final GAxisLabelTheme valueLabelTheme;

  /// Theme for the point labels.
  final GAxisLabelTheme pointLabelTheme;

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
