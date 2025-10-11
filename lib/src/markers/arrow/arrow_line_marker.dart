import 'arrow_line_marker_render.dart';

import '../../components/marker/overlay_marker.dart';
import '../../values/coord.dart';
import '../../values/value.dart';

enum GArrowHeadType { none, triangle, open, stealth, diamond, oval }

class GArrowHead {
  final GArrowHeadType type;
  final double length;
  final double width;

  const GArrowHead({
    this.type = GArrowHeadType.triangle,
    this.length = 10,
    this.width = 5,
  });

  GArrowHead copyWith({GArrowHeadType? type, double? length, double? width}) {
    return GArrowHead(
      type: type ?? this.type,
      length: length ?? this.length,
      width: width ?? this.width,
    );
  }

  @override
  String toString() {
    return 'GArrowHead(type: $type, headLength: $length, headWidth: $width)';
  }
}

class GArrowLineMarker extends GOverlayMarker {
  late final GValue<GArrowHead> _headStart;
  GArrowHead get startHead => _headStart.value;
  set startHead(GArrowHead value) => _headStart.value = value;

  late final GValue<GArrowHead> _headEnd;
  GArrowHead get endHead => _headEnd.value;
  set endHead(GArrowHead value) => _headEnd.value = value;

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  GArrowLineMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.selected,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    GArrowHead? startHead,
    GArrowHead? endHead,
    GArrowLineMarkerRender? render,
    super.scaleHandler,
  }) : super(keyCoordinates: [startCoord, endCoord]) {
    _headStart = GValue<GArrowHead>(
      startHead ?? const GArrowHead(type: GArrowHeadType.none),
    );
    _headEnd = GValue<GArrowHead>(
      endHead ?? const GArrowHead(type: GArrowHeadType.triangle),
    );
    super.render = render ?? GArrowLineMarkerRender();
  }
}
