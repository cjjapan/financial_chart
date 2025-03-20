import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../chart.dart';
import '../values/range.dart';
import '../values/value.dart';
import 'panel/panel.dart';
import 'viewport_h_scaler.dart';

/// Viewport for point (horizontal) axis
class GPointViewPort extends ChangeNotifier {
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

  /// current range of the viewport.
  GRange get range => _pointRange.clone();

  /// The size of the range.
  double get pointRangeSize => endPoint - startPoint;

  /// The range when scaling started. will be cleared when scaling finished.
  final GRange _pointRangeScaling = GRange.empty();
  bool get isScaling => _pointRangeScaling.isNotEmpty;

  /// The range when selecting. will be cleared when selection finished.
  GRange get selectedRange => _selectedRange;
  final GRange _selectedRange = GRange.empty();

  /// The auto scale strategy to calculate the range when auto scale enabled.
  final GPointViewPortAutoScaleStrategy? autoScaleStrategy;

  /// The animation milliseconds when auto scaling.
  ///
  /// set to 0 to disable animation.
  final GValue<int> _animationMilliseconds = GValue<int>(200);
  int get animationMilliseconds => _animationMilliseconds.value;
  set animationMilliseconds(int value) => _animationMilliseconds.value = value;

  AnimationController? _rangeAnimationController;
  Animation<double>? _rangeAnimation;
  final GRange _animationStartRange = GRange.empty();
  final GRange _animationTargetRange = GRange.empty();
  bool get isAnimating => _animationStartRange.isNotEmpty;

  GPointViewPort({
    double? initialStartPoint,
    double? initialEndPoint,
    this.autoScaleStrategy = const GPointViewPortAutoScaleStrategyLatest(),
    int animationMilliseconds = 200,
    this.minPointWidth = 2,
    this.maxPointWidth = 100,
    this.defaultPointWidth = 10,
  }) {
    assert(
      (initialStartPoint == null && initialEndPoint == null) ||
          (initialStartPoint != null && initialEndPoint != null),
      'initialStartPoint and initialEndPoint should be both null or not null.',
    );
    if (initialStartPoint != null && initialEndPoint != null) {
      _pointRange.update(initialStartPoint, initialEndPoint);
    }
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
      _rangeAnimation!.addListener(rangeAnimationListener);
    }
  }

  void stopAnimation() {
    _rangeAnimationController?.stop();
    _animationStartRange.clear();
    _animationTargetRange.clear();
  }

  void rangeAnimationListener() {
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
    GChart chart,
    GRange targetRange,
    bool finished,
    bool animation, {
    Simulation? simulation,
  }) {
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
    _animationStartRange.update(startPoint, endPoint);
    _animationTargetRange.copy(targetRange);
    Future.delayed(const Duration(milliseconds: 10), () {
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

  void setRange({
    required double startPoint,
    required double endPoint,
    required bool finished,
    bool notify = true,
  }) {
    assert(startPoint < endPoint);
    if (_pointRange.isNotEmpty &&
        startPoint == this.startPoint &&
        endPoint == this.endPoint) {
      return;
    }
    _pointRange.update(startPoint, endPoint);
    if (notify) {
      _notify(finished: finished);
    }
  }

  /// Get the width of a point in view size.
  double pointSize(double width) {
    return _pointSize(width, startPoint, endPoint);
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

  void resize(double fromSize, double toSize, bool notify) {
    if (fromSize == toSize) {
      return;
    }
    final pointSizeCurrent = _pointSize(fromSize, startPoint, endPoint);
    final newStartPoint = endPoint - toSize / pointSizeCurrent;
    setRange(
      startPoint: newStartPoint,
      endPoint: endPoint,
      finished: true,
      notify: notify,
    );
  }

  void interactionStart() {
    _pointRangeScaling.copy(_pointRange);
  }

  void interactionEnd() {
    _pointRangeScaling.clear();
    _selectedRange.clear();
    _notify(finished: true);
  }

  void zoomUpdate(GRange startRange, Rect area, double zoomRatio) {
    if (startRange.isEmpty) {
      return;
    }
    double pointWidthStart = _pointSize(
      area.width,
      startRange.first!,
      startRange.last!,
    );
    double pointWidthNew = min(
      max(pointWidthStart * zoomRatio, minPointWidth),
      maxPointWidth,
    );
    double endPointNew = startRange.last!;
    double startPointNew = startRange.last! - area.width / pointWidthNew;
    setRange(startPoint: startPointNew, endPoint: endPointNew, finished: false);
  }

  void interactionZoomUpdate(Rect area, double zoomRatio) {
    if (_pointRangeScaling.isEmpty) {
      return;
    }
    zoomUpdate(_pointRangeScaling, area, zoomRatio);
  }

  void interactionMoveUpdate(Rect area, double movedDistance) {
    if (_pointRangeScaling.isEmpty) {
      return;
    }
    double pointWidthStart = _pointSize(
      area.width,
      _pointRangeScaling.first!,
      _pointRangeScaling.last!,
    );
    double pointsMoved = movedDistance / pointWidthStart;
    double startPointNew = _pointRangeScaling.begin! - pointsMoved;
    double endPointNew = _pointRangeScaling.end! - pointsMoved;
    setRange(startPoint: startPointNew, endPoint: endPointNew, finished: false);
  }

  void interactionSelectUpdate(
    GChart chart,
    Rect area,
    double startPosition,
    double position, {
    bool animation = true,
    bool finished = false,
  }) {
    if (_pointRangeScaling.isEmpty) {
      return;
    }
    final position1 = min(startPosition, position);
    final position2 = max(startPosition, position);
    _selectedRange.update(
      positionToPoint(area, max(area.left, min(area.right, position1))),
      positionToPoint(area, max(area.left, min(area.right, position2))),
    );
    if (finished) {
      double value1 = _selectedRange.begin!;
      double value2 = _selectedRange.end!;
      double pointLeftNew = max(min(value1, value2), _pointRangeScaling.begin!);
      double pointRightNew = min(max(value1, value2), _pointRangeScaling.end!);
      double minPoints = area.width / maxPointWidth;
      if (pointRightNew - pointLeftNew < minPoints) {
        // adjust to make sure the width is not less than minPointWidth
        double center = (pointLeftNew + pointRightNew) / 2;
        pointLeftNew = center - minPoints / 2;
        pointRightNew = center + minPoints / 2;
      }
      animateToRange(
        chart,
        GRange.range(pointLeftNew, pointRightNew),
        finished,
        animation,
      );
    }
  }

  void autoScaleReset({
    required GChart chart,
    required GPanel panel,
    required bool finished,
    bool animation = true,
  }) {
    if (autoScaleStrategy == null) {
      return;
    }
    final newRange = autoScaleStrategy!.getScale(
      chart: chart,
      panel: panel,
      pointViewPort: this,
    );
    if (newRange.isNotEmpty) {
      animateToRange(chart, newRange, finished, animation);
    }
  }

  double _pointSize(double width, double startPoint, double endPoint) {
    return width / (endPoint - startPoint);
  }

  void _notify({required bool finished}) {
    notifyListeners();
  }
}
