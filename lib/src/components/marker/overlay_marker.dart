import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../../values/coord.dart';
import '../../values/value.dart';
import '../components.dart';

/// Base class for Markers overlay on anther component (usually a axis or a graph).
abstract class GOverlayMarker extends GMarker {
  /// Key points decides the shape of the marker.
  final List<GCoordinate> keyCoordinates;

  final GValue<GOverlayMarkerScaleHandler<GOverlayMarker>?> _scaleHandler =
      GValue<GOverlayMarkerScaleHandler<GOverlayMarker>?>(null);
  GOverlayMarkerScaleHandler<GOverlayMarker>? get scaleHandler =>
      _scaleHandler.value;
  set scaleHandler(GOverlayMarkerScaleHandler<GOverlayMarker>? value) {
    _scaleHandler.value = value;
  }

  @override
  GOverlayMarkerTheme? get theme => super.theme as GOverlayMarkerTheme?;

  @override
  set theme(GComponentTheme? value) {
    if (value != null && value is! GOverlayMarkerTheme) {
      throw ArgumentError('theme must be a GOverlayMarkerTheme');
    }
    super.theme = value;
  }

  GOverlayMarker({
    super.id,
    super.label,
    super.highlighted,
    super.selected,
    super.locked,
    super.visible,
    super.layer,
    super.hitTestMode,
    GOverlayMarkerTheme? theme,
    GOverlayMarkerRender? render,
    this.keyCoordinates = const [],
    GOverlayMarkerScaleHandler<GOverlayMarker>? scaleHandler,
  }) : super(theme: theme, render: render) {
    _scaleHandler.value = scaleHandler;
  }

  @override
  GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme> getRender() {
    return super.getRender()
        as GOverlayMarkerRender<GOverlayMarker, GOverlayMarkerTheme>;
  }

  bool hitTest({
    required Offset position,
    double? epsilon,
    autoHighlight = true,
  }) {
    if (hitTestMode == GHitTestMode.none) {
      return false;
    }
    bool test = getRender().hitTest(position: position, epsilon: epsilon);
    if (autoHighlight) {
      highlighted = test;
    }
    return test;
  }
}
