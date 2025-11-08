import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'stacked_bar_render.dart';

/// Stacked bar graph for displaying multiple data series as segmented bars.
class GGraphStackedBar<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for stacked bar graphs.
  static const String typeName = "stacked_bar";

  /// Series value keys in the data source for each bar segment.
  final List<String> valueKeys;

  final GValue<double?> _baseValue = GValue(null);

  /// Gets the base value for the first bar segment.
  double? get baseValue => _baseValue.value;

  /// Sets the base value for the first bar segment.
  set baseValue(double? value) => _baseValue.value = value;

  final GValue<double?> _basePosition = GValue(1.0);

  /// Gets the base position (0 to 1) for the first bar segment when baseValue is null.
  double? get basePosition => _basePosition.value;

  /// Sets the base position (0 to 1) for the first bar segment when baseValue is null.
  set basePosition(double? value) {
    assert(
      value == null || (value >= 0 && value <= 1),
      'basePosition must be between 0 and 1',
    );
    _basePosition.value = value;
  }

  /// Creates a stacked bar graph.
  GGraphStackedBar({
    super.id,
    super.label,
    required this.valueKeys,
    double? baseValue,
    double? basePosition,
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
  }) : assert(valueKeys.isNotEmpty, 'valueKeys cannot be empty') {
    _baseValue.value = baseValue;
    _basePosition.value = basePosition;
    super.theme = theme;
    super.render = super.render ?? GGraphStackedBarRender();
  }

  @override
  String get type => typeName;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('valueKeys', valueKeys));
    properties.add(DoubleProperty('baseValue', baseValue));
    properties.add(DoubleProperty('basePosition', basePosition));
  }
}
