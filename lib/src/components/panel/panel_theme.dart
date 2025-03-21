import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'panel.dart';

/// Theme for [GPanel]
class GPanelTheme extends GComponentTheme {
  final PaintStyle style;

  const GPanelTheme({required this.style});

  GPanelTheme copyWith({PaintStyle? style}) {
    return GPanelTheme(style: style ?? this.style);
  }
}
