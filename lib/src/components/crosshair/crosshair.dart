import 'dart:ui';

import '../../values/value.dart';
import '../../values/pair.dart';
import '../component.dart';
import 'crosshair_render.dart';

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

  final GValue<bool> _valueAxisLabelsVisible;
  bool get valueAxisLabelsVisible => _valueAxisLabelsVisible.value;
  set valueAxisLabelsVisible(bool value) =>
      _valueAxisLabelsVisible.value = value;

  GCrosshair({
    super.id,
    super.visible,
    super.theme,
    super.render = const GCrosshairRender(),
    bool snapToPoint = true,
    bool pointLinesVisible = true,
    bool valueLinesVisible = true,
    bool pointLabelsVisible = true,
    bool valueLabelsVisible = true,
  }) : _snapToPoint = GValue<bool>(snapToPoint),
       _pointLinesVisible = GValue<bool>(pointLinesVisible),
       _valueLinesVisible = GValue<bool>(valueLinesVisible),
       _pointAxisLabelsVisible = GValue<bool>(pointLabelsVisible),
       _valueAxisLabelsVisible = GValue<bool>(valueLabelsVisible);

  setCrossPosition(double x, double y) {
    crossPosition.update(x, y);
  }

  Offset? getCrossPosition() {
    if (crossPosition.isEmpty) {
      return null;
    }
    return Offset(crossPosition.first!, crossPosition.last!);
  }

  clearCrossPosition() {
    crossPosition.clear();
  }
}
