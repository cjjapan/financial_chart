import 'package:flutter/painting.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'oval_marker_render.dart';

class GOvalMarker extends GGraphMarker {
  final GValue<GSize?> _pointRadiusSize;
  GSize? get pointRadiusSize => _pointRadiusSize.value;
  set pointRadiusSize(GSize? value) => _pointRadiusSize.value = value;

  final GValue<GSize?> _valueRadiusSize;
  GSize? get valueRadiusSize => _valueRadiusSize.value;
  set valueRadiusSize(GSize? value) => _valueRadiusSize.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  GOvalMarker.corner({
    String? id,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    GGraphMarkerTheme? theme,
    super.render = const GOvalMarkerRender(),
  }) : _pointRadiusSize = GValue<GSize?>(null),
       _valueRadiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       super(id: id, keyCoordinates: [startCoord, endCoord], theme: theme);

  GOvalMarker.anchorAndRadius({
    String? id,
    required GCoordinate anchorCoord,
    required GSize pointRadiusSize,
    required GSize valueRadiusSize,
    required Alignment alignment,
    GGraphMarkerTheme? theme,
    super.render = const GOvalMarkerRender(),
  }) : _pointRadiusSize = GValue<GSize?>(pointRadiusSize),
       _valueRadiusSize = GValue<GSize?>(valueRadiusSize),
       _alignment = GValue<Alignment>(alignment),
       super(id: id, keyCoordinates: [anchorCoord], theme: theme);
}
