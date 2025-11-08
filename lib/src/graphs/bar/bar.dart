import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'bar_render.dart';

/// Bar graph for displaying vertical bars.
class GGraphBar<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for bar graphs.
  static const String typeName = "bar";

  /// The series value key in the data source.
  final String valueKey;

  final GValue<double?> _baseValue = GValue(null);

  /// Gets the base value for bars.
  double? get baseValue => _baseValue.value;

  /// Sets the base value for bars.
  set baseValue(double? value) => _baseValue.value = value;

  final GValue<double> _basePosition = GValue(1.0);

  /// Gets the base position (0-1) for bars.
  double get basePosition => _basePosition.value;

  /// Sets the base position (0-1) for bars.
  set basePosition(double value) {
    assert(value >= 0 && value <= 1, 'basePosition must be between 0 and 1');
    _basePosition.value = value;
  }

  /// Creates a bar graph.
  GGraphBar({
    super.id,
    super.label,
    required this.valueKey,
    double? baseValue,
    double basePosition = 1.0,
    super.layer,
    super.visible,
    super.highlighted,
    super.selected,
    super.valueViewPortId,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    _baseValue.value = baseValue;
    _basePosition.value = basePosition;
    super.theme = theme;
    super.render = super.render ?? GGraphBarRender();
  }

  @override
  String get type => typeName;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('valueKey', valueKey));
    properties.add(DoubleProperty('baseValue', baseValue));
  }
}
