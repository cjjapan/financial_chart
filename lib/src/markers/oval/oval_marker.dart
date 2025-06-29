import 'package:flutter/painting.dart';

import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'oval_marker_render.dart';

class GOvalMarker extends GOverlayMarker {
  final GValue<GSize?> _pointRadiusSize;
  GSize? get pointRadiusSize => _pointRadiusSize.value;
  set pointRadiusSize(GSize? value) => _pointRadiusSize.value = value;

  final GValue<GSize?> _valueRadiusSize;
  GSize? get valueRadiusSize => _valueRadiusSize.value;
  set valueRadiusSize(GSize? value) => _valueRadiusSize.value = value;

  GCoordinate? get anchorCoord =>
      _pointRadiusSize.value == null ? null : keyCoordinates[0];
  GCoordinate? get startCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[0];
  GCoordinate? get endCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[1];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  GOvalMarker.corner({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _pointRadiusSize = GValue<GSize?>(null),
       _valueRadiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       super(keyCoordinates: [startCoord, endCoord]) {
    super.render = render ?? GOvalMarkerRender();
  }

  GOvalMarker.anchorAndRadius({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate anchorCoord,
    required GSize pointRadiusSize,
    required GSize valueRadiusSize,
    required Alignment alignment,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _pointRadiusSize = GValue<GSize?>(pointRadiusSize),
       _valueRadiusSize = GValue<GSize?>(valueRadiusSize),
       _alignment = GValue<Alignment>(alignment),
       super(keyCoordinates: [anchorCoord]) {
    super.render = render ?? GOvalMarkerRender();
  }
}
