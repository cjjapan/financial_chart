import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../chart.dart';
import '../../values/value.dart';
import '../../values/pair.dart';
import '../components.dart';

/// Trigger events for the crosshair.
enum GCrosshairTrigger {
  /// Mouse enters the chart area.
  mouseEnter,

  /// Mouse moves over the chart area.
  mouseHover,

  /// Mouse exits the chart area.
  mouseExit,

  /// Chart is resized.
  resized,

  /// Tap down event.
  tapDown,

  /// Tap up event.
  tapUp,

  /// Long press starts.
  longPressStart,

  /// Long press moves.
  longPressMove,

  /// Long press ends.
  longPressEnd,

  /// Scale gesture starts.
  scaleStart,

  /// Scale gesture updates.
  scaleUpdate,

  /// Scale gesture ends.
  scaleEnd,
}

/// Strategy for updating crosshair position and visibility.
abstract class GCrosshairUpdateStrategy {
  /// Updates the crosshair based on the trigger event and position.
  void update({
    required GChart chart,
    required GCrosshairTrigger trigger,
    double? x,
    double? y,
  });
}

/// Crosshair update strategy based on trigger events.
class GCrosshairUpdateStrategyByTriggers implements GCrosshairUpdateStrategy {
  /// Triggers that show the crosshair.
  final Set<GCrosshairTrigger> onTriggers;

  /// Triggers that hide the crosshair.
  final Set<GCrosshairTrigger> offTriggers;

  /// Creates a trigger-based crosshair update strategy.
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

/// Default crosshair update strategy.
class GCrosshairUpdateStrategyDefault
    extends GCrosshairUpdateStrategyByTriggers {
  /// Creates a default crosshair update strategy.
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

/// Crosshair update strategy that always hides the crosshair.
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

/// Crosshair component displaying vertical and horizontal lines at the pointer position.
class GCrosshair extends GComponent {
  /// Current crosshair position.
  final GDoublePair crossPosition = GDoublePair.empty();

  final GValue<bool> _snapToPoint;

  /// Gets whether the crosshair snaps to the nearest point.
  bool get snapToPoint => _snapToPoint.value;

  /// Sets whether the crosshair snaps to the nearest point.
  set snapToPoint(bool value) => _snapToPoint.value = value;

  final GValue<bool> _pointLinesVisible;

  /// Gets whether vertical lines are visible.
  bool get pointLinesVisible => _pointLinesVisible.value;

  /// Sets whether vertical lines are visible.
  set pointLinesVisible(bool value) => _pointLinesVisible.value = value;

  final GValue<bool> _valueLinesVisible;

  /// Gets whether horizontal lines are visible.
  bool get valueLinesVisible => _valueLinesVisible.value;

  /// Sets whether horizontal lines are visible.
  set valueLinesVisible(bool value) => _valueLinesVisible.value = value;

  final GValue<bool> _pointAxisLabelsVisible;

  /// Gets whether point axis labels are visible.
  bool get pointAxisLabelsVisible => _pointAxisLabelsVisible.value;

  /// Sets whether point axis labels are visible.
  set pointAxisLabelsVisible(bool value) =>
      _pointAxisLabelsVisible.value = value;

  final GValue<bool> _valueAxisLabelsVisible;

  /// Gets whether value axis labels are visible.
  bool get valueAxisLabelsVisible => _valueAxisLabelsVisible.value;

  /// Sets whether value axis labels are visible.
  set valueAxisLabelsVisible(bool value) =>
      _valueAxisLabelsVisible.value = value;

  final GValue<GCrosshairUpdateStrategy> _updateStrategy =
      GValue<GCrosshairUpdateStrategy>(GCrosshairUpdateStrategyDefault());

  /// Gets the crosshair update strategy.
  GCrosshairUpdateStrategy get updateStrategy => _updateStrategy.value;

  /// Sets the crosshair update strategy.
  set updateStrategy(GCrosshairUpdateStrategy value) =>
      _updateStrategy.value = value;

  /// Creates a crosshair component.
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

  /// Updates the crosshair position using the configured update strategy.
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
