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

/// The interval type for logarithmic scale value ticks.
enum GValueTickerLogScaleIntervalType {
  /// ticks are spaced evenly in view size.
  sizeSpacingEvenly,

  /// ticks are spaced evenly in value.
  valueSpacingEvenly,
}

/// Default strategy to calculate value ticks.
class GValueTickerStrategyDefault implements GValueTickerStrategy {
  /// The minimum size of a tick in pixel.
  ///
  /// the final tick size will in range valueTickMinSize ~ valueTickMinSize*2
  final double tickerMinSize;

  final GValueTickerLogScaleIntervalType logScaleIntervalType;

  const GValueTickerStrategyDefault({
    this.tickerMinSize = 60,
    this.logScaleIntervalType =
        GValueTickerLogScaleIntervalType.sizeSpacingEvenly,
  });

  double _defaultTickerValueInterval(double valueRange) {
    if (valueRange <= 0) {
      return 0;
    }
    if (valueRange >= 1) {
      return pow(10, valueRange.toStringAsFixed(0).length - 1).toDouble();
    }
    return pow(
      10,
      (valueRange * 10000000).toStringAsFixed(0).length - 9,
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

    double tickInterval = _defaultTickerValueInterval(viewPort.rangeSize);
    if (tickInterval <= 0) {
      return [];
    }
    double tickSize = viewPort.valueToSize(viewSize, tickInterval);
    while (tickSize < tickerMinSize) {
      tickInterval *= 2;
      tickSize *= 2;
    }
    while (tickSize > tickerMinSize * 2) {
      tickInterval /= 2;
      tickSize /= 2;
    }
    double valueHigh = viewPort.endValue;
    double valueLow = viewPort.startValue;
    double baseValue = _defaultBaseValue(viewPort.centerValue, tickInterval);

    if (viewPort.scaleType == GValueViewPortScaleType.logarithmic) {
      return generateLogTicks(
        size: viewSize,
        sizeInterval: tickSize,
        lowValue: valueLow,
        highValue: valueHigh,
        valueIntervalMin: tickInterval,
        viewPort: viewPort,
      );
    } else {
      List<double> valueTicks = [];
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

  List<double> generateLogTicks({
    required double size,
    required double sizeInterval,
    required double lowValue,
    required double highValue,
    required double valueIntervalMin,
    required GValueViewPort viewPort,
  }) {
    List<double> ticks = [];
    final valueInterval = valueIntervalMin;
    final centerValueRaw = (lowValue + highValue) / 2;
    final centerValue =
        (centerValueRaw / valueInterval).round() * valueInterval;

    if (logScaleIntervalType ==
        GValueTickerLogScaleIntervalType.valueSpacingEvenly) {
      for (
        double value = centerValue;
        value >= lowValue - valueInterval;
        value -= valueInterval
      ) {
        if (value >= lowValue - valueInterval && value <= highValue) {
          ticks.add(value);
        }
      }

      for (
        double value = centerValue + valueInterval;
        value <= highValue;
        value += valueInterval
      ) {
        if (value >= lowValue && value <= highValue) {
          ticks.add(value);
        }
      }
    } else {
      final minExp = (log(lowValue / centerValue) / viewPort.logBase);
      final maxExp = (log(highValue / centerValue) / viewPort.logBase);
      if (minExp.isInfinite || maxExp.isInfinite) {
        return [];
      }
      final centerExp = 0.0;
      final expInterval = (sizeInterval / size) * (maxExp - minExp);
      double exp = centerExp;
      while (exp >= minExp) {
        final tick = centerValue * pow(10, exp);
        ticks.add(tick);
        exp -= expInterval;
      }
      exp = centerExp + expInterval;
      while (exp <= maxExp) {
        final tick = centerValue * pow(10, exp);
        ticks.add(tick);
        exp += expInterval;
      }
    }
    return ticks;
  }
}
