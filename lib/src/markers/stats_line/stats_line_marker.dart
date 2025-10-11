import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';

class GLineStats {
  final Offset startPosition;
  final Offset endPosition;
  final String startValue;
  final String endValue;
  final int startPoint;
  final int endPoint;
  final int startPointValue;
  final int endPointValue;
  final double angleRadian;
  final double angleDegree;

  GLineStats({
    required this.startPosition,
    required this.endPosition,
    required this.startValue,
    required this.endValue,
    required this.startPoint,
    required this.endPoint,
    required this.startPointValue,
    required this.endPointValue,
    required this.angleRadian,
    required this.angleDegree,
  });
}

enum GStatsLineFillStyle { none, triangle, rectangle }

class GStatsLineMarker extends GArrowLineMarker {
  /// Whether to extend the line infinitely from the start point.
  final GValue<bool> _startRay = GValue<bool>(false);
  bool get startRay => _startRay.value;
  set startRay(bool value) => _startRay.value = value;

  /// Whether to extend the line infinitely from the end point.
  final GValue<bool> _endRay = GValue<bool>(false);
  bool get endRay => _endRay.value;
  set endRay(bool value) => _endRay.value = value;

  /// Whether to show angle statistics.
  final GValue<bool> _showAngleStats = GValue<bool>(true);
  bool get showAngleStats => _showAngleStats.value;
  set showAngleStats(bool value) => _showAngleStats.value = value;

  /// The radius of the angle mark arc.
  final GValue<double> _angleMarkRadius = GValue<double>(50.0);
  double get angleMarkRadius => _angleMarkRadius.value;
  set angleMarkRadius(double value) => _angleMarkRadius.value = value;

  /// Whether to show point statistics.
  final GValue<bool> _showPointStats = GValue<bool>(true);
  bool get showPointStats => _showPointStats.value;
  set showPointStats(bool value) => _showPointStats.value = value;

  /// Whether to show value statistics.
  final GValue<bool> _showValueStats = GValue<bool>(true);
  bool get showValueStats => _showValueStats.value;
  set showValueStats(bool value) => _showValueStats.value = value;

  /// Whether to show distance statistics.
  final GValue<bool> _showDistance = GValue<bool>(true);
  bool get showDistance => _showDistance.value;
  set showDistance(bool value) => _showDistance.value = value;

  /// The position of the stats box along the line, ranging from 0.0 to 1.0.
  final GValue<double?> _statsBoxPosition = GValue<double?>(null);
  double? get statsBoxPosition => _statsBoxPosition.value;
  set statsBoxPosition(double? value) => _statsBoxPosition.value = value;

  /// The fill style of the area
  final GValue<GStatsLineFillStyle> _fillStyle = GValue<GStatsLineFillStyle>(
    GStatsLineFillStyle.none,
  );
  GStatsLineFillStyle get fillStyle => _fillStyle.value;
  set fillStyle(GStatsLineFillStyle value) => _fillStyle.value = value;

  GStatsLineMarker({
    super.id,
    super.label,
    super.visible,
    super.layer,
    super.selected,
    super.hitTestMode,
    super.theme,
    required super.startCoord,
    required super.endCoord,
    super.startHead = const GArrowHead(type: GArrowHeadType.none),
    super.endHead = const GArrowHead(type: GArrowHeadType.triangle),
    bool startRay = false,
    bool endRay = false,
    double? statsBoxPosition,
    bool showAngleStats = true,
    double angleMarkRadius = 50.0,
    bool showPointStats = true,
    bool showValueStats = true,
    bool showDistance = true,
    GStatsLineFillStyle fillStyle = GStatsLineFillStyle.none,
    GRender? render,
  }) : super() {
    assert(
      statsBoxPosition == null ||
          (statsBoxPosition >= 0.0 && statsBoxPosition <= 1.0),
      "statsPosition must be between 0.0 and 1.0",
    );
    assert(angleMarkRadius > 0, "angleMarkRadius must be greater than 0");
    _startRay.value = startRay;
    _endRay.value = endRay;
    _statsBoxPosition.value = statsBoxPosition;
    _showAngleStats.value = showAngleStats;
    _angleMarkRadius.value = angleMarkRadius;
    _showPointStats.value = showPointStats;
    _showValueStats.value = showValueStats;
    _showDistance.value = showDistance;
    _fillStyle.value = fillStyle;
    super.render = render ?? GStatsLineMarkerRender();
  }
}
