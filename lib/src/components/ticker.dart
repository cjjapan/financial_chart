import 'dart:math';
import 'viewport_h.dart';
import 'viewport_v.dart';

/// Strategy to calculate value ticks for axis and grids.
abstract class GValueTickerStrategy {
  List<double> valueTicks({
    required double viewSize,
    required GValueViewPort viewPort,
  });
}

/// Strategy to calculate point ticks for axis and grids.
abstract class GPointTickerStrategy {
  List<int> pointTicks({
    required double viewSize,
    required GPointViewPort viewPort,
  });
}

/// Default strategy to calculate point ticks.
class GPointTickerStrategyDefault implements GPointTickerStrategy {
  /// The minimum interval between two ticks in pixel.
  final double tickerMinSize;

  const GPointTickerStrategyDefault({this.tickerMinSize = 100});

  @override
  List<int> pointTicks({
    required double viewSize,
    required GPointViewPort viewPort,
  }) {
    if (viewSize <= 0) {
      return [];
    }
    List<int> points = <int>[];
    int pointTickInterval = max(
      (tickerMinSize / viewPort.pointSize(viewSize)).ceil(),
      1,
    ); // how many points per tick
    int left = viewPort.startPoint.toInt();
    int right = viewPort.endPoint.toInt();
    for (int point = left; point < right; point++) {
      if ((point % pointTickInterval) != 0) {
        continue;
      }
      points.add(point);
    }
    return points;
  }
}

/// Default strategy to calculate value ticks.
class GValueTickerStrategyDefault implements GValueTickerStrategy {
  /// The minimum size of a tick in pixel.
  ///
  /// the final tick size will in range valueTickMinSize ~ valueTickMinSize*2
  final double tickerMinSize;

  const GValueTickerStrategyDefault({this.tickerMinSize = 60});

  double _defaultTickerValueInterval(double valueRange) {
    return pow(
      10,
      (valueRange * 10000).toStringAsFixed(0).length - 5,
    ).toDouble();
  }

  double _defaultBaseValue(double centerValue, double tickInterval) {
    return (centerValue / tickInterval).round() * tickInterval;
  }

  @override
  List<double> valueTicks({
    required double viewSize,
    required GValueViewPort viewPort,
  }) {
    if (viewSize <= 0) {
      return [];
    }

    double tickInterval = _defaultTickerValueInterval(viewPort.valueRange);
    double tickSize = viewPort.valueToSize(viewSize, tickInterval);
    while (tickSize < tickerMinSize) {
      tickInterval *= 2;
      tickSize *= 2;
    }
    while (tickSize > tickerMinSize * 2) {
      tickInterval /= 2;
      tickSize /= 2;
    }
    List<double> valueTicks = [];
    double valueHigh = viewPort.endValue;
    double valueLow = viewPort.startValue;
    double baseValue = _defaultBaseValue(viewPort.centerValue, tickInterval);

    double tickValue = baseValue;
    while (tickValue <= valueHigh) {
      if (tickValue >= valueLow) {
        valueTicks.add(tickValue);
      }
      tickValue += tickInterval;
    }
    tickValue = baseValue - tickInterval;
    while (tickValue >= valueLow) {
      if (tickValue <= valueHigh) {
        valueTicks.add(tickValue);
      }
      tickValue -= tickInterval;
    }
    return valueTicks;
  }
}
