import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'splitter.dart';

/// Theme for splitter components.
class GSplitterTheme extends GComponentTheme {
  /// Style for the splitter line.
  final PaintStyle lineStyle;

  /// Style for the handle background.
  final PaintStyle handleStyle;

  /// Style for the handle line decoration.
  final PaintStyle handleLineStyle;

  /// Width of the handle in pixels.
  final double handleWidth;

  /// Border radius of the handle in pixels.
  final double handleBorderRadius;

  /// Creates a splitter theme.
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
