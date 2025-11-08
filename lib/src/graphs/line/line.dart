import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'line_render.dart';

/// Line graph for displaying continuous data.
class GGraphLine<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for line graphs.
  static const String typeName = "line";

  /// The series value key in the data source.
  final String valueKey;

  final GValue<bool> _smoothing = GValue<bool>(false);

  /// Gets whether line smoothing is enabled.
  bool get smoothing => _smoothing.value;

  /// Sets whether line smoothing is enabled.
  set smoothing(bool value) {
    _smoothing.value = value;
  }

  /// Creates a line graph.
  GGraphLine({
    super.id,
    super.label,
    super.layer,
    super.visible,
    super.highlighted,
    super.selected,
    super.valueViewPortId,
    required this.valueKey,
    bool smoothing = false,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = render ?? GGraphLineRender();
    _smoothing.value = smoothing;
  }

  @override
  String get type => typeName;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('valueKey', valueKey));
    properties.add(DiagnosticsProperty<bool>('smoothing', smoothing));
  }
}
