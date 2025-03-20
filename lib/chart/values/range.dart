import 'pair.dart';

/// A double range with [begin] and [end] values.
///
/// [begin] must be less than or equal to [end].
class GRange extends GDoublePair {
  /// Construct a range with [begin] and [end] values.
  GRange.range(double begin, double end) : super.pair(begin, end) {
    assert(begin <= end);
  }

  /// Construct an empty range.
  GRange.empty() : super.empty();

  /// Update the range with [begin] and [end] values.
  @override
  void update(double begin, double end) {
    assert(begin <= end);
    super.update(begin, end);
  }

  /// clone the range.
  GRange clone() => isEmpty ? GRange.empty() : GRange.range(begin!, end!);

  /// linear interpolation between two ranges.
  static GRange lerp(GRange a, GRange b, double t) {
    if (a.isEmpty || b.isEmpty) {
      return b;
    }
    // lerp the begin and end values
    return GRange.range(
      _lerpDouble(a.begin!, b.begin!, t),
      _lerpDouble(a.end!, b.end!, t),
    );
  }

  /// linear interpolation between two double values.
  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
