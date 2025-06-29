import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'ohlc_render.dart';

/// OHLC (and Candle) graph
class GGraphOhlc<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "ohlc";

  /// The four keys of the OHLC values in the data source.
  final List<String> ohlcValueKeys;

  /// If true, will draw candlesticks instead of OHLC.
  final GValue<bool> _drawAsCandle;
  bool get drawAsCandle => _drawAsCandle.value;
  set drawAsCandle(bool value) => _drawAsCandle.value = value;

  @override
  String get type => typeName;

  GGraphOhlc({
    super.id,
    super.label,
    super.valueViewPortId,
    required this.ohlcValueKeys,
    bool drawAsCandle = true,
    super.layer,
    super.visible,
    super.highlighted,
    super.selected,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) : _drawAsCandle = GValue(drawAsCandle) {
    assert(
      ohlcValueKeys.toSet().length == 4,
      "The length of ohlcValueKeys must be 4.",
    );
    super.theme = theme;
    super.render = render ?? GGraphOhlcRender();
  }

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('ohlcValueKeys', ohlcValueKeys));
    properties.add(DiagnosticsProperty<bool>('drawAsCandle', drawAsCandle));
  }
}
