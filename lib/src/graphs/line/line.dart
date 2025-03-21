import '../../components/graph/graph.dart';
import 'line_render.dart';
import 'line_theme.dart';

/// Line graph
class GGraphLine extends GGraph<GGraphLineTheme> {
  static const String typeName = "line";

  /// The key of the series value in the data source.
  final String valueKey;
  GGraphLine({
    super.id,
    super.layer,
    super.visible,
    required super.valueViewPortId,
    required this.valueKey,
    super.hitTestMode,
    super.crosshairHighlightValueKeys,
    super.axisMarkers,
    super.graphMarkers,
    super.theme,
    super.render,
  }) {
    super.render = render ?? GGraphLineRender();
  }

  @override
  String get type => typeName;
}
