import 'package:flutter/material.dart';

import '../../components/marker/overlay_marker.dart';
import '../../components/marker/overlay_marker_render.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import 'svg_marker_render.dart';

class GSvgMarker extends GOverlayMarker {
  /// The asset key of the SVG file to be used to draw the svg marker.
  /// Either [svgAssetKey] or [svgXml] must be provided.
  final GValue<String> _svgAssetKey;
  String get svgAssetKey => _svgAssetKey.value;
  set svgAssetKey(String value) => _svgAssetKey.value = value;

  /// The SVG XML string to be used to draw the svg marker.
  /// Either [svgAssetKey] or [svgXml] must be provided.
  final GValue<String> _svgXml;
  String get svgXml => _svgXml.value;
  set svgXml(String value) => _svgXml.value = value;

  final GValue<Alignment> _alignment;
  Alignment get alignment => _alignment.value;
  set alignment(Alignment value) => _alignment.value = value;

  final GValue<Size?> _size;
  Size? get size => _size.value;
  set size(Size? value) => _size.value = value;

  GCoordinate? get anchorCoord => keyCoordinates[0];

  GSvgMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate anchorPosition,
    String? svgAssetKey,
    String? svgXml,
    Alignment alignment = Alignment.center,
    Size? size,
    bool close = false,
    GOverlayMarkerRender? render,
    super.scaleHandler,
  }) : assert(
         svgAssetKey?.isNotEmpty == true || svgXml?.isNotEmpty == true,
         "svgAssetKey or svgXml must be provided",
       ),
       _svgAssetKey = GValue<String>(svgAssetKey ?? ''),
       _svgXml = GValue<String>(svgXml ?? ''),
       _alignment = GValue<Alignment>(alignment),
       _size = GValue<Size?>(size),
       super(keyCoordinates: [anchorPosition]) {
    super.render = render ?? GSvgMarkerRender();
  }
}
