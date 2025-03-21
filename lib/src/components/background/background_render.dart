import 'dart:ui';

import '../../chart.dart';
import '../panel/panel.dart';
import '../render.dart';
import 'background.dart';
import 'background_theme.dart';

/// The render for [GBackground].
class GBackgroundRender extends GRender<GBackground, GBackgroundTheme> {
  const GBackgroundRender();
  @override
  void doRender({
    required Canvas canvas,
    required GChart chart,
    GPanel? panel,
    required GBackground component,
    required Rect area,
    required GBackgroundTheme theme,
  }) {
    drawPath(canvas: canvas, path: Path()..addRect(area), style: theme.style);
  }
}
