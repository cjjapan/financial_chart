import 'package:financial_chart/financial_chart.dart';

class GFibResistanceFanMarker extends GOverlayMarker {
  List<GCoordinate> get coordinates => [...keyCoordinates];

  GCoordinate get startCoord => keyCoordinates[0];
  GCoordinate get endCoord => keyCoordinates[1];

  final List<double> valueFibLevels = [];
  final List<double> pointFibLevels = [];

  final GValue<bool> _extendRay = GValue<bool>(true);
  bool get extendRay => _extendRay.value;
  set extendRay(bool value) => _extendRay.value = value;

  final GValue<bool> _showValueLevelLines = GValue<bool>(true);
  bool get showValueLevelLines => _showValueLevelLines.value;
  set showValueLevelLines(bool value) => _showValueLevelLines.value = value;

  final GValue<bool> _showPointLevelLines = GValue<bool>(true);
  bool get showPointLevelLines => _showPointLevelLines.value;
  set showPointLevelLines(bool value) => _showPointLevelLines.value = value;

  final GValue<bool> _showValueLevelStartLabels = GValue<bool>(true);
  bool get showValueLevelStartLabels => _showValueLevelStartLabels.value;
  set showValueLevelStartLabels(bool value) =>
      _showValueLevelStartLabels.value = value;

  final GValue<bool> _showValueLevelEndLabels = GValue<bool>(true);
  bool get showValueLevelEndLabels => _showValueLevelEndLabels.value;
  set showValueLevelEndLabels(bool value) =>
      _showValueLevelEndLabels.value = value;

  final GValue<bool> _showPointLevelStartLabels = GValue<bool>(true);
  bool get showPointLevelStartLabels => _showPointLevelStartLabels.value;
  set showPointLevelStartLabels(bool value) =>
      _showPointLevelStartLabels.value = value;

  final GValue<bool> _showPointLevelEndLabels = GValue<bool>(true);
  bool get showPointLevelEndLabels => _showPointLevelEndLabels.value;
  set showPointLevelEndLabels(bool value) =>
      _showPointLevelEndLabels.value = value;

  GFibResistanceFanMarker({
    super.id,
    super.visible,
    super.layer,
    super.hitTestMode,
    super.theme,
    required GCoordinate startCoord,
    required GCoordinate endCoord,
    List<double> valueFibLevels = const [0.0, 0.236, 0.382, 0.5, 0.618, 1.0],
    List<double> pointFibLevels = const [0.0, 0.236, 0.382, 0.5, 0.618, 1.0],
    bool extendRay = true,
    bool showValueLevelLines = true,
    bool showPointLevelLines = true,
    bool showValueLevelStartLabels = true,
    bool showValueLevelEndLabels = true,
    bool showPointLevelStartLabels = true,
    bool showPointLevelEndLabels = true,
    GRender? render,
  }) : super(keyCoordinates: [startCoord, endCoord]) {
    this.valueFibLevels.addAll(valueFibLevels);
    this.pointFibLevels.addAll(pointFibLevels);
    _extendRay.value = extendRay;
    _showValueLevelLines.value = showValueLevelLines;
    _showPointLevelLines.value = showPointLevelLines;
    _showValueLevelStartLabels.value = showValueLevelStartLabels;
    _showValueLevelEndLabels.value = showValueLevelEndLabels;
    _showPointLevelStartLabels.value = showPointLevelStartLabels;
    _showPointLevelEndLabels.value = showPointLevelEndLabels;
    super.render = render ?? GFibonacciResistanceFanMarkerRender();
  }
}
