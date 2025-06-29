import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../../chart.dart';
import '../components.dart';

abstract class GOverlayMarkerScaleHandler<M extends GOverlayMarker> {
  (GScaleUpdateCallback, GScaleEndCallback)? tryScale({
    required GChart chart,
    required GPanel panel,
    required GGraph graph,
    required M marker,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
    required Rect area,
    required Offset position,
  });

  void scaleUpdate({
    required Offset position,
    required double scale,
    required double verticalScale,
  });

  void scaleEnd(int pointerCount, double scaleVelocity, Velocity? velocity);
}
