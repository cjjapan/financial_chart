import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../chart.dart';
import '../values/range.dart';
import '../values/value.dart';
import 'panel/panel.dart';
import 'viewport_v_scaler.dart';

/// Viewport for value (vertical) axis
class GValueViewPort extends ChangeNotifier {
  /// Identifier of the viewport which being referenced by components.
  final String id;

  /// The decimal precision of the value.
  final int valuePrecision;

  /// Current value range (top and bottom) of the viewport.
  final GRange _range = GRange.empty();
  bool get isValid => _range.isNotEmpty;

  /// The end (top) value of the viewport.
  double get endValue => _range.last!;

  /// The start (bottom) value of the viewport.
  double get startValue => _range.first!;

  /// The center value of the viewport.
  double get centerValue => (endValue + startValue) / 2;

  /// The value range of the viewport ([endValue]-[startValue]).
  double get valueRange => endValue - startValue;

  /// The range when scaling started. will be cleared when scaling finished.
  final GRange _rangeScaling = GRange.empty();

  /// The range when selecting. will be cleared when selection finished.
  GRange get selectedRange => _selectedRange;
  final GRange _selectedRange = GRange.empty();

  /// Whether the viewport is auto scaling mode.
  bool get autoScaleFlg => _autoScale();
  set autoScaleFlg(bool value) => _autoScale(newValue: value);
  final GValue<bool> _autoScale = GValue<bool>(true);

  /// The auto scale strategy to calculate the range when auto scale enabled.
  final GValueViewPortAutoScaleStrategy? autoScaleStrategy;

  /// The minimum value range when scaling.
  final double? minValueRange;

  /// The maximum value range when scaling.
  final double? maxValueRange;

  /// Callback when range updated.
  final GRange Function({required GRange updatedRange, required bool finished})?
  onRangeUpdate;

  /// The animation milliseconds when auto scaling.
  ///
  /// set to 0 to disable animation.
  final GValue<int> _animationMilliseconds = GValue<int>(2000);
  int get animationMilliseconds => _animationMilliseconds.value;
  set animationMilliseconds(int value) => _animationMilliseconds.value = value;

  AnimationController? _rangeAnimationController;
  Animation<double>? _rangeAnimation;
  final GValue<bool> _isAnimating = GValue<bool>(false);
  bool get isAnimating => _isAnimating.value;

  /// Create a value viewport.
  ///
  /// Set proper [initialEndValue] and [initialStartValue] when [autoScaleStrategy] not provided.
  GValueViewPort({
    required this.id,
    double? initialEndValue,
    double? initialStartValue,
    required this.valuePrecision,
    this.autoScaleStrategy,
    int animationMilliseconds = 200,
    this.onRangeUpdate,
    this.maxValueRange,
    this.minValueRange,
    double? baseValue,
  }) {
    assert(
      (initialStartValue == null && initialEndValue == null) ||
          (initialStartValue != null && initialEndValue != null),
    );
    if (initialStartValue != null && initialEndValue != null) {
      assert(initialEndValue > initialStartValue);
      _autoScale.value = false;
    }
    if (maxValueRange != null) {
      assert(maxValueRange! > 0);
    }
    if (maxValueRange != null) {
      assert(maxValueRange! > 0);
      if (minValueRange != null) {
        assert(minValueRange! < maxValueRange!);
      }
    }
    _range.update(initialStartValue ?? 0, initialEndValue ?? 1);
    _animationMilliseconds.value = animationMilliseconds;
  }

  void initializeAnimation(TickerProvider vsync) {
    if (_rangeAnimationController == null && animationMilliseconds > 0) {
      _rangeAnimationController = AnimationController(
        vsync: vsync,
        duration: Duration(milliseconds: animationMilliseconds),
      );
      _rangeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _rangeAnimationController!,
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  void _notifyRangeUpdated({required bool finished}) {
    if (onRangeUpdate != null) {
      _range.copy(
        onRangeUpdate!.call(updatedRange: _range, finished: finished),
      );
    }
  }

  void animateToRange(
    GChart chart,
    GRange targetRange,
    bool finished,
    bool animation, {
    VoidCallback? onFinished,
  }) {
    if (!animation ||
        _rangeAnimationController == null ||
        (targetRange == _range)) {
      setRange(
        startValue: targetRange.begin!,
        endValue: targetRange.end!,
        finished: finished,
      );
      onFinished?.call();
      return;
    }
    _rangeAnimationController!.stop();
    _isAnimating.value = true;
    var currentRange = GRange.range(startValue, endValue);
    void listener() {
      final updatedRange = GRange.lerp(
        currentRange,
        targetRange,
        _rangeAnimationController!.value,
      );
      setRange(
        startValue: updatedRange.first!,
        endValue: updatedRange.last!,
        finished: finished,
      );
      chart.repaint(layout: false);
    }

    Future.delayed(const Duration(milliseconds: 10), () {
      _rangeAnimationController!.reset();
      _rangeAnimation!.addListener(listener);
      _rangeAnimationController!.forward().then((_) {
        _rangeAnimation!.removeListener(listener);
        _isAnimating.value = false;
        onFinished?.call();
      });
    });
  }

  void setRange({
    required double startValue,
    required double endValue,
    bool finished = true,
  }) {
    assert(endValue > startValue);
    if (onRangeUpdate == null) {
      if (endValue == this.endValue && startValue == this.startValue) {
        return;
      }
    }
    final (startValueClamped, endValueClamped) = clampScaleRange(
      startValue,
      endValue,
    );
    _range.update(startValueClamped, endValueClamped);
    _notifyRangeUpdated(finished: finished);
  }

  /// convert value to position
  double valueToPosition(Rect area, double value) {
    return area.bottom -
        (value - startValue) / (endValue - startValue) * area.height;
  }

  /// convert position to value
  double positionToValue(Rect area, double position) {
    return startValue +
        (area.bottom - position) / area.height * (endValue - startValue);
  }

  /// convert value to size
  double valueToSize(double viewSize, double value) {
    return value * viewSize / (endValue - startValue);
  }

  /// convert size to value
  double sizeToValue(double viewSize, double size) {
    return size * (endValue - startValue) / viewSize;
  }

  void interactionStart() {
    _rangeScaling.copy(_range);
  }

  void interactionEnd() {
    _rangeScaling.clear();
    _selectedRange.clear();
    _notifyRangeUpdated(finished: true);
  }

  (double startValueClamped, double endValueClamped) clampScaleRange(
    double startValue,
    double endValue,
  ) {
    double endValueClamped = endValue;
    double startValueClamped = startValue;
    if (minValueRange != null) {
      if (endValueClamped - startValueClamped < minValueRange!) {
        // expand from center
        double centerValue = (endValue + startValue) / 2;
        endValueClamped = centerValue + minValueRange! / 2;
        startValueClamped = centerValue - minValueRange! / 2;
      }
    }
    if (maxValueRange != null) {
      if (endValueClamped - startValueClamped > maxValueRange!) {
        // shrink from center
        double centerValue = (endValue + startValue) / 2;
        endValueClamped = centerValue + maxValueRange! / 2;
        startValueClamped = centerValue - maxValueRange! / 2;
      }
    }
    return (startValueClamped, endValueClamped);
  }

  void interactionZoomUpdate(Rect area, double zoomRatio) {
    if (_rangeScaling.isEmpty) {
      return;
    }
    double centerValue = (_rangeScaling.first! + _rangeScaling.last!) / 2;
    double endValueNew =
        centerValue + (_rangeScaling.last! - centerValue) / zoomRatio;
    double startValueNew =
        centerValue + (_rangeScaling.first! - centerValue) / zoomRatio;
    (startValueNew, endValueNew) = clampScaleRange(startValueNew, endValueNew);
    setRange(startValue: startValueNew, endValue: endValueNew);
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (_rangeScaling.isEmpty) {
      return;
    }
    double valueMoved =
        (movedDistance / area.height) *
        (_rangeScaling.last! - _rangeScaling.first!);
    double endValueNew = _rangeScaling.last! + valueMoved;
    double startValueNew = _rangeScaling.first! + valueMoved;
    setRange(startValue: startValueNew, endValue: endValueNew);
  }

  void interactionSelectUpdate(
    GChart chart,
    Rect area,
    double startPosition,
    double position, {
    bool finished = false,
  }) {
    if (_rangeScaling.isEmpty) {
      return;
    }
    final value1 = positionToValue(
      area,
      max(area.top, min(area.bottom, startPosition)),
    );
    final value2 = positionToValue(
      area,
      max(area.top, min(area.bottom, position)),
    );
    _selectedRange.update(min(value1, value2), max(value1, value2));
    if (finished) {
      double endValueNew = min(_selectedRange.last!, _rangeScaling.last!);
      double startValueNew = max(_selectedRange.first!, _rangeScaling.first!);
      (startValueNew, endValueNew) = clampScaleRange(
        startValueNew,
        endValueNew,
      );
      animateToRange(
        chart,
        GRange.range(startValueNew, endValueNew),
        finished,
        true,
      );
    }
  }

  void autoScaleReset({
    required GChart chart,
    required GPanel panel,
    autoScaleFlg = true,
    bool finished = true,
    bool animation = true,
    VoidCallback? onFinished,
  }) {
    _autoScale.value = autoScaleFlg;
    if (autoScaleStrategy == null) {
      return;
    }
    final newRange = autoScaleStrategy!.getScale(
      chart: chart,
      panel: panel,
      valueViewPort: this,
    );
    if (newRange.isEmpty || newRange.begin! >= newRange.end!) {
      return;
    }
    final (startValueClamped, endValueClamped) = clampScaleRange(
      newRange.begin!,
      newRange.end!,
    );
    animateToRange(
      chart,
      GRange.range(startValueClamped, endValueClamped),
      finished,
      animation,
      onFinished: onFinished,
    );
  }

  @override
  void dispose() {
    _rangeAnimationController?.dispose();
    super.dispose();
  }
}
