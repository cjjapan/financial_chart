import 'package:flutter/cupertino.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'arc_marker_render.dart';

class GArcMarker extends GGraphMarker {
  final GValue<GSize?> _radiusSize;
  GSize? get radiusSize => _radiusSize.value;
  set radiusSize(GSize? value) => _radiusSize.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _startTheta;
  double get startTheta => _startTheta.value;
  set startTheta(double value) => _startTheta.value = value;

  final GValue<double> _endTheta;
  double get endTheta => _endTheta.value;
  set endTheta(double value) => _endTheta.value = value;

  final GValue<bool> _close;
  bool get close => _close.value;
  set close(bool value) => _close.value = value;

  GArcMarker({
    String? id,
    required GCoordinate centerCoord,
    required GCoordinate borderCoord,
    required double startTheta,
    required double endTheta,
    bool close = false,
    GGraphMarkerTheme? theme,
    super.render = const GArcMarkerRender(),
  }) : _radiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _close = GValue<bool>(close),
       super(
         id: id,
         keyCoordinates: [
           centerCoord,
           borderCoord,
         ], // the distance between "center" and "border" decides the render radius
         theme: theme,
       );

  GArcMarker.anchorAndRadius({
    String? id,
    required GCoordinate anchorCoord,
    required GSize radiusSize,
    required double startTheta,
    required double endTheta,
    bool close = false,
    Alignment alignment =
        Alignment
            .center, // where anchor point located on the bound rect of the circle
    GGraphMarkerTheme? theme,
    GGraphMarkerRender render = const GArcMarkerRender(),
  }) : _radiusSize = GValue<GSize?>(radiusSize),
       _alignment = GValue<Alignment>(alignment),
       _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       _close = GValue<bool>(close),
       super(
         id: id,
         keyCoordinates: [anchorCoord],
         theme: theme,
         render: render,
       ) {
    assert(radiusSize.sizeValue > 0, 'radius must be positive value.');
  }
}
