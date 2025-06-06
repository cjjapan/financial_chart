import 'package:financial_chart/financial_chart.dart';

import 'step_line_render.dart';
import 'step_line_theme.dart';

/// A example for custom graph times: Step line graph
class GGraphStepLine extends GGraph<GGraphStepLineTheme> {
  static const String typeName = "stepLine";

  /// The key of the series value in the data source.
  final String valueKey;
  final int pointInterval;
  GGraphStepLine({
    required super.id,
    super.layer,
    super.visible,
    required super.valueViewPortId,
    required this.valueKey,
    this.pointInterval = 10,
    super.hitTestMode,
    super.overlayMarkers,
    super.theme,
    super.render,
  }) {
    super.render = render ?? GGraphStepLineRender();
  }

  @override
  String get type => typeName;
}
