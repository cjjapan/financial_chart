import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'panel.dart';

/// Theme for panel components.
class GPanelTheme extends GComponentTheme {
  /// Style for the panel background.
  final PaintStyle style;

  /// Creates a panel theme.
  const GPanelTheme({required this.style});

  /// Creates a copy of this theme with modified properties.
  GPanelTheme copyWith({PaintStyle? style}) {
    return GPanelTheme(style: style ?? this.style);
  }
}
