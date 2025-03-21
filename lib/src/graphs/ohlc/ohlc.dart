import '../../components/graph/graph.dart';
import '../../values/value.dart';
import 'ohlc_render.dart';
import 'ohlc_theme.dart';

/// OHLC (and Candle) graph
class GGraphOhlc extends GGraph<GGraphOhlcTheme> {
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
    required super.valueViewPortId,
    required this.ohlcValueKeys,
    bool drawAsCandle = true,
    super.layer,
    super.visible,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.axisMarkers,
    super.graphMarkers,
    super.theme,
    super.render,
  }) : _drawAsCandle = GValue(drawAsCandle) {
    assert(ohlcValueKeys.length == 4, "The length of ohlcValueKeys must be 4.");
    super.render = render ?? GGraphOhlcRender();
  }
}
