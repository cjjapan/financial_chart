import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'bar_render.dart';

/// Bar graph.
class GGraphBar<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "bar";

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  ///
  /// If this value is not null, the bar will be the space between the value and the base value.
  /// else the bar will be the space between the value and the bottom of the viewport.
  final GValue<double?> _baseValue = GValue(null);
  double? get baseValue => _baseValue.value;
  set baseValue(double? value) => _baseValue.value = value;

  GGraphBar({
    super.id,
    super.label,
    required this.valueKey,
    double? baseValue,
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
