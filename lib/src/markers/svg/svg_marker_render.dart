import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';

import '../../chart.dart';
import '../../components/components.dart';
import 'svg_marker.dart';

class GSvgMarkerRender
    extends GOverlayMarkerRender<GSvgMarker, GOverlayMarkerTheme> {
  PictureInfo? pictureInfo;
  Rect? pictureRect;

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GSvgMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isEmpty) {
      return;
    }

    if (marker.svgAssetKey.isEmpty && marker.svgXml.isEmpty) {
      return;
    }

    if (pictureInfo == null) {
      vg
          .loadPicture(
            marker.svgAssetKey.isNotEmpty
                ? SvgAssetLoader(marker.svgAssetKey)
                : SvgStringLoader(marker.svgXml),
            null,
          )
          .then((pictureInfo) {
            this.pictureInfo = pictureInfo;
            chart.repaint(layout: false);
          });
      return;
    }
    final anchor = marker.anchorCoord!.toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    pictureRect = GRenderUtil.drawSvg(
      pictureInfo: pictureInfo!,
      anchor: anchor,
      canvas: canvas,
      size: marker.size,
    );
  }

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    return pictureRect?.inflate(epsilon ?? 0).contains(position) == true;
  }
}
