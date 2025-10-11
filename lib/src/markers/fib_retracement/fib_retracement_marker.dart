import 'package:financial_chart/financial_chart.dart';

class GFibRetracementMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];

  final List<double> fibLevels = [];

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  final GValue<bool> _startRay = GValue<bool>(false);
  bool get startRay => _startRay.value;
  set startRay(bool value) => _startRay.value = value;

  final GValue<bool> _endRay = GValue<bool>(false);
  bool get endRay => _endRay.value;
  set endRay(bool value) => _endRay.value = value;

  GFibRetracementMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    List<double> fibLevels = const [0.0, 0.236, 0.382, 0.5, 0.618, 1.0],
    bool startRay = false,
    bool endRay = false,
    GRender? render,
  }) : super(keyCoordinates: [startCoord, endCoord]) {
    _startRay.value = startRay;
    _endRay.value = endRay;
    this.fibLevels.addAll(fibLevels);
    super.render = render ?? GFibRetracementMarkerRender();
  }
}
