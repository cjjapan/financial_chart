import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import 'polyline_marker_render.dart';

class GPolyLineMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];
  GPolyLineMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required List<GCoordinate> coordinates,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : super(keyCoordinates: [...coordinates]) {
    super.render = render ?? GPolyLineMarkerRender();
  }
}
