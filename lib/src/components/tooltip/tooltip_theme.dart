import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'tooltip.dart';

/// Theme for tooltip components.
class GTooltipTheme extends GComponentTheme {
  /// Style for the tooltip frame border and background.
  final PaintStyle frameStyle;

  /// Corner radius for the tooltip frame in pixels.
  final double frameCornerRadius;

  /// Padding inside the tooltip frame in pixels.
  final double framePadding;

  /// Margin around the tooltip frame in pixels.
  final double frameMargin;

  /// Spacing between label and value in pixels.
  final double labelValueSpacing;

  /// Spacing between rows in pixels.
  final double rowSpacing;

  /// Style for point value text.
  final LabelStyle pointStyle;

  /// Spacing between point row and value rows in pixels.
  final double pointRowSpacing;

  /// Style for value label text.
  final LabelStyle labelStyle;

  /// Style for value text.
  final LabelStyle valueStyle;

  /// Style for highlighted point line or area.
  final PaintStyle? pointHighlightStyle;

  /// Style of the highlighted value line.
  final PaintStyle? valueHighlightStyle;

  const GTooltipTheme({
    required this.frameStyle,
    required this.pointStyle,
    required this.labelStyle,
    required this.valueStyle,
    this.pointHighlightStyle,
    this.valueHighlightStyle,
    this.frameCornerRadius = 2,
    this.framePadding = 6,
    this.frameMargin = 6,
    this.labelValueSpacing = 16,
    this.rowSpacing = 2,
    this.pointRowSpacing = 6,
  });

  GTooltipTheme copyWith({
    PaintStyle? frameStyle,
    LabelStyle? pointStyle,
    LabelStyle? labelStyle,
    LabelStyle? valueStyle,
    PaintStyle? pointHighlightStyle,
    PaintStyle? valueHighlightStyle,
    double? frameCornerRadius,
    double? framePadding,
    double? frameMargin,
    double? labelValueSpacing,
    double? rowSpacing,
    double? pointRowSpacing,
  }) {
    return GTooltipTheme(
      frameStyle: frameStyle ?? this.frameStyle,
      pointStyle: pointStyle ?? this.pointStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      pointHighlightStyle: pointHighlightStyle ?? this.pointHighlightStyle,
      valueHighlightStyle: valueHighlightStyle ?? this.valueHighlightStyle,
      frameCornerRadius: frameCornerRadius ?? this.frameCornerRadius,
      framePadding: framePadding ?? this.framePadding,
      frameMargin: frameMargin ?? this.frameMargin,
      labelValueSpacing: labelValueSpacing ?? this.labelValueSpacing,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      pointRowSpacing: pointRowSpacing ?? this.pointRowSpacing,
    );
  }
}
