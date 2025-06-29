import 'package:flutter/painting.dart';

import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'shape_marker_render.dart';

class GShapeMarker extends GOverlayMarker {
  final GValue<GSize> _radiusSize;
  GSize get radiusSize => _radiusSize.value;
  set radiusSize(GSize value) => _radiusSize.value = value;

  GCoordinate get anchorCoord => keyCoordinates[0];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _rotation;
  double get rotation => _rotation.value;
  set rotation(double value) => _rotation.value = value;

  final Path Function(double radius) pathGenerator;

  GShapeMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate anchorCoord,
    required GSize radiusSize,
    double rotation = 0,
    Alignment alignment = Alignment.center,
    required this.pathGenerator,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _radiusSize = GValue<GSize>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _rotation = GValue<double>(rotation),
       super(keyCoordinates: [anchorCoord]) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
    super.render = render ?? GShapeMarkerRender();
  }
}
