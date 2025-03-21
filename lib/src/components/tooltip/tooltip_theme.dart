import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'tooltip.dart';

/// Theme for [GTooltip] component.
class GTooltipTheme extends GComponentTheme {
  /// Style of the tooltip frame.
  final PaintStyle frameStyle;

  /// Radius of the tooltip frame corner.
  final double frameCornerRadius;

  /// Padding of the tooltip frame.
  final double framePadding;

  /// Margin of the tooltip frame.
  final double frameMargin;

  /// Spacing between label and value.
  final double labelValueSpacing;

  /// Spacing between label & value rows.
  final double rowSpacing;

  /// Style of the tooltip label.
  final LabelStyle labelStyle;

  /// Style of the tooltip value.
  final LabelStyle valueStyle;

  /// Style of the highlighted point line/area.
  final PaintStyle? pointHighlightStyle;

  /// Style of the highlighted value line.
  final PaintStyle? valueHighlightStyle;

  const GTooltipTheme({
    required this.frameStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.pointHighlightStyle,
    this.valueHighlightStyle,
    this.frameCornerRadius = 2,
    this.framePadding = 6,
    this.frameMargin = 6,
    this.labelValueSpacing = 16,
    this.rowSpacing = 2,
  });

  GTooltipTheme copyWith({
    PaintStyle? frameStyle,
    LabelStyle? labelStyle,
    LabelStyle? valueStyle,
    PaintStyle? pointHighlightStyle,
    PaintStyle? valueHighlightStyle,
    double? frameCornerRadius,
    double? framePadding,
    double? frameMargin,
    double? labelValueSpacing,
    double? rowSpacing,
  }) {
    return GTooltipTheme(
      frameStyle: frameStyle ?? this.frameStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      pointHighlightStyle: pointHighlightStyle ?? this.pointHighlightStyle,
      valueHighlightStyle: valueHighlightStyle ?? this.valueHighlightStyle,
      frameCornerRadius: frameCornerRadius ?? this.frameCornerRadius,
      framePadding: framePadding ?? this.framePadding,
      frameMargin: frameMargin ?? this.frameMargin,
      labelValueSpacing: labelValueSpacing ?? this.labelValueSpacing,
      rowSpacing: rowSpacing ?? this.rowSpacing,
    );
  }
}
