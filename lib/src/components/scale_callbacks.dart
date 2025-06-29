import 'package:flutter/gestures.dart';

typedef GScaleUpdateCallback =
    void Function({
      required Offset position,
      required double scale,
      required double verticalScale,
    });

typedef GScaleEndCallback =
    void Function(int pointerCount, double scaleVelocity, Velocity? velocity);
