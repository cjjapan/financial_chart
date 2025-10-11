import 'package:financial_chart/financial_chart.dart';

class GFibTimeZoneMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  final GValue<double> _labelPosition = GValue<double>(0.5);
  double get labelPosition => _labelPosition.value;
  set labelPosition(double value) {
    _labelPosition.value = value.clamp(0, 1.0);
  }

  GFibTimeZoneMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    double labelPosition = 0.5,
    GRender? render,
  }) : super(keyCoordinates: [startCoord, endCoord]) {
    this.labelPosition = labelPosition;
    super.render = render ?? GFibonacciTimeZoneMarkerRender();
  }
}
