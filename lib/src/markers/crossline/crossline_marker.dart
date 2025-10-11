import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'crossline_marker_render.dart';

class GCrosslineMarker extends GOverlayMarker {
  GCoordinate get anchor => keyCoordinates[0];
  set anchor(GCoordinate value) => keyCoordinates[0] = value;

  final GValue<bool> _leftRay;
  bool get leftRay => _leftRay.value;
  set leftRay(bool value) => _leftRay.value = value;

  final GValue<bool> _topRay;
  bool get topRay => _topRay.value;
  set topRay(bool value) => _topRay.value = value;

  final GValue<bool> _rightRay;
  bool get rightRay => _rightRay.value;
  set rightRay(bool value) => _rightRay.value = value;

  final GValue<bool> _bottomRay;
  bool get bottomRay => _bottomRay.value;
  set bottomRay(bool value) => _bottomRay.value = value;

  GCrosslineMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate anchor,
    bool leftRay = true,
    bool topRay = true,
    bool rightRay = true,
    bool bottomRay = true,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _leftRay = GValue<bool>(leftRay),
       _topRay = GValue<bool>(topRay),
       _rightRay = GValue<bool>(rightRay),
       _bottomRay = GValue<bool>(bottomRay),
       super(keyCoordinates: [anchor]) {
    super.render = render ?? GCrosslineMarkerRender();
  }
}

// ...existing code...
