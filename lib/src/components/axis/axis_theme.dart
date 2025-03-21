import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'axis.dart';

/// Theme for the axis component.
class GAxisTheme extends GComponentTheme {
  /// Style of the line (vertical or horizontal) of the axis
  final PaintStyle lineStyle;

  /// Length of the tickers
  final double tickerLength;

  /// Style of the tickers
  final PaintStyle tickerStyle;

  /// Theme for the labels
  final GAxisLabelTheme labelTheme;

  /// Style of the selection area when selecting a range on the axis.
  ///
  /// only used when [GAxis.scaleMode] is [GAxisScaleMode.select]
  final PaintStyle selectionStyle;

  const GAxisTheme({
    required this.lineStyle,
    this.tickerLength = 5.0,
    required this.tickerStyle,
    required this.selectionStyle,
    required this.labelTheme,
  });

  GAxisTheme copyWith({
    PaintStyle? lineStyle,
    double? tickerLength,
    PaintStyle? tickerStyle,
    PaintStyle? selectionStyle,
    GAxisLabelTheme? labelTheme,
  }) {
    return GAxisTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      tickerLength: tickerLength ?? this.tickerLength,
      tickerStyle: tickerStyle ?? this.tickerStyle,
      selectionStyle: selectionStyle ?? this.selectionStyle,
      labelTheme: labelTheme ?? this.labelTheme,
    );
  }
}

/// Theme for the labels of the axis.
class GAxisLabelTheme {
  /// Style of the labels
  final LabelStyle labelStyle;

  /// Spacing between the label and the axis line
  final double spacing;

  const GAxisLabelTheme({required this.labelStyle, this.spacing = 5});

  GAxisLabelTheme copyWith({LabelStyle? labelStyle, double? spacing}) {
    return GAxisLabelTheme(
      labelStyle: labelStyle ?? this.labelStyle,
      spacing: spacing ?? this.spacing,
    );
  }
}
