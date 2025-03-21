import 'package:flutter/painting.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'label_marker_render.dart';

class GLabelMarker extends GGraphMarker {
  final GValue<String> _text;
  String get text => _text.value;
  set text(String value) => _text.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  GLabelMarker({
    String? id,
    required String text,
    required GCoordinate anchorCoord,
    Alignment alignment = Alignment.center,
    GGraphMarkerTheme? theme,
    super.render = const GLabelMarkerRender(),
  }) : _text = GValue<String>(text),
       _alignment = GValue<Alignment>(alignment),
       super(id: id, keyCoordinates: [anchorCoord], theme: theme);
}
