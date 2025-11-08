import 'package:flutter/foundation.dart';

import '../../components/components.dart';
import '../../values/value.dart';
import 'ohlc_render.dart';

/// OHLC and candlestick graph for financial data.
class GGraphOhlc<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for OHLC graphs.
  static const String typeName = "ohlc";

  /// The four series value keys for OHLC data.
  final List<String> ohlcValueKeys;

  final GValue<bool> _drawAsCandle;

  /// Gets whether to draw as candlesticks instead of OHLC.
  bool get drawAsCandle => _drawAsCandle.value;

  /// Sets whether to draw as candlesticks instead of OHLC.
  set drawAsCandle(bool value) => _drawAsCandle.value = value;

  @override
  String get type => typeName;

  /// Creates an OHLC graph.
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
