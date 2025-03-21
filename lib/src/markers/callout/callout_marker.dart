import 'package:flutter/painting.dart';

import '../../components/marker/marker.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'callout_marker_render.dart';

class GCalloutMarker extends GGraphMarker {
  final GValue<String> _text;
  String get text => _text.value;
  set text(String value) => _text.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<double> _pointerSize;
  double get pointerSize => _pointerSize.value;
  set pointerSize(double value) => _pointerSize.value = value;

  final GValue<double> _pointerMargin;
  double get pointerMargin => _pointerMargin.value;
  set pointerMargin(double value) => _pointerMargin.value = value;

  GCalloutMarker({
    String? id,
    required String text,
    required GCoordinate anchorCoord,
    Alignment alignment = Alignment.center,
    double pointerSize = 10,
    double pointerMargin = 10,
    GGraphMarkerTheme? theme,
    GGraphMarkerRender render = const GCalloutMarkerRender(),
  }) : _text = GValue<String>(text),
       _alignment = GValue<Alignment>(alignment),
       _pointerSize = GValue<double>(pointerSize),
       _pointerMargin = GValue<double>(pointerMargin),
       super(
         id: id,
         keyCoordinates: [anchorCoord],
         theme: theme,
         render: render,
       );
}
