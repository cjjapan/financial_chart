import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../chart.dart';
import '../../values/value.dart';
import '../../values/pair.dart';
import '../components.dart';

/// The crosshair trigger events.
///
/// Not every event can be triggered on all area of the chart.
/// For example, long press events are only triggered on the graph area.
enum GCrosshairTrigger {
  mouseEnter,
  mouseHover,
  mouseExit,
  resized,
  tapDown,
  tapUp,
  longPressStart,
  longPressMove,
  longPressEnd,
  scaleStart,
  scaleUpdate,
  scaleEnd,
}

/// The crosshair position update strategy.
abstract class GCrosshairUpdateStrategy {
  /// show / hide /update position of the crosshair in this method.
  void update({
    required GChart chart,
    required GCrosshairTrigger trigger,
    double? x,
    double? y,
  });
}

/// The crosshair update strategy which
/// update the crosshair position based on the provided on/off triggers.
class GCrosshairUpdateStrategyByTriggers implements GCrosshairUpdateStrategy {
  /// The triggers that will show the crosshair.
  final Set<GCrosshairTrigger> onTriggers;

  /// The triggers that will hide the crosshair.
  final Set<GCrosshairTrigger> offTriggers;

  GCrosshairUpdateStrategyByTriggers({
    required this.onTriggers,
    required this.offTriggers,
  });

  @override
  void update({
    required GChart chart,
    required GCrosshairTrigger trigger,
    double? x,
    double? y,
  }) {
    final crossPosition = chart.crosshair.crossPosition;
    double? newX = x ?? crossPosition.first;
    double? newY = y ?? crossPosition.last;
    if (newX == null || newY == null) {
      crossPosition.clear();
    } else {
      if (offTriggers.contains(trigger)) {
        crossPosition.clear();
      } else if (onTriggers.contains(trigger)) {
        crossPosition.update(newX, newY);
      }
    }
  }
}

/// The default crosshair update strategy which
/// shows the crosshair when the pointer is over, tapped or long pressed
class GCrosshairUpdateStrategyDefault
    extends GCrosshairUpdateStrategyByTriggers {
  GCrosshairUpdateStrategyDefault({
    bool withTap = false,
    bool withMouseHover = true,
    bool withScale = true,
    bool wthLongPress = true,
  }) : super(
         onTriggers: {
           if (withMouseHover) GCrosshairTrigger.mouseEnter,
           if (withMouseHover) GCrosshairTrigger.mouseHover,
           if (withTap) GCrosshairTrigger.tapDown,
           if (wthLongPress) GCrosshairTrigger.longPressStart,
           if (wthLongPress) GCrosshairTrigger.longPressMove,
           if (withScale) GCrosshairTrigger.scaleStart,
           if (withScale) GCrosshairTrigger.scaleUpdate,
         },
         offTriggers: {
           if (withMouseHover) GCrosshairTrigger.mouseExit,
           if (!wthLongPress) GCrosshairTrigger.longPressStart,
           GCrosshairTrigger.longPressEnd, // always hide on long press end
           if (!withScale) GCrosshairTrigger.scaleStart,
           if (withScale) GCrosshairTrigger.scaleEnd,
         },
       );
}

/// The crosshair update strategy which always hide.
class GCrosshairUpdateStrategyNone implements GCrosshairUpdateStrategy {
  @override
  void update({
    required GChart chart,
    required GCrosshairTrigger trigger,
    double? x,
    double? y,
  }) {
    chart.crosshair.clearCrossPosition();
  }
}

/// Crosshair with vertical and horizontal lines over the chart when pointer is moving over it.
class GCrosshair extends GComponent {
  /// the pointer position.
  final GDoublePair crossPosition = GDoublePair.empty();

  /// Whether the crosshair should snap to the nearest point.
  final GValue<bool> _snapToPoint;
  bool get snapToPoint => _snapToPoint.value;
  set snapToPoint(bool value) => _snapToPoint.value = value;

  /// Whether the point lines are visible.
  final GValue<bool> _pointLinesVisible;
  bool get pointLinesVisible => _pointLinesVisible.value;
  set pointLinesVisible(bool value) => _pointLinesVisible.value = value;

  /// Whether the value lines are visible.
  final GValue<bool> _valueLinesVisible;
  bool get valueLinesVisible => _valueLinesVisible.value;
  set valueLinesVisible(bool value) => _valueLinesVisible.value = value;

  /// Whether the point labels are visible.
  final GValue<bool> _pointAxisLabelsVisible;
  bool get pointAxisLabelsVisible => _pointAxisLabelsVisible.value;
  set pointAxisLabelsVisible(bool value) =>
      _pointAxisLabelsVisible.value = value;

  /// Whether the value labels are visible.
  final GValue<bool> _valueAxisLabelsVisible;
  bool get valueAxisLabelsVisible => _valueAxisLabelsVisible.value;
  set valueAxisLabelsVisible(bool value) =>
      _valueAxisLabelsVisible.value = value;

  /// The crosshair update strategy.
  final GValue<GCrosshairUpdateStrategy> _updateStrategy =
      GValue<GCrosshairUpdateStrategy>(GCrosshairUpdateStrategyDefault());
  GCrosshairUpdateStrategy get updateStrategy => _updateStrategy.value;
  set updateStrategy(GCrosshairUpdateStrategy value) =>
      _updateStrategy.value = value;

  GCrosshair({
    super.id,
    super.visible,
    super.theme,
    GRender? render,
    bool snapToPoint = true,
    bool pointLinesVisible = true,
    bool valueLinesVisible = true,
    bool pointLabelsVisible = true,
    bool valueLabelsVisible = true,
    GCrosshairUpdateStrategy? updateStrategy,
  }) : _snapToPoint = GValue<bool>(snapToPoint),
       _pointLinesVisible = GValue<bool>(pointLinesVisible),
       _valueLinesVisible = GValue<bool>(valueLinesVisible),
       _pointAxisLabelsVisible = GValue<bool>(pointLabelsVisible),
       _valueAxisLabelsVisible = GValue<bool>(valueLabelsVisible) {
    this.render = render ?? const GCrosshairRender();
    if (updateStrategy != null) {
      _updateStrategy.value = updateStrategy;
    }
  }

  /// update the crosshair position by provided [updateStrategy]
  void updateCrossPosition({
    required GChart chart,
    required GCrosshairTrigger trigger,
    double? x,
    double? y,
  }) {
    updateStrategy.update(chart: chart, trigger: trigger, x: x, y: y);
  }

  /// update the crosshair position by provided [x] and [y]
  void setCrossPosition(double x, double y) {
    crossPosition.update(x, y);
  }

  /// clear the crosshair position
  void clearCrossPosition() {
    if (crossPosition.isEmpty) {
      return;
    }
    crossPosition.clear();
  }

  /// get the crosshair position as [Offset]
  Offset? getCrossPosition() {
    if (crossPosition.isEmpty) {
      return null;
    }
    return Offset(crossPosition.first!, crossPosition.last!);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<GCrosshairUpdateStrategy>(
        'updateStrategy',
        updateStrategy,
      ),
    );
    properties.add(DiagnosticsProperty<bool>('snapToPoint', snapToPoint));
    properties.add(
      DiagnosticsProperty<bool>('pointLinesVisible', pointLinesVisible),
    );
    properties.add(
      DiagnosticsProperty<bool>('valueLinesVisible', valueLinesVisible),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'pointAxisLabelsVisible',
        pointAxisLabelsVisible,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'valueAxisLabelsVisible',
        valueAxisLabelsVisible,
      ),
    );
  }
}
