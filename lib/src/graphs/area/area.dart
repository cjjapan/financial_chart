import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'area_render.dart';

/// Area graph for displaying filled regions under a line.
class GGraphArea<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for area graphs.
  static const String typeName = "area";

  /// The series value key in the data source.
  final String valueKey;

  final GValue<String?> _baseValueKey = GValue(null);

  /// Gets the base value key in the data source.
  String? get baseValueKey => _baseValueKey.value;

  /// Sets the base value key in the data source.
  set baseValueKey(String? value) => _baseValueKey.value = value;

  final GValue<double?> _baseValue = GValue(0);

  /// Gets the base value for the area.
  double? get baseValue => _baseValue.value;

  /// Sets the base value for the area.
  set baseValue(double? value) => _baseValue.value = value;

  /// Creates an area graph.
  GGraphArea({
    super.id,
    super.label,
    required this.valueKey,
    double? baseValue = 0,
    String? baseValueKey,
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
    super.theme = theme;
    super.render = super.render ?? GGraphAreaRender();
    _baseValueKey.value = baseValueKey;
    _baseValue.value = baseValue;
  }

  @override
  String get type => typeName;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('valueKey', valueKey));
    properties.add(StringProperty('baseValueKey', baseValueKey));
    properties.add(DoubleProperty('baseValue', baseValue));
  }
}
