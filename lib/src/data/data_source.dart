import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';

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
  final String Function(double seriesValue)? valueFormater;

  const GDataSeriesProperty({
    required this.key,
    required this.label,
    required this.precision,
    this.valueFormater,
  });
}

/// Default formatter for point value which format it as yyyy-MM-dd assumes the value is milliseconds since epoch.
String defaultPointValueFormater(int point, dynamic pointValue) {
  if (pointValue is int) {
    // assume the point value is milliseconds since epoch
    return DateTime.fromMillisecondsSinceEpoch(
      pointValue,
    ).toIso8601String().substring(0, 10);
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
class GDataSource<P, D extends GData<P>> extends ChangeNotifier
    with Diagnosticable {
  /// Current start point of the data (point value of the first data in [dataList]).
  ///
  /// Use point instead of index to access data so we can append data to both ends dynamically without breaking data access.
  final GValue<int> _basePoint = GValue<int>(0);
  int get basePoint => _basePoint.value;

  final GValue<int> _minPoint = GValue<int>(-100000000);
  final GValue<int> _maxPoint = GValue<int>(100000000);

  /// load more data than necessary to avoid loading too frequently.
  final int dataLoadMargin;

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
    this.dataLoadMargin = 50,
    this.dataLoaded,
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

  /// Convert series key to value index in [GData].seriesValues
  int seriesKeyToIndex(String key) {
    return _seriesKeyIndexMap[key]!;
  }

  /// Convert series value index to series key.
  String seriesIndexToKey(int index) {
    return seriesProperties[index].key;
  }

  /// Get the data at the given point.
  GData<P>? getData(int point) {
    final index = pointToIndex(point);
    if (index < 0 || index >= dataList.length) {
      return null;
    }
    return dataList[index];
  }

  /// add a new series to the data source.
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

  /// remove a series from the data source.
  ///
  /// make sure it is not being used by any component of the chart before removing.
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
