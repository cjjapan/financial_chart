import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'spline_marker_render.dart';

class GSplineMarker extends GGraphMarker {
  final GValue<bool> _close;
  bool get close => _close.value;
  set close(bool value) => _close.value = value;

  GSplineMarker({
    String? id,
    required List<GCoordinate> coordinates,
    bool close = false,
    GGraphMarkerTheme? theme,
    super.render = const GSplineMarkerRender(),
  }) : _close = GValue<bool>(close),
       super(id: id, keyCoordinates: [...coordinates], theme: theme);
}
