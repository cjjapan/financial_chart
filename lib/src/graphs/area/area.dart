import '../../components/graph/graph.dart';
import 'area_render.dart';
import 'area_theme.dart';

/// Area graph.
///
/// if [baseValueKey] or [baseValue] is not null, the area will be the space between the value and the base value.
/// else the area will be the space between the value and bottom of the viewport.
class GGraphArea extends GGraph<GGraphAreaTheme> {
  static const String typeName = "area";

  /// The key of the series value in the data source.
  final String valueKey;

  /// The key of the base value in the data source.
  final String? baseValueKey;

  /// The base value of the area graph.
  final double? baseValue;

  GGraphArea({
    super.id,
    required this.valueKey,
    this.baseValue = 0,
    this.baseValueKey,
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
    super.render = render ?? GGraphAreaRender();
  }

  @override
  String get type => typeName;
}
