import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../values/value.dart';

/// class for a single data point.
///
/// [P] is the type of the point value. usually it is int type with time in seconds since epoch as value.
/// [seriesValues] is a list of double values for each series.
class GData<P> extends Equatable {
  final P pointValue;
  final List<double> seriesValues;

  const GData({required this.pointValue, required this.seriesValues});

  double operator [](int index) => seriesValues[index];
  void operator []=(int index, double value) => seriesValues[index] = value;

  @override
  List<Object?> get props => [pointValue, seriesValues];
}

/// Property of a series.
class GDataSeriesProperty {
  final String key;
  final String label;
  final int precision;

  const GDataSeriesProperty({
    required this.key,
    required this.label,
    required this.precision,
  });
}

/// Default formatter for point value which assumes the value is milliseconds since epoch.
String defaultPointValueFormater(int point, dynamic pointValue) {
  // assume the point value is milliseconds since epoch
  if (pointValue is int) {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.fromMillisecondsSinceEpoch(pointValue));
  }
  return pointValue.toString();
}

/// Default formatter for series value.
String defaultSeriesValueFormater(double seriesValue, int precision) {
  if (seriesValue.abs() >= 100000) {
    if (seriesValue.abs() >= 1000000000) {
      return '${(seriesValue / 1000000000).toStringAsFixed(1)} B';
    }
    if (seriesValue.abs() >= 1000000) {
      return '${(seriesValue / 1000000).toStringAsFixed(1)} M';
    }
    return '${(seriesValue / 1000).toStringAsFixed(1)} K';
  }
  return seriesValue.toStringAsFixed(precision);
}

/// Data container for the chart.
/// ignore: must_be_immutable
class GDataSource<P, D extends GData<P>> extends ChangeNotifier {
  /// Current start point of the data (point value of the first data in [dataList]).
  ///
  /// Use point instead of index to access data so we can append data to both ends dynamically without breaking data access.
  final GValue<int> _basePoint = GValue<int>(0);
  int get basePoint => _basePoint.value;

  final GValue<int> _minPoint = GValue<int>(-100000000);
  final GValue<int> _maxPoint = GValue<int>(100000000);

  final GValue<bool> _isLoading = GValue<bool>(false);
  bool get isLoading => _isLoading.value;

  /// The data list.
  final List<D> dataList;

  /// The series properties.
  final List<GDataSeriesProperty> seriesProperties;

  /// Map of series key to index.
  final Map<String, int> _seriesKeyIndexMap;

  /// Default formatter for point value.
  final String Function(int point, P pointValue) pointValueFormater;

  /// Default formatter for series value.
  final String Function(double seriesValue, int precision) seriesValueFormater;

  GDataSource({
    required this.dataList,
    required this.seriesProperties,
    this.initialDataLoader,
    this.priorDataLoader,
    this.afterDataLoader,
    this.pointValueFormater = defaultPointValueFormater,
    this.seriesValueFormater = defaultSeriesValueFormater,
  }) : _seriesKeyIndexMap = Map.fromIterables(
         seriesProperties.map((p) => p.key),
         List.generate(seriesProperties.length, (i) => i),
       );

  bool get isEmpty => dataList.isEmpty;
  bool get isNotEmpty => dataList.isNotEmpty;
  int get firstPoint => indexToPoint(0);
  int get lastPoint => indexToPoint(dataList.length - 1);
  int get length => dataList.length;

  /// Convert point to index in data list.
  int pointToIndex(int point) {
    return point - basePoint;
  }

  /// Convert index in data list to point.
  int indexToPoint(int index) {
    return index + basePoint;
  }

  /// Get the data at the given point.
  P? getPointValue(int point) {
    final index = pointToIndex(point);
    if (index < 0 || index >= dataList.length) {
      return null;
    }
    return dataList[index].pointValue;
  }

  /// Get the data at the given point range.
  List<P> getPointValues({required int fromPoint, required int toPoint}) {
    return dataList
        .sublist(pointToIndex(fromPoint), pointToIndex(toPoint))
        .map((data) => data.pointValue)
        .toList();
  }

  /// Get the series value by key at the given point.
  double? getSeriesValue({required int point, required String key}) {
    final index = pointToIndex(point);
    if (index < 0 ||
        index >= dataList.length ||
        !_seriesKeyIndexMap.containsKey(key)) {
      return null;
    }
    return dataList[index].seriesValues[_seriesKeyIndexMap[key]!];
  }

  /// Get the series values by key at the given point range.
  List<double> getSeriesValues({
    required int fromPoint,
    required int toPoint,
    required String key,
  }) {
    final fromIndex = pointToIndex(fromPoint);
    final toIndex = pointToIndex(toPoint);
    return dataList
        .sublist(fromIndex, toIndex)
        .map((data) => data.seriesValues[_seriesKeyIndexMap[key]!])
        .toList();
  }

  /// Get the series property by key.
  GDataSeriesProperty getSeriesProperty(String key) {
    return seriesProperties[_seriesKeyIndexMap[key]!];
  }

  /// Get the series value as map by keys at the given point.
  ///
  /// return value is a map with series key as key and series value as value.
  Map<String, double> getSeriesValueAsMap({
    required int point,
    required List<String> keys,
  }) {
    final index = pointToIndex(point);
    if (index < 0 || index >= dataList.length) {
      return <String, double>{};
    }
    final data = dataList[index];
    return keys.asMap().map(
      (i, key) =>
          MapEntry(key, data.seriesValues[_seriesKeyIndexMap[keys[i]]!]),
    );
  }

  /// Get the min and max of series values by key at the given point range.
  (double minvalue, double maxValue) getSeriesMinMax({
    required int fromPoint,
    required int toPoint,
    required String key,
  }) {
    var fromIndex = pointToIndex(fromPoint);
    var toIndex = pointToIndex(toPoint);
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    if (fromIndex < 0) {
      fromIndex = 0;
    }
    if (toIndex > dataList.length - 1) {
      toIndex = dataList.length - 1;
    }
    if (fromIndex > toIndex) {
      return (minValue, maxValue);
    }
    final values = getSeriesValues(
      fromPoint: indexToPoint(fromIndex),
      toPoint: indexToPoint(toIndex),
      key: key,
    );
    minValue = values.fold(minValue, min);
    maxValue = values.fold(maxValue, max);
    return (minValue, maxValue);
  }

  /// Get the min and max of series values by keys at the given point range.
  (double minvalue, double maxValue) getSeriesMinMaxByKeys({
    required int fromPoint,
    required int toPoint,
    required List<String> keys,
  }) {
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    for (final key in keys) {
      final rangeOfKey = getSeriesMinMax(
        fromPoint: fromPoint,
        toPoint: toPoint,
        key: key,
      );
      minValue = min(minValue, rangeOfKey.$1);
      maxValue = max(maxValue, rangeOfKey.$2);
    }
    return (minValue, maxValue);
  }

  /// Ensure the data is loaded for the given point range.
  Future<void> ensureData({
    required int fromPoint,
    required int toPoint,
  }) async {
    if (isLoading ||
        toPoint <= fromPoint ||
        toPoint < _minPoint.value ||
        fromPoint > _maxPoint.value ||
        _minPoint.value > _maxPoint.value) {
      return;
    }
    try {
      if (dataList.isEmpty) {
        if (initialDataLoader == null) {
          return;
        }
        _isLoading.value = true;
        notifyListeners();
        final expectedCount = toPoint - fromPoint + 1;
        await initialDataLoader!(pointCount: expectedCount).then((data) {
          if (data.isNotEmpty) {
            dataList.addAll(data);
            if (data.length < expectedCount) {
              _minPoint.value = firstPoint;
              _maxPoint.value = lastPoint;
            }
          } else {
            // no data at all
            _minPoint.value = 1;
            _maxPoint.value = -1;
          }
          notifyListeners();
        });
      } else {
        if (priorDataLoader != null &&
            fromPoint < firstPoint &&
            fromPoint >= _minPoint.value) {
          _isLoading.value = true;
          notifyListeners();
          final expectedCount = firstPoint - fromPoint;
          await priorDataLoader!(
                pointCount: expectedCount,
                toPointExclusive: firstPoint,
                toPointValueExclusive: getPointValue(firstPoint) as P,
              )
              .then((data) {
                if (data.isNotEmpty) {
                  dataList.insertAll(0, data);
                  _basePoint.value = _basePoint.value - data.length;
                }
                if (data.length < expectedCount) {
                  // no more data before this point
                  _minPoint.value = firstPoint;
                }
                notifyListeners();
              });
        }
        if (afterDataLoader != null &&
            toPoint > lastPoint &&
            toPoint <= _maxPoint.value) {
          _isLoading.value = true;
          notifyListeners();
          final expectedCount = toPoint - lastPoint;
          await afterDataLoader!(
                fromPointExclusive: lastPoint,
                fromPointValueExclusive: getPointValue(lastPoint) as P,
                pointCount: expectedCount,
              )
              .then((data) {
                if (data.isNotEmpty) {
                  dataList.addAll(data);
                }
                if (data.length < expectedCount) {
                  // no more data after this point
                  _maxPoint.value = lastPoint;
                }
                notifyListeners();
              });
        }
      }
    } finally {
      _isLoading.value = false;
      notifyListeners();
    }
  }

  /// The function to load initial data.
  final Future<List<D>> Function({required int pointCount})? initialDataLoader;

  /// The function to load prior data before the given point value.
  final Future<List<D>> Function({
    required int toPointExclusive,
    required P toPointValueExclusive,
    required int pointCount,
  })?
  priorDataLoader;

  /// The function to load after data after the given point value.
  final Future<List<D>> Function({
    required int fromPointExclusive,
    required P fromPointValueExclusive,
    required int pointCount,
  })?
  afterDataLoader;
}
