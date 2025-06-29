import '../component.dart';
import 'marker_render.dart';
import 'marker_theme.dart';

/// Base class for markers.
abstract class GMarker extends GComponent {
  GMarker({
    super.id,
    super.label,
    super.visible,
    super.highlighted,
    super.selected,
    super.locked,
    super.theme,
    super.render,
    super.layer,
    super.hitTestMode,
  });

  @override
  GMarkerRender<GMarker, GMarkerTheme> getRender() {
    return super.getRender() as GMarkerRender<GMarker, GMarkerTheme>;
  }
}
