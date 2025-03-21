import '../../components/graph/graph.dart';
import 'bar_render.dart';
import 'bar_theme.dart';

/// Bar graph.
class GGraphBar extends GGraph<GGraphBarTheme> {
  static const String typeName = "bar";

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  ///
  /// If this value is not null, the bar will be the space between the value and the base value.
  /// else the bar will be the space between the value and the bottom of the viewport.
  final double? baseValue;

  GGraphBar({
    super.id,
    required this.valueKey,
    this.baseValue,
    super.layer,
    super.visible,
    required super.valueViewPortId,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.axisMarkers,
    super.graphMarkers,
    super.theme,
    super.render,
  }) {
    super.render = render ?? GGraphBarRender();
  }

  @override
  String get type => typeName;
}
