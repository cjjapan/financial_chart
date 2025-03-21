import 'package:flutter/painting.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'rect_marker_render.dart';

class GRectMarker extends GGraphMarker {
  final GValue<GSize?> _cornerRadiusSize;
  GSize? get cornerRadiusSize => _cornerRadiusSize.value;
  set cornerRadiusSize(GSize? value) => _cornerRadiusSize.value = value;

  final GValue<GSize?> _pointRadiusSize;
  GSize? get pointRadiusSize => _pointRadiusSize.value;
  set pointRadiusSize(GSize? value) => _pointRadiusSize.value = value;

  final GValue<GSize?> _valueRadiusSize;
  GSize? get valueRadiusSize => _valueRadiusSize.value;
  set valueRadiusSize(GSize? value) => _valueRadiusSize.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  GRectMarker({
    String? id,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    GSize? cornerRadiusSize,
    GGraphMarkerTheme? theme,
    super.render = const GRectMarkerRender(),
  }) : _pointRadiusSize = GValue<GSize?>(null),
       _valueRadiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       super(id: id, keyCoordinates: [startCoord, endCoord], theme: theme);

  GRectMarker.anchorAndRadius({
    String? id,
    required GCoordinate anchorCoord,
    required GSize pointRadiusSize,
    required GSize valueRadiusSize,
    GSize? cornerRadiusSize,
    Alignment alignment = Alignment.center,
    GGraphMarkerTheme? theme,
    super.render = const GRectMarkerRender(),
  }) : _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       _pointRadiusSize = GValue<GSize?>(pointRadiusSize),
       _valueRadiusSize = GValue<GSize?>(valueRadiusSize),
       _alignment = GValue<Alignment>(alignment),
       super(id: id, keyCoordinates: [anchorCoord], theme: theme);
}
