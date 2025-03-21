import 'dart:ui';

import '../../chart.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../../components/marker/marker_render.dart';
import '../../components/marker/marker_theme.dart';
import '../../components/panel/panel.dart';
import '../../components/viewport_h.dart';
import '../../components/viewport_v.dart';
import 'label_marker.dart';

class GLabelMarkerRender
    extends GGraphMarkerRender<GLabelMarker, GGraphMarkerTheme> {
  const GLabelMarkerRender();
  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GGraph<GGraphTheme> graph,
    required GLabelMarker marker,
    required Rect area,
    required GGraphMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.isEmpty) {
      return;
    }
    final anchor = marker.keyCoordinates[0].toPosition(
      area: area,
      valueViewPort: valueViewPort,
      pointViewPort: pointViewPort,
    );
    drawText(
      canvas: canvas,
      text: marker.text,
      anchor: anchor,
      defaultAlign: marker.alignment,
      style: theme.labelStyle!,
    );
  }
}
