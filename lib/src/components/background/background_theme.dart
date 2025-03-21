import '../../style/paint_style.dart';
import '../component_theme.dart';
import 'background.dart';

/// Theme for the [GBackground] component.
class GBackgroundTheme extends GComponentTheme {
  final PaintStyle style;

  const GBackgroundTheme({required this.style});

  GBackgroundTheme copyWith({PaintStyle? style}) {
    return GBackgroundTheme(style: style ?? this.style);
  }
}
