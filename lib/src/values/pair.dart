import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Wrapper for a pair of values.
class GPair<T> extends Equatable {
  final List<T?> _range = List<T?>.filled(2, null);

  /// Gets whether the pair is empty.
  bool get isEmpty => _range[0] == null || _range[1] == null;

  /// Gets whether the pair is not empty.
  bool get isNotEmpty => _range[0] != null && _range[1] != null;

  /// Gets the beginning value.
  T? get begin => _range[0];

  /// Gets the ending value.
  T? get end => _range[1];

  /// Gets the first value (same as begin).
  T? get first => _range[0];

  /// Gets the last value (same as end).
  T? get last => _range[1];

  /// Creates a pair with specified values.
  GPair.pair(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  /// Creates an empty pair.
  GPair.empty() {
    clear();
  }

  /// Updates the pair with new values.
  void update(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  /// Copies values from another pair.
  void copy(GPair<T> range) {
    _range[0] = range.begin;
    _range[1] = range.end;
  }

  /// Clears the pair values.
  void clear() {
    _range[0] = null;
    _range[1] = null;
  }

  @override
  List<Object?> get props => [..._range];
}

/// Wrapper for a pair of double values.
class GDoublePair extends GPair<double> with Diagnosticable {
  /// Creates a double pair with specified values.
  GDoublePair.pair(super.begin, super.end) : super.pair();

  /// Creates an empty double pair.
  GDoublePair.empty() : super.empty();

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('begin', isEmpty ? null : begin));
    properties.add(DoubleProperty('end', isEmpty ? null : end));
  }
}
