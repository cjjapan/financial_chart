import 'package:financial_chart/financial_chart.dart';

class GFibCircleMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];

  final List<double> fibLevels = [];

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  GFibCircleMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    List<double> fibLevels = const [0.0, 0.236, 0.382, 0.5, 0.618, 1.0],
    GRender? render,
  }) : super(keyCoordinates: [startCoord, endCoord]) {
    this.fibLevels.addAll(fibLevels);
    super.render = render ?? GFibCircleMarkerRender();
  }
}
