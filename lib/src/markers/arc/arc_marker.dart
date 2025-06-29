import 'package:flutter/painting.dart';

import '../../components/components.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'arc_marker_render.dart';

class GArcMarker extends GOverlayMarker {
  final GValue<GSize?> _radiusSize;
  GSize? get radiusSize => _radiusSize.value;
  set radiusSize(GSize? value) => _radiusSize.value = value;

  GCoordinate? get anchorCoord =>
      _radiusSize.value == null ? null : keyCoordinates[0];
  GCoordinate? get centerCoord =>
      _radiusSize.value != null ? null : keyCoordinates[0];
  GCoordinate? get borderCoord =>
      _radiusSize.value != null ? null : keyCoordinates[1];

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _startTheta;
  double get startTheta => _startTheta.value;
  set startTheta(double value) => _startTheta.value = value;

  final GValue<double> _endTheta;
  double get endTheta => _endTheta.value;
  set endTheta(double value) => _endTheta.value = value;

  final GValue<GArcCloseType> _closeType;
  GArcCloseType get closeType => _closeType.value;
  set closeType(GArcCloseType value) => _closeType.value = value;

  GArcMarker({
    super.id,
    super.label,
    super.visible,
    super.theme,
    super.layer,
    super.hitTestMode,
    required GCoordinate centerCoord,
    required GCoordinate borderCoord,
    required double startTheta,
    required double endTheta,
    GArcCloseType closeType = GArcCloseType.none,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _radiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _closeType = GValue<GArcCloseType>(closeType),
       super(
         keyCoordinates: [
           centerCoord,
           borderCoord,
         ], // the distance between "center" and "border" decides the render radius
       ) {
    super.render = render ?? GArcMarkerRender();
  }

  GArcMarker.anchorAndRadius({
    super.id,
    super.label,
    super.visible,
    super.theme,
    super.layer,
    super.hitTestMode,
    required GCoordinate centerOCoord,
    required GSize radiusSize,
    required double startTheta,
    required double endTheta,
    GArcCloseType closeType = GArcCloseType.none,
    Alignment alignment =
        Alignment
            .center, // where anchor point located on the bound rect of the circle
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _radiusSize = GValue<GSize?>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _closeType = GValue<GArcCloseType>(closeType),
       super(keyCoordinates: [centerOCoord]) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
    super.render = render ?? GArcMarkerRender();
  }
}
