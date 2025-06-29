import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../marker/overlay_marker.dart';
import '../render.dart';
import 'graph_render.dart';
import 'graph_theme.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../viewport_v.dart';

/// Base class for graph components.
///
/// This is not abstract so we can create a empty [GGraph] with only markers.
class GGraph<T extends GGraphTheme> extends GComponent {
  static const String typeName = 'graph';

  /// The value viewport id of the graph.
  ///
  /// see [GValueViewPort] for more details.
  /// point viewport is shared for the whole panel. see [GPanel.pointViewPortId]
  final String valueViewPortId;

  /// The keys of the series value in the data source that
  /// will be highlighted by drawing a circle on the graph.
  final List<String> crosshairHighlightValueKeys = [];

  /// The graph markers of the graph.
  List<GOverlayMarker> get overlayMarkers => List.unmodifiable(_overlayMarkers);
  final List<GOverlayMarker> _overlayMarkers = [];

  GGraph({
    super.id,
    super.label,
    this.valueViewPortId = "", // empty means the default view port id
    super.layer,
    super.visible,
    super.highlighted,
    super.selected,
    super.hitTestMode,
    T? super.theme,
    GGraphRender? super.render,
    List<String>? crosshairHighlightValueKeys,
    List<GOverlayMarker> overlayMarkers = const [],
  }) {
    if (overlayMarkers.isNotEmpty) {
      _overlayMarkers.addAll(overlayMarkers);
    }
    if (crosshairHighlightValueKeys != null) {
      this.crosshairHighlightValueKeys.addAll(crosshairHighlightValueKeys);
    }
  }

  GOverlayMarker? findMarker(String id) {
    return _overlayMarkers.where((marker) => marker.id == id).firstOrNull;
  }

  GOverlayMarker? removeMarkerById(String id) {
    final marker = findMarker(id);
    if (marker != null) {
      _overlayMarkers.remove(marker);
      return marker;
    }
    return null;
  }

  bool removeMarker(GOverlayMarker marker) {
    return _overlayMarkers.remove(marker);
  }

  void addMarker(GOverlayMarker marker) {
    _overlayMarkers.add(marker);
  }

  void clearMarkers() {
    _overlayMarkers.clear();
  }

  GOverlayMarker? hitTestOverlayMarkers({required Offset position}) {
    for (final marker in _overlayMarkers) {
      if (marker.visible && marker.hitTest(position: position)) {
        return marker;
      }
    }
    return null;
  }

  @override
  GRender getRender() {
    return render ?? const GGraphRender();
  }

  String get type => typeName;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('valueViewPortId', valueViewPortId));
    if (crosshairHighlightValueKeys.isNotEmpty) {
      properties.add(
        IterableProperty<String>(
          'crosshairHighlightValueKeys',
          crosshairHighlightValueKeys,
        ),
      );
    }
  }
}
