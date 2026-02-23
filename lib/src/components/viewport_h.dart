import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../chart.dart';
import '../values/range.dart';
import '../values/value.dart';
import 'panel/panel.dart';
import 'viewport_h_scaler.dart';
import 'viewport_resize.dart';

/// Viewport for point (horizontal) axis
class GPointViewPort extends ChangeNotifier with Diagnosticable {
  /// The minimum width of a point in pixel when scaling.
  final double minPointWidth;

  /// The maximum width of a point in pixel when scaling.
  final double maxPointWidth;

  /// The default width of a point in pixel.
  ///
  /// This value is mainly used for auto scaling. see [GPointViewPortAutoScaleStrategyLatest].
  final double defaultPointWidth;

  /// Current point range (left and right) of the viewport.
  final GRange _pointRange = GRange.empty();
  bool get isValid => _pointRange.isNotEmpty;

  /// The start(left) point of the viewport.
  double get startPoint => _pointRange.begin!;

  /// The end(right) point of the viewport.
  double get endPoint => _pointRange.end!;

  /// The center point of the viewport.
  double get centerPoint => (startPoint + endPoint) / 2;

  /// min left point of the viewport.
  final GValue<double> _startPointMin = GValue(double.negativeInfinity);
  double get startPointMin => _startPointMin.value;
  set startPointMin(double value) {
    assert(
      value < endPointMax,
      'startPointMin should be less than endPointMax.',
    );
    if (_startPointMin.value == value) {
      return;
    }
    _startPointMin.value = value;
    if (isValid && startPoint < value) {
      final points = _pointRange.end! - _pointRange.begin!;
      setRange(
        startPoint: value,
        endPoint: value + points,
        finished: true,
        notify: true,
      );
    }
  }

  /// max right point of the viewport.
  final GValue<double> _endPointMax = GValue(double.infinity);
  double get endPointMax => _endPointMax.value;
  set endPointMax(double value) {
    assert(
      value > startPointMin,
      'endPointMax should be greater than startPointMin.',
    );
    if (_endPointMax.value == value) {
      return;
    }
    _endPointMax.value = value;
    if (isValid && endPoint > value) {
      final points = _pointRange.end! - _pointRange.begin!;
      setRange(
        startPoint: value - points,
        endPoint: value,
        finished: true,
        notify: true,
      );
    }
  }

  /// current range of the viewport.
  GRange get range => _pointRange.clone();

  /// The size of the range.
  double get pointRangeSize => endPoint - startPoint;

  /// Whether the viewport is auto scaling mode.
  bool get autoScaleFlg => _autoScale.value;
  set autoScaleFlg(bool value) => _autoScale.value = value;
  final GValue<bool> _autoScale = GValue<bool>(true);

  /// The range when selecting. will be cleared when selection finished.
  GRange get selectedRange => _selectedRange;
  final GRange _selectedRange = GRange.empty();

  /// The auto scale strategy to calculate the range when auto scale enabled.
  final GPointViewPortAutoScaleStrategy? autoScaleStrategy;

  /// Defines the behavior of how to update the viewport range when view size changed.
  final GValue<GViewPortResizeMode> _resizeMode = GValue<GViewPortResizeMode>(
    GViewPortResizeMode.keepEnd,
  );
  GViewPortResizeMode get resizeMode => _resizeMode.value;
  set resizeMode(GViewPortResizeMode value) => _resizeMode.value = value;

  /// The animation milliseconds when auto scaling.
  ///
  /// set to 0 to disable animation.
  final GValue<int> _animationMilliseconds = GValue<int>(200);
  int get animationMilliseconds => _animationMilliseconds.value;
  set animationMilliseconds(int value) {
    assert(
      value >= 0,
      'animationMilliseconds should be greater than or equal to 0.',
    );
    if (_animationMilliseconds.value == value) {
      return;
    }
    _animationMilliseconds.value = value;
    if (_rangeAnimationController != null) {
      _rangeAnimationController!.duration = Duration(
        milliseconds: animationMilliseconds,
      );
    }
  }

  AnimationController? _rangeAnimationController;
  Animation<double>? _rangeAnimation;
  final GRange _animationStartRange = GRange.empty();
  final GRange _animationTargetRange = GRange.empty();
  bool get isAnimating => _animationStartRange.isNotEmpty;

  GPointViewPort({
    double? initialStartPoint,
    double? initialEndPoint,
    this.autoScaleStrategy = const GPointViewPortAutoScaleStrategyLatest(),
    GViewPortResizeMode? resizeMode,
    int animationMilliseconds = 200,
    this.minPointWidth = 2,
    this.maxPointWidth = 100,
    this.defaultPointWidth = 10,
    double startPointMin = double.negativeInfinity,
    double endPointMax = double.infinity,
  }) {
    assert(
      (initialStartPoint == null && initialEndPoint == null) ||
          (initialStartPoint != null && initialEndPoint != null),
      'initialStartPoint and initialEndPoint should be both null or not null.',
    );
    assert(
      startPointMin < endPointMax,
      'startPointMin should be less than endPointMax.',
    );
    _startPointMin.value = startPointMin;
    _endPointMax.value = endPointMax;
    assert(minPointWidth > 0, 'minPointWidth should be greater than 0.');
    assert(
      maxPointWidth >= minPointWidth,
      'maxPointWidth should be greater than minPointWidth.',
    );
    assert(
      defaultPointWidth >= minPointWidth,
      'defaultPointWidth should be greater than minPointWidth.',
    );
    assert(
      animationMilliseconds >= 0,
      'animationMilliseconds should be greater than or equal to 0.',
    );
    if (initialStartPoint != null && initialEndPoint != null) {
      setRange(
        startPoint: initialStartPoint,
        endPoint: initialEndPoint,
        finished: true,
        notify: false,
      );
      _autoScale.value = false;
    }
    _animationMilliseconds.value = animationMilliseconds;
    if (resizeMode != null) {
      _resizeMode.value = resizeMode;
    }
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
      _rangeAnimation!.addListener(_rangeAnimationListener);
    }
  }

  void stopAnimation() {
    if (_disposed) {
      return;
    }
    _rangeAnimationController?.stop();
    _animationStartRange.clear();
    _animationTargetRange.clear();
  }

  void _rangeAnimationListener() {
    if (_disposed) {
      return;
    }
    if (_animationStartRange.isEmpty || _animationTargetRange.isEmpty) {
      return;
    }
    final updatedRange = GRange.lerp(
      _animationStartRange,
      _animationTargetRange,
      _rangeAnimation!.value,
    );
    setRange(
      startPoint: updatedRange.first!,
      endPoint: updatedRange.last!,
      finished: false,
    );
  }

  void animateToRange(
    GRange targetRange,
    bool finished,
    bool animation, {
    Simulation? simulation,
  }) {
    if (_disposed) {
      return;
    }
    if (!animation ||
        _rangeAnimationController == null ||
        (targetRange == _pointRange)) {
      setRange(
        startPoint: targetRange.begin!,
        endPoint: targetRange.end!,
        finished: finished,
      );
      return;
    }
    stopAnimation();
    if (_pointRange.isNotEmpty &&
        targetRange.first == startPoint &&
        targetRange.last == endPoint) {
      return;
    }
    final clampedRange = clampRange(targetRange.first!, targetRange.last!);
    _animationStartRange.update(startPoint, endPoint);
    _animationTargetRange.copy(clampedRange);
    Future.delayed(const Duration(milliseconds: 1), () {
      _rangeAnimationController!.reset();
      if (simulation != null) {
        _rangeAnimationController!.animateWith(simulation).then((_) {
          stopAnimation();
          _notify(finished: true);
        }, onError: (_, _) => stopAnimation());
      } else {
        _rangeAnimationController!.forward().then((_) {
          stopAnimation();
          _notify(finished: true);
        }, onError: (_, _) => stopAnimation());
      }
    });
  }

  /// Clamp the range to the min and max values.
  GRange clampRange(
    double startPoint,
    double endPoint, {
    double? startMin,
    double? endMax,
  }) {
    assert(startPoint < endPoint);

    final sMin = startMin ?? startPointMin;
    final eMax = endMax ?? endPointMax;
    final points = endPoint - startPoint;

    double clampedStartPoint = startPoint;
    double clampedEndPoint = endPoint;

    if (points > eMax - sMin) {
      // Viewport is larger than the data range.
      // Keep the data inside the viewport.
      if (startPoint > sMin) {
        clampedStartPoint = sMin;
        clampedEndPoint = clampedStartPoint + points;
      } else if (endPoint < eMax) {
        clampedEndPoint = eMax;
        clampedStartPoint = clampedEndPoint - points;
      }
    } else {
      // Viewport is smaller than or equal to the data range.
      // Keep the viewport inside the data range.
      if (endPoint > eMax) {
        clampedEndPoint = eMax;
        clampedStartPoint = clampedEndPoint - points;
      } else if (startPoint < sMin) {
        clampedStartPoint = sMin;
        clampedEndPoint = clampedStartPoint + points;
      }
    }

    return GRange.range(clampedStartPoint, clampedEndPoint);
  }

  void setRange({
    required double startPoint,
    required double endPoint,
    required bool finished,
    bool notify = true,
  }) {
    if (_disposed) {
      return;
    }
    if (_pointRange.isNotEmpty &&
        startPoint == this.startPoint &&
        endPoint == this.endPoint) {
      return;
    }
    final clampedRange = clampRange(startPoint, endPoint);
    _pointRange.update(clampedRange.first!, clampedRange.last!);
    if (notify) {
      _notify(finished: finished);
    }
  }

  /// Get the width of a point in view size.
  double pointSize(double width, {GRange? range}) {
    return _pointSize(
      width,
      range?.first ?? startPoint,
      range?.last ?? endPoint,
    );
  }

  /// Get the position of a point in view area.
  double pointToPosition(Rect area, double point) {
    return area.left + (point - startPoint) * pointSize(area.width);
  }

  /// Get the point from position in view area.
  double positionToPoint(Rect area, double position) {
    return ((position - area.left) / pointSize(area.width) + startPoint);
  }

  /// Get the size of points in view area.
  double pointToSize(double viewSize, double points) {
    return points * pointSize(viewSize);
  }

  /// Get the points from size in view area.
  double sizeToPoint(double viewSize, double size) {
    return size / pointSize(viewSize);
  }

  /// Get the nearest point from position in view area.
  int nearestPoint(Rect area, Offset position) {
    return ((position.dx - area.left) / pointSize(area.width) + startPoint)
        .round();
  }

  /// update the viewport range when view size changed
  void resize(double fromSize, double toSize, bool notify) {
    if (_disposed) {
      return;
    }
    if (resizeMode == GViewPortResizeMode.keepRange ||
        fromSize == toSize ||
        !isValid) {
      return;
    }
    final pointSizeCurrent = _pointSize(fromSize, startPoint, endPoint);
    if (pointSizeCurrent <= 0) {
      return;
    }
    switch (resizeMode) {
      case GViewPortResizeMode.keepStart:
        final newEndPoint = startPoint + toSize / pointSizeCurrent;
        setRange(
          startPoint: startPoint,
          endPoint: newEndPoint,
          finished: true,
          notify: notify,
        );
        break;
      case GViewPortResizeMode.keepEnd:
        final newStartPoint = endPoint - toSize / pointSizeCurrent;
        setRange(
          startPoint: newStartPoint,
          endPoint: endPoint,
          finished: true,
          notify: notify,
        );
        break;
      case GViewPortResizeMode.keepCenter:
        final centerPoint = (startPoint + endPoint) / 2;
        final newStartPoint = centerPoint - toSize / (2 * pointSizeCurrent);
        final newEndPoint = centerPoint + toSize / (2 * pointSizeCurrent);
        setRange(
          startPoint: newStartPoint,
          endPoint: newEndPoint,
          finished: true,
          notify: notify,
        );
        break;
      case GViewPortResizeMode.keepRange:
        break;
    }
  }

  void _zoom(
    GRange startRange,
    Rect area,
    double zoomRatio,
    double centerPoint, {
    bool animate = false,
    bool finished = true,
  }) {
    if (startRange.isEmpty) {
      return;
    }
    autoScaleFlg = false;
    double pointWidthStart = _pointSize(
      area.width,
      startRange.first!,
      startRange.last!,
    );
    double pointWidthNew = min(
      max(pointWidthStart * zoomRatio, minPointWidth),
      maxPointWidth,
    );
    double centerPosition = pointToPosition(area, centerPoint);
    double leftSize = centerPosition - area.left;
    double rightSize = area.right - centerPosition;
    double startPointNew = centerPoint - leftSize / pointWidthNew;
    double endPointNew = centerPoint + rightSize / pointWidthNew;
    animateToRange(GRange.range(startPointNew, endPointNew), finished, animate);
  }

  void zoom(
    Rect area,
    double zoomRatio, {
    GRange? startRange,
    double? centerPoint,
    bool animate = true,
    bool finished = true,
  }) {
    _zoom(
      startRange ?? range,
      area,
      zoomRatio,
      centerPoint ?? this.centerPoint,
      animate: animate,
      finished: finished,
    );
  }

  void autoScaleReset({
    required GChart chart,
    required GPanel panel,
    required bool finished,
    bool animation = true,
    bool autoScaleFlg = true,
  }) {
    _autoScale.value = autoScaleFlg;
    if (autoScaleStrategy == null) {
      return;
    }
    final newRange = autoScaleStrategy!.getScale(
      chart: chart,
      panel: panel,
      pointViewPort: this,
    );
    if (newRange.isNotEmpty) {
      animateToRange(newRange, finished, animation);
    }
  }

  double _pointSize(double width, double startPoint, double endPoint) {
    return width / (endPoint - startPoint);
  }

  void _notify({required bool finished}) {
    if (super.hasListeners) {
      notifyListeners();
    }
  }

  void notify({required bool finished}) {
    _notify(finished: finished);
  }

  bool _disposed = false;

  @override
  void dispose() {
    _rangeAnimation?.removeListener(_rangeAnimationListener);
    _rangeAnimationController
      ?..stop()
      ..dispose();
    _disposed = true;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GRange>('range', range));
    properties.add(DoubleProperty('rangeSize', isValid ? pointRangeSize : 0));
    if (selectedRange.isNotEmpty) {
      properties.add(
        DiagnosticsProperty<GRange>('selectedRange', selectedRange),
      );
    }
    properties.add(
      DiagnosticsProperty<GViewPortResizeMode>('resizeMode', resizeMode),
    );
    properties.add(DoubleProperty('minPointWidth', minPointWidth));
    properties.add(DoubleProperty('maxPointWidth', maxPointWidth));
    properties.add(DoubleProperty('defaultPointWidth', defaultPointWidth));
    properties.add(DoubleProperty('startPointMin', startPointMin));
    properties.add(DoubleProperty('endPointMax', endPointMax));
    properties.add(DiagnosticsProperty<bool>('autoScaleFlg', autoScaleFlg));
    properties.add(IntProperty('animationMilliseconds', animationMilliseconds));
    properties.add(DiagnosticsProperty<bool>('isAnimating', isAnimating));
  }
}
