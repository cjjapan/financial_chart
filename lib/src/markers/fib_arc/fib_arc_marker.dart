import 'package:financial_chart/financial_chart.dart';

class GFibArcMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];

  final List<double> fibLevels = [];

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  final GValue<double> _startTheta;
  double get startTheta => _startTheta.value;
  set startTheta(double value) => _startTheta.value = value;

  final GValue<double> _endTheta;
  double get endTheta => _endTheta.value;
  set endTheta(double value) => _endTheta.value = value;

  GFibArcMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    required double startTheta,
    required double endTheta,
    List<double> fibLevels = const [0.0, 0.236, 0.382, 0.5, 0.618, 1.0],
    GRender? render,
  }) : _startTheta = GValue<double>(startTheta),
       _endTheta = GValue<double>(endTheta),
       super(keyCoordinates: [startCoord, endCoord]) {
    this.fibLevels.addAll(fibLevels);
    super.render = render ?? GFibArcMarkerRender();
  }
}
