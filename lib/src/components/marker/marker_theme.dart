import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import '../component_theme.dart';
import '../axis/axis_theme.dart';

/// Base class for marker theme
abstract class GMarkerTheme extends GComponentTheme {
  const GMarkerTheme();
}

/// Base class for axis marker theme
class GAxisMarkerTheme extends GMarkerTheme {
  final GAxisLabelTheme? valueAxisLabelTheme;
  final GAxisLabelTheme? pointAxisLabelTheme;
  final PaintStyle? valueRangeStyle;
  final PaintStyle? pointRangeStyle;

  const GAxisMarkerTheme({
    this.valueAxisLabelTheme,
    this.pointAxisLabelTheme,
    this.valueRangeStyle,
    this.pointRangeStyle,
  });

  GAxisMarkerTheme copyWith({
    GAxisLabelTheme? valueAxisLabelTheme,
    GAxisLabelTheme? pointAxisLabelTheme,
    PaintStyle? valueRangeStyle,
    PaintStyle? pointRangeStyle,
  }) {
    return GAxisMarkerTheme(
      valueAxisLabelTheme: valueAxisLabelTheme ?? this.valueAxisLabelTheme,
      pointAxisLabelTheme: pointAxisLabelTheme ?? this.pointAxisLabelTheme,
      valueRangeStyle: valueRangeStyle ?? this.valueRangeStyle,
      pointRangeStyle: pointRangeStyle ?? this.pointRangeStyle,
    );
  }
}

/// Base class for graph marker theme
class GGraphMarkerTheme extends GMarkerTheme {
  final PaintStyle markerStyle;
  final LabelStyle? labelStyle;
  final PaintStyle? controlPointsStyle;

  const GGraphMarkerTheme({
    required this.markerStyle,
    this.labelStyle,
    this.controlPointsStyle,
  });

  GGraphMarkerTheme copyWith({
    PaintStyle? controlPointsStyle,
    PaintStyle? markerStyle,
    LabelStyle? labelStyle,
  }) {
    return GGraphMarkerTheme(
      controlPointsStyle: controlPointsStyle ?? this.controlPointsStyle,
      markerStyle: markerStyle ?? this.markerStyle,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
