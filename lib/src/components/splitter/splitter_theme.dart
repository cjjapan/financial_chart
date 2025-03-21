import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'splitter.dart';

/// Theme for [GSplitter]
class GSplitterTheme extends GComponentTheme {
  final PaintStyle lineStyle;
  final PaintStyle handleStyle;
  final PaintStyle handleLineStyle;
  final double handleWidth;
  final double handleBorderRadius;

  const GSplitterTheme({
    required this.lineStyle,
    required this.handleStyle,
    required this.handleLineStyle,
    this.handleWidth = 60,
    this.handleBorderRadius = 4,
  });

  GSplitterTheme copyWith({
    PaintStyle? lineStyle,
    PaintStyle? handleStyle,
    PaintStyle? handleLineStyle,
    double? handleWidth,
    double? handleBorderRadius,
  }) {
    return GSplitterTheme(
      lineStyle: lineStyle ?? this.lineStyle,
      handleStyle: handleStyle ?? this.handleStyle,
      handleLineStyle: handleLineStyle ?? this.handleLineStyle,
      handleWidth: handleWidth ?? this.handleWidth,
      handleBorderRadius: handleBorderRadius ?? this.handleBorderRadius,
    );
  }
}
