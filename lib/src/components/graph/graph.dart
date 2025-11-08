import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../marker/overlay_marker.dart';
import '../render.dart';
import 'graph_render.dart';
import 'graph_theme.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../viewport_v.dart';

/// Base class for all graph components.
class GGraph<T extends GGraphTheme> extends GComponent {
  /// Type identifier for graph components.
  static const String typeName = 'graph';

  /// The viewport ID this graph is associated with.
  final String valueViewPortId;

  /// Series value keys that trigger crosshair highlights.
  final List<String> crosshairHighlightValueKeys = [];

  final List<GOverlayMarker> _overlayMarkers = [];

  /// Gets an unmodifiable list of overlay markers for this graph.
  List<GOverlayMarker> get overlayMarkers => List.unmodifiable(_overlayMarkers);

  /// Creates a graph.
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

  /// Finds a marker by its ID.
  GOverlayMarker? findMarker(String id) {
    return _overlayMarkers.where((marker) => marker.id == id).firstOrNull;
  }

  /// Removes a marker by its ID and returns it if found.
  GOverlayMarker? removeMarkerById(String id) {
    final marker = findMarker(id);
    if (marker != null) {
      _overlayMarkers.remove(marker);
      return marker;
    }
    return null;
  }

  /// Removes a specific marker from this graph.
  bool removeMarker(GOverlayMarker marker) {
    return _overlayMarkers.remove(marker);
  }

  /// Adds a marker to this graph.
  void addMarker(GOverlayMarker marker) {
    _overlayMarkers.add(marker);
  }

  /// Removes all markers from this graph.
  void clearMarkers() {
    _overlayMarkers.clear();
  }

  /// Performs hit testing on overlay markers at the given position.
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
