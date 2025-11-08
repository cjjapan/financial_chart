import 'package:flutter/painting.dart';

import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/size.dart';
import '../../values/value.dart';
import 'rect_marker_render.dart';

/// Rectangle marker for displaying rectangular shapes.
class GRectMarker extends GOverlayMarker {
  final GValue<GSize?> _cornerRadiusSize;

  /// Gets the corner radius size.
  GSize? get cornerRadiusSize => _cornerRadiusSize.value;

  /// Sets the corner radius size.
  set cornerRadiusSize(GSize? value) => _cornerRadiusSize.value = value;

  final GValue<GSize?> _pointRadiusSize;

  /// Gets the point radius size.
  GSize? get pointRadiusSize => _pointRadiusSize.value;

  /// Sets the point radius size.
  set pointRadiusSize(GSize? value) => _pointRadiusSize.value = value;

  final GValue<GSize?> _valueRadiusSize;

  /// Gets the value radius size.
  GSize? get valueRadiusSize => _valueRadiusSize.value;

  /// Sets the value radius size.
  set valueRadiusSize(GSize? value) => _valueRadiusSize.value = value;

  /// Gets the anchor coordinate (when using point radius mode).
  GCoordinate? get anchorCoord =>
      _pointRadiusSize.value == null ? null : keyCoordinates[0];

  /// Gets the starting coordinate (when using two-point mode).
  GCoordinate? get startCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[0];

  /// Gets the ending coordinate (when using two-point mode).
  GCoordinate? get endCoord =>
      _pointRadiusSize.value != null ? null : keyCoordinates[1];

  final GValue<Alignment> _alignment;

  /// Gets the alignment for the rectangle.
  Alignment get alignment => _alignment.value;

  /// Sets the alignment for the rectangle.
  set alignment(Alignment value) => _alignment.value = value;

  /// Creates a rectangle marker from two corner coordinates.
  GRectMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    GSize? cornerRadiusSize,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _pointRadiusSize = GValue<GSize?>(null),
       _valueRadiusSize = GValue<GSize?>(null),
       _alignment = GValue<Alignment>(Alignment.center),
       _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       super(keyCoordinates: [startCoord, endCoord]) {
    super.render = render ?? GRectMarkerRender();
  }

  GRectMarker.anchorAndRadius({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate anchorCoord,
    required GSize pointRadiusSize,
    required GSize valueRadiusSize,
    GSize? cornerRadiusSize,
    Alignment alignment = Alignment.center,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _cornerRadiusSize = GValue<GSize?>(cornerRadiusSize),
       _pointRadiusSize = GValue<GSize?>(pointRadiusSize),
       _valueRadiusSize = GValue<GSize?>(valueRadiusSize),
       _alignment = GValue<Alignment>(alignment),
       super(keyCoordinates: [anchorCoord]) {
    super.render = render ?? GRectMarkerRender();
  }
}
