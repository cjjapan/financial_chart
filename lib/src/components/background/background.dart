import '../component.dart';
import 'background_render.dart';

/// Background component for the entire chart.
class GBackground extends GComponent {
  /// Creates a background component.
  GBackground({
    super.id,
    super.visible,
    super.theme,
    super.render = const GBackgroundRender(),
  });
}
