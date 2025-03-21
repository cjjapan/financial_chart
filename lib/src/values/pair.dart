import 'package:equatable/equatable.dart';

/// A wrapper of a pair of values with general type <[T]>.
class GPair<T> extends Equatable {
  final List<T?> _range = List<T?>.filled(2, null);

  bool get isEmpty => _range[0] == null || _range[1] == null;
  bool get isNotEmpty => _range[0] != null && _range[1] != null;

  T? get begin => _range[0];
  T? get end => _range[1];
  T? get first => _range[0];
  T? get last => _range[1];

  GPair.pair(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  GPair.empty() {
    clear();
  }

  void update(T begin, T end) {
    _range[0] = begin;
    _range[1] = end;
  }

  void copy(GPair<T> range) {
    _range[0] = range.begin;
    _range[1] = range.end;
  }

  void clear() {
    _range[0] = null;
    _range[1] = null;
  }

  @override
  List<Object?> get props => [..._range];
}

/// A wrapper of a pair of [double] values.
class GDoublePair extends GPair<double> {
  GDoublePair.pair(double begin, double end) : super.pair(begin, end);
  GDoublePair.empty() : super.empty();
}
