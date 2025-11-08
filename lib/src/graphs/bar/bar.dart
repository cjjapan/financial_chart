import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'bar_render.dart';

/// Bar graph.
class GGraphBar<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "bar";

  /// The key of the series value in the data source.
  final String valueKey;

  /// The base value in the data source.
  ///
  /// If this value is not null, the bar will be the space between the value of valueKey and the base value.
  /// else the bar will be the space between the value and basePosition.
  final GValue<double?> _baseValue = GValue(null);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  /// A value from 0 to 1 which defines start position of the first bar.
  /// Only used when baseValue is null.
  final GValue<double> _basePosition = GValue(1.0);
  double get basePosition => _basePosition.value;
  set basePosition(double value) {
    assert(value >= 0 && value <= 1, 'basePosition must be between 0 and 1');
    _basePosition.value = value;
  }

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
