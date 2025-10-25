import 'package:financial_chart/src/components/marker/overlay_marker_render.dart';

import '../../style/label_style.dart';
import '../../style/paint_style.dart';
import './marker_theme.dart';

enum GControlHandleShape { circle, square, diamond, crossCircle, crossSquare }

class GControlHandleTheme {
  final GControlHandleShape shape;
  final double size;
  final PaintStyle style;

  const GControlHandleTheme({
    this.shape = GControlHandleShape.circle,
    this.size = 4.0,
    required this.style,
  });

  GControlHandleTheme copyWith({
    GControlHandleShape? shape,
    double? size,
    PaintStyle? style,
  }) {
    return GControlHandleTheme(
      shape: shape ?? this.shape,
      size: size ?? this.size,
      style: style ?? this.style,
    );
  }
}

/// Base class for graph marker theme
class GOverlayMarkerTheme extends GMarkerTheme {
  static final emptyPaintStyle = PaintStyle();
  final PaintStyle markerStyle;
  final LabelStyle? labelStyle;
  final Map<GControlHandleType, GControlHandleTheme> controlHandleThemes;

  const GOverlayMarkerTheme({
    required this.markerStyle,
    this.labelStyle,
    required this.controlHandleThemes,
  });

  GOverlayMarkerTheme copyWith({
    PaintStyle? markerStyle,
    LabelStyle? labelStyle,
    Map<GControlHandleType, GControlHandleTheme>? controlHandleThemes,
  }) {
    return GOverlayMarkerTheme(
      markerStyle: markerStyle ?? this.markerStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      controlHandleThemes: controlHandleThemes ?? this.controlHandleThemes,
    );
  }

  GControlHandleTheme getControlHandleTheme(GControlHandleType handleType) {
    return controlHandleThemes[handleType] ??
        controlHandleThemes.values.firstOrNull ??
        GControlHandleTheme(style: emptyPaintStyle);
  }
}
