import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'background.dart';

/// Theme for background components.
class GBackgroundTheme extends GComponentTheme {
  /// Style for the background fill.
  final PaintStyle style;

  /// Creates a background theme.
  const GBackgroundTheme({required this.style});

  /// Creates a copy of this theme with modified properties.
  GBackgroundTheme copyWith({PaintStyle? style}) {
    return GBackgroundTheme(style: style ?? this.style);
  }
}
