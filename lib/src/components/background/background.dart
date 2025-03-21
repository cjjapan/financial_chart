import '../component.dart';
import 'background_render.dart';

/// Background of the chart.
class GBackground extends GComponent {
  GBackground({
    super.id,
    super.visible,
    super.theme,
    super.render = const GBackgroundRender(),
  });
}
