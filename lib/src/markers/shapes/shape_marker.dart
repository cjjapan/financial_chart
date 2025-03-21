import 'package:flutter/cupertino.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'shape_marker_render.dart';

class GShapeMarker extends GGraphMarker {
  final GValue<GSize> _radiusSize;
  GSize get radiusSize => _radiusSize.value;
  set radiusSize(GSize value) => _radiusSize.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _rotation;
  double get rotation => _rotation.value;
  set rotation(double value) => _rotation.value = value;

  final Path Function(double radius) pathGenerator;

  GShapeMarker({
    String? id,
    required GCoordinate anchorCoord,
    required GSize radiusSize,
    double rotation = 0,
    Alignment alignment =
        Alignment
            .center, // where anchor point located on the bound rect of the circle
    required this.pathGenerator,
    GGraphMarkerTheme? theme,
    super.render = const GShapeMarkerRender(),
  }) : _radiusSize = GValue<GSize>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _rotation = GValue<double>(rotation),
       super(id: id, keyCoordinates: [anchorCoord], theme: theme) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
  }
}
