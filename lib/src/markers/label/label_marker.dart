import 'package:flutter/painting.dart';

import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'label_marker_render.dart';

/// Label marker for displaying text at a specific position.
class GLabelMarker extends GOverlayMarker {
  final GValue<String> _text;

  /// Gets the label text.
  String get text => _text.value;

  /// Sets the label text.
  set text(String value) => _text.value = value;

  final GValue<Alignment> _alignment;

  /// Gets the text alignment.
  Alignment get alignment => _alignment.value;

  /// Sets the text alignment.
  set alignment(Alignment value) => _alignment.value = value;

  /// Creates a label marker.
  GLabelMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required String text,
    required GCoordinate anchorCoord,
    Alignment alignment = Alignment.center,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : _text = GValue<String>(text),
       _alignment = GValue<Alignment>(alignment),
       super(keyCoordinates: [anchorCoord]) {
    super.render = render ?? GLabelMarkerRender();
  }
}
