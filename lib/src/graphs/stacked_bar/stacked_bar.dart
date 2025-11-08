import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'stacked_bar_render.dart';

/// Stacked bar graph.
class GGraphStackedBar<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "stacked_bar";

  /// The keys of the series values in the data source.
  /// For example with keys ["A", "B"], will draw a bar segment from baseValue
  /// to value of "A" and also another bar segment from value of "A" to value of "B".
  final List<String> valueKeys;

  /// The base value in the data source.
  ///
  /// If this value is not null, the bar will start from this value.
  /// Otherwise, the bar will start from the position defined by basePosition.
  final GValue<double?> _baseValue = GValue(null);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  /// A value from 0 to 1 which defines start position of the first bar.
  /// Only used when baseValue is null.
  /// when null the first bar segment will be value of first valueKey to value of second valueKey.
  final GValue<double?> _basePosition = GValue(1.0);
  double? get basePosition => _basePosition.value;
  set basePosition(double? value) {
    assert(
      value == null || (value >= 0 && value <= 1),
      'basePosition must be between 0 and 1',
    );
    _basePosition.value = value;
  }

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
