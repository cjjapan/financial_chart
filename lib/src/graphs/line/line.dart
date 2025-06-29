import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'line_render.dart';

/// Line graph
class GGraphLine<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "line";

  /// The key of the series value in the data source.
  final String valueKey;

  /// Whether to smooth the line.
  final GValue<bool> _smoothing = GValue<bool>(false);
  bool get smoothing => _smoothing.value;
  set smoothing(bool value) {
    _smoothing.value = value;
  }

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
