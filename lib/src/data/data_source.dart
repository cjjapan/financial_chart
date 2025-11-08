import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';

import '../values/value.dart';

/// Represents a single data point with point value and series values.
class GData<P> extends Equatable {
  /// The point value, typically a timestamp.
  final P pointValue;

  /// List of series values for this data point.
  final List<double> seriesValues;

  /// Creates a data point.
  const GData({required this.pointValue, required this.seriesValues});

  /// Gets a series value by index.
  double operator [](int index) => seriesValues[index];

  /// Sets a series value by index.
  void operator []=(int index, double value) => seriesValues[index] = value;

  @override
  List<Object?> get props => [pointValue, seriesValues];
}

/// Properties and metadata for a data series.
class GDataSeriesProperty {
  /// Unique key for the series.
  final String key;

  /// Display label for the series.
  final String label;

  /// Decimal precision for formatting.
  final int precision;

  /// Custom formatter for series values.
  final String Function(double seriesValue)? valueFormater;

  /// Creates series properties.
  const GDataSeriesProperty({
    required this.key,
    required this.label,
    required this.precision,
    this.valueFormater,
  });
}

/// Default formatter for point values as yyyy-MM-dd dates.
String defaultPointValueFormater(int point, dynamic pointValue) {
  if (pointValue is int) {
    // assume the point value is milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(
      pointValue,
    ).toIso8601String().substring(0, 10);
  }
  return pointValue.toString();
}

/// Default formatter for series values with K/M/B suffixes.
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

/// Container for chart data with dynamic loading capabilities.
/// ignore: must_be_immutable
class GDataSource<P, D extends GData<P>> extends ChangeNotifier
    with Diagnosticable {
  final GValue<int> _basePoint = GValue<int>(0);

  /// Gets the starting point of the data.
  int get basePoint => _basePoint.value;

  final GValue<int> _minPoint = GValue<int>(-100000000);
  final GValue<int> _maxPoint = GValue<int>(100000000);

  /// Extra data points to load beyond visible range.
  final int dataLoadMargin;

  final GValue<bool> _isLoading = GValue<bool>(false);

  /// Gets whether data is currently loading.
  bool get isLoading => _isLoading.value;

  /// The list of data points.
  final List<D> dataList;

  /// Properties for each data series.
  final List<GDataSeriesProperty> seriesProperties;

  final Map<String, int> _seriesKeyIndexMap;

  /// Formatter for point values.
  final String Function(int point, P pointValue) pointValueFormater;

  /// Formatter for series values.
  final String Function(double seriesValue, int precision) seriesValueFormater;

  /// Creates a data source.
  GDataSource({
    required this.dataList,
    required this.seriesProperties,
    this.initialDataLoader,
    this.priorDataLoader,
    this.afterDataLoader,
    this.dataLoadMargin = 50,
    this.dataLoaded,
    this.pointValueFormater = defaultPointValueFormater,
    this.seriesValueFormater = defaultSeriesValueFormater,
  }) : _seriesKeyIndexMap = Map.fromIterables(
         seriesProperties.map((p) => p.key),
         List.generate(seriesProperties.length, (i) => i),
       );

  /// Gets whether the data list is empty.
  bool get isEmpty => dataList.isEmpty;

  /// Gets whether the data list is not empty.
  bool get isNotEmpty => dataList.isNotEmpty;

  /// Gets the first point value.
  int get firstPoint => indexToPoint(0);

  /// Gets the last point value.
  int get lastPoint => indexToPoint(dataList.length - 1);

  /// Gets the number of data points.
  int get length => dataList.length;

  /// Converts a point value to an index in the data list.
  int pointToIndex(int point) {
    return point - basePoint;
  }

  /// Converts an index in the data list to a point value.
  int indexToPoint(int index) {
    return index + basePoint;
  }

  /// Converts a series key to its index in series values.
  int seriesKeyToIndex(String key) {
    return _seriesKeyIndexMap[key]!;
  }

  /// Converts a series index to its key.
  String seriesIndexToKey(int index) {
    return seriesProperties[index].key;
  }

  /// Gets the data at the specified point.
  GData<P>? getData(int point) {
    final index = pointToIndex(point);
    if (index < 0 || index >= dataList.length) {
      return null;
    }
    return dataList[index];
  }

  /// Adds a new series to the data source.
  void addSeries(GDataSeriesProperty property, List<double> values) {
    assert(
      !_seriesKeyIndexMap.containsKey(property.key),
      'Series key already exists: ${property.key}',
    );
    assert(
      values.length == dataList.length,
      'Values length must be equal to dataList length: ${values.length} != ${dataList.length}',
    );
    seriesProperties.add(property);
    _seriesKeyIndexMap[property.key] = seriesProperties.length - 1;
    for (int i = 0; i < dataList.length; i++) {
      dataList[i].seriesValues.add(values[i]);
    }
    _notify();
  }

  /// Removes a series from the data source.
  /// Ensure the series is not in use before removing.
  void removeSeries(String key) {
    assert(_seriesKeyIndexMap.containsKey(key), 'Series key not found: $key');
    final index = _seriesKeyIndexMap[key]!;
    seriesProperties.removeAt(index);
    _seriesKeyIndexMap.remove(key);
    for (final data in dataList) {
      data.seriesValues.removeAt(index);
    }
    for (int i = index; i < seriesProperties.length; i++) {
      _seriesKeyIndexMap[seriesProperties[i].key] = i;
    }
    _notify();
  }

  /// Gets the point value at the specified point.
  P? getPointValue(int point) {
    final index = pointToIndex(point);
    if (index < 0 || index >= dataList.length) {
      return null;
    }
    return dataList[index].pointValue;
  }

  /// Gets point values within the specified range.
  List<P> getPointValues({required int fromPoint, required int toPoint}) {
    return dataList
        .sublist(pointToIndex(fromPoint), pointToIndex(toPoint))
        .map((data) => data.pointValue)
        .toList();
  }

  /// Gets a series value by key at the specified point.
  double? getSeriesValue({required int point, required String key}) {
    final index = pointToIndex(point);
    if (index < 0 ||
        index >= dataList.length ||
        !_seriesKeyIndexMap.containsKey(key)) {
      return null;
    }
    return dataList[index].seriesValues[_seriesKeyIndexMap[key]!];
  }

  /// Gets series values by key within the specified range.
  List<double> getSeriesValues({
    required int fromPoint,
    required int toPoint,
    required String key,
    bool ignoreInvalid = true,
  }) {
    final fromIndex = pointToIndex(fromPoint);
    final toIndex = pointToIndex(toPoint);
    return dataList
        .sublist(fromIndex, toIndex + 1)
        .map((data) => data.seriesValues[_seriesKeyIndexMap[key]!])
        .where((v) => !ignoreInvalid || !(v.isInfinite || v.isNaN))
        .toList();
  }

  /// Gets the series property by key.
  GDataSeriesProperty getSeriesProperty(String key) {
    return seriesProperties[_seriesKeyIndexMap[key]!];
  }

  /// Gets series values as a map at the specified point.
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
    bool ignoreInvalid = true,
  }) {
    int fromIndex = pointToIndex(fromPoint);
    int toIndex = pointToIndex(toPoint);
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
      ignoreInvalid: ignoreInvalid,
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
    bool ignoreInvalid = true,
  }) {
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    for (final key in keys) {
      final rangeOfKey = getSeriesMinMax(
        fromPoint: fromPoint,
        toPoint: toPoint,
        key: key,
        ignoreInvalid: ignoreInvalid,
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
    final fromPointRequest = fromPoint - dataLoadMargin;
    final toPointRequest = toPoint + dataLoadMargin;
    try {
      if (dataList.isEmpty) {
        if (initialDataLoader == null) {
          return;
        }
        _isLoading.value = true;
        _notify();
        final expectedCount = toPointRequest - fromPointRequest + 1;
        await initialDataLoader!(pointCount: expectedCount).then((data) async {
          if (data.isNotEmpty) {
            dataList.addAll(data);
            if (data.length < expectedCount) {
              _minPoint.value = firstPoint;
              _maxPoint.value = lastPoint;
            }
            await dataLoaded?.call(this);
          } else {
            // no data at all
            _minPoint.value = 1;
            _maxPoint.value = -1;
          }
          _notify();
        });
      } else {
        if (priorDataLoader != null &&
            fromPoint < firstPoint &&
            fromPoint >= _minPoint.value) {
          _isLoading.value = true;
          _notify();
          final expectedCount = firstPoint - fromPointRequest;
          await priorDataLoader!(
            pointCount: expectedCount,
            toPointExclusive: firstPoint,
            toPointValueExclusive: getPointValue(firstPoint) as P,
          ).then((data) async {
            if (data.isNotEmpty) {
              dataList.insertAll(0, data);
              _basePoint.value = _basePoint.value - data.length;
              await dataLoaded?.call(this);
            }
            if (data.length < expectedCount) {
              // no more data before this point
              _minPoint.value = firstPoint;
            }
            _notify();
          });
        }
        if (afterDataLoader != null &&
            toPoint > lastPoint &&
            toPoint <= _maxPoint.value) {
          _isLoading.value = true;
          _notify();
          final expectedCount = toPointRequest - lastPoint;
          await afterDataLoader!(
            fromPointExclusive: lastPoint,
            fromPointValueExclusive: getPointValue(lastPoint) as P,
            pointCount: expectedCount,
          ).then((data) async {
            if (data.isNotEmpty) {
              dataList.addAll(data);
              await dataLoaded?.call(this);
            }
            if (data.length < expectedCount) {
              // no more data after this point
              _maxPoint.value = lastPoint;
            }
            _notify();
          });
        }
      }
    } finally {
      _isLoading.value = false;
      _notify();
    }
  }

  void _notify() {
    if (super.hasListeners) {
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

  /// Callback invoked after data is loaded.
  final Future<void> Function(GDataSource<P, D> dataSource)? dataLoaded;

  @override
  @mustCallSuper
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('minPoint', _minPoint.value));
    properties.add(IntProperty('maxPoint', _maxPoint.value));
    properties.add(IntProperty('length', length));
    properties.add(IntProperty('firstPoint', firstPoint));
    properties.add(IntProperty('lastPoint', lastPoint));
  }
}
