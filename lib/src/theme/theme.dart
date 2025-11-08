import 'package:flutter/foundation.dart';

import '../components/background/background_theme.dart';
import '../components/marker/overlay_marker_theme.dart';
import '../components/marker/axis_marker_theme.dart';
import '../components/panel/panel_theme.dart';

import '../components/tooltip/tooltip_theme.dart';
import '../components/axis/axis_theme.dart';
import '../components/crosshair/crosshair_theme.dart';
import '../components/graph/graph_theme.dart';
import '../components/splitter/splitter_theme.dart';

/// Theme container for all chart components.
class GTheme with Diagnosticable {
  /// Name of the theme.
  final String name;

  /// Theme for the background component.
  final GBackgroundTheme backgroundTheme;

  /// Theme for panel components.
  final GPanelTheme panelTheme;

  /// Theme for point axes.
  final GAxisTheme pointAxisTheme;

  /// Theme for value axes.
  final GAxisTheme valueAxisTheme;

  /// Theme for the crosshair component.
  final GCrosshairTheme crosshairTheme;

  /// Theme for tooltip components.
  final GTooltipTheme tooltipTheme;

  /// Theme for splitter components.
  final GSplitterTheme splitterTheme;

  /// Theme for axis marker components.
  final GAxisMarkerTheme axisMarkerTheme;

  /// Theme for overlay marker components.
  final GOverlayMarkerTheme overlayMarkerTheme;

  /// Map of graph themes by type.
  final Map<String, GGraphTheme> graphThemes;

  /// Creates a theme.
  const GTheme({
    required this.name,
    required this.backgroundTheme,
    required this.panelTheme,
    required this.pointAxisTheme,
    required this.valueAxisTheme,
    required this.crosshairTheme,
    required this.tooltipTheme,
    required this.splitterTheme,
    required this.graphThemes,
    required this.axisMarkerTheme,
    required this.overlayMarkerTheme,
  });

  /// Creates a new theme by extending this theme with overrides.
  GTheme extend({
    String? name,
    GBackgroundTheme? backgroundTheme,
    GPanelTheme? panelTheme,
    GAxisTheme? pointAxisTheme,
    GAxisTheme? valueAxisTheme,
    GCrosshairTheme? crosshairTheme,
    GTooltipTheme? tooltipTheme,
    GSplitterTheme? splitterTheme,
    GAxisMarkerTheme? axisMarkerTheme,
    GOverlayMarkerTheme? overlayMarkerTheme,
    Map<String, GGraphTheme>? graphThemes,
  }) {
    return GTheme(
      name: name ?? this.name,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      panelTheme: panelTheme ?? this.panelTheme,
      pointAxisTheme: pointAxisTheme ?? this.pointAxisTheme,
      valueAxisTheme: valueAxisTheme ?? this.valueAxisTheme,
      crosshairTheme: crosshairTheme ?? this.crosshairTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
      splitterTheme: splitterTheme ?? this.splitterTheme,
      axisMarkerTheme: axisMarkerTheme ?? this.axisMarkerTheme,
      overlayMarkerTheme: overlayMarkerTheme ?? this.overlayMarkerTheme,
      graphThemes: this.graphThemes..addAll(graphThemes ?? {}),
    );
  }

  /// Gets the theme for a specific graph type.
  GGraphTheme? graphTheme(String graphType) {
    return graphThemes[graphType];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('name', name));
  }
}
