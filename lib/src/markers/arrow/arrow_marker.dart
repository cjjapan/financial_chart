import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'arrow_marker_render.dart';

/// Arrow marker for displaying directional arrows.
@Deprecated("Use GArrowLineMarker instead")
class GArrowMarker extends GOverlayMarker {
  final GValue<double> _headWidth;

  /// Gets the arrow head width in pixels.
  double get headWidth => _headWidth.value;

  /// Sets the arrow head width in pixels.
  set headWidth(double value) => _headWidth.value = value;

  final GValue<double> _headLength;

  /// Gets the arrow head length in pixels.
  double get headLength => _headLength.value;

  /// Sets the arrow head length in pixels.
  set headLength(double value) => _headLength.value = value;

  /// Gets the starting coordinate of the arrow.
  GCoordinate get startCoord => keyCoordinates[0];

  /// Gets the ending coordinate of the arrow.
  GCoordinate get endCoord => keyCoordinates[1];

  /// Creates an arrow marker.
  GArrowMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    double headWidth = 4,
    double headLength = 10,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _headWidth = GValue<double>(headWidth),
       _headLength = GValue<double>(headLength),
       super(keyCoordinates: [startCoord, endCoord]) {
    super.render = render ?? GArrowMarkerRender();
  }
}
