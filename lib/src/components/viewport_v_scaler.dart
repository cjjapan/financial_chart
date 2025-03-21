import 'dart:math';

import '../chart.dart';
import '../values/range.dart';
import '../values/size.dart';
import 'panel/panel.dart';
import 'viewport_v.dart';

/// Auto scale strategy for value viewport.
abstract class GValueViewPortAutoScaleStrategy {
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GValueViewPort valueViewPort,
  });
}

/// Auto scale strategy to scale viewport to min and max value of data values so all data points be visible in the view area.
class GValueViewPortAutoScaleStrategyMinMax
    implements GValueViewPortAutoScaleStrategy {
  /// The data keys to calculate the min and max value from.
  final List<String> dataKeys;

  /// The margin ratio of the end (top) side.
  late final GSize marginEnd;

  /// The margin ratio of the start (bottom) side.
  late final GSize marginStart;

  /// Specify this if you want the end value to be fixed.
  final double? fixedEndValue;

  /// Specify this if you want the start value to be fixed.
  final double? fixedStartValue;

  GValueViewPortAutoScaleStrategyMinMax({
    required this.dataKeys,
    GSize? marginStart,
    GSize? marginEnd,
    this.fixedEndValue,
    this.fixedStartValue,
  }) {
    this.marginStart = marginStart ?? GSize.viewHeightRatio(0.05);
    this.marginEnd = marginEnd ?? GSize.viewHeightRatio(0.05);
  }

  @override
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GValueViewPort valueViewPort,
  }) {
    if (dataKeys.isEmpty || !chart.pointViewPort.isValid) {
      return GRange.empty();
    }
    if (fixedEndValue != null && fixedStartValue != null) {
      return GRange.range(fixedStartValue!, fixedEndValue!);
    }
    int startPoint = chart.pointViewPort.startPoint.floor();
    int endPoint = chart.pointViewPort.endPoint.ceil();
    var (minValue, maxValue) = chart.dataSource.getSeriesMinMaxByKeys(
      fromPoint: startPoint,
      toPoint: endPoint,
      keys: dataKeys,
    );
    if (minValue == double.infinity || maxValue == double.negativeInfinity) {
      return GRange.empty();
    }
    if (fixedStartValue != null) {
      minValue = fixedStartValue!;
    }
    if (fixedEndValue != null) {
      maxValue = fixedEndValue!;
    }
    double marginStartSize = marginStart.toViewSize(
      area: panel.graphArea(),
      pointViewPort: chart.pointViewPort,
      valueViewPort: valueViewPort,
    );
    double marginEndSize = marginEnd.toViewSize(
      area: panel.graphArea(),
      pointViewPort: chart.pointViewPort,
      valueViewPort: valueViewPort,
    );
    double availableHeight = max(
      panel.graphArea().height - marginStartSize - marginEndSize,
      1,
    );
    double valueDensity = (maxValue - minValue) / availableHeight;
    double marginStartValue = marginStartSize * valueDensity;
    double marginEndValue = marginEndSize * valueDensity;
    return GRange.range(minValue - marginStartValue, maxValue + marginEndValue);
  }
}
