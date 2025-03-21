import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart' as painting;

import 'package:path_drawing/path_drawing.dart';

/// Checks whether only one of the parameters is set. if [allowNone], none is set
/// also returns true.
bool isSingle(List params, {allowNone = false}) {
  int count = 0;
  for (var param in params) {
    if (param != null) {
      count++;
    }
  }
  return allowNone ? count <= 1 : count == 1;
}

class PaintStyle extends Equatable {
  /// Creates a paint style.
  PaintStyle({
    this.fillColor,
    this.fillGradient,
    this.fillShader,
    this.strokeColor,
    this.strokeGradient,
    this.strokeShader,
    this.gradientBounds,
    this.blendMode,
    this.strokeWidth,
    this.strokeCap,
    this.strokeJoin,
    this.strokeMiterLimit,
    this.elevation,
    Color? shadowColor,
    this.dash,
    this.dashOffset,
  }) : assert(isSingle([fillColor, fillGradient, fillShader], allowNone: true)),
       assert(
         isSingle([strokeColor, strokeGradient, strokeShader], allowNone: true),
       ),
       assert(
         strokeColor != null ||
             strokeGradient != null ||
             strokeShader != null ||
             (strokeWidth == null ||
                 strokeCap == null ||
                 strokeJoin == null ||
                 strokeMiterLimit == null),
       ),
       assert(elevation != null || shadowColor == null),
       assert(dash != null || dashOffset == null),
       shadowColor =
           elevation == null
               ? null
               : fillColor ?? (strokeColor ?? const Color(0xFF000000)) {
    _fillPaint = _createFillPaint();
    _strokePaint = _createStrokePaint();
  }

  PaintStyle copyWith({
    Color? fillColor,
    painting.Gradient? fillGradient,
    Shader? fillShader,
    Color? strokeColor,
    painting.Gradient? strokeGradient,
    Shader? strokeShader,
    Rect? gradientBounds,
    BlendMode? blendMode,
    double? strokeWidth,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? elevation,
    Color? shadowColor,
    List<double>? dash,
    DashOffset? dashOffset,
  }) {
    return PaintStyle(
      fillColor: fillColor ?? this.fillColor,
      fillGradient: fillGradient ?? this.fillGradient,
      fillShader: fillShader ?? this.fillShader,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeGradient: strokeGradient ?? this.strokeGradient,
      strokeShader: strokeShader ?? this.strokeShader,
      gradientBounds: gradientBounds ?? this.gradientBounds,
      blendMode: blendMode ?? this.blendMode,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      dash: dash ?? this.dash,
      dashOffset: dashOffset ?? this.dashOffset,
    );
  }

  late final Paint? _fillPaint;
  late final Paint? _strokePaint;

  Paint? getFillPaint({Rect? gradientBounds}) {
    if (gradientBounds == null || fillGradient == null) {
      return _fillPaint; // return cached paint
    }
    return _createFillPaint(gradientBounds: gradientBounds);
  }

  Paint? _createFillPaint({Rect? gradientBounds}) {
    if (fillColor != null || fillGradient != null || fillShader != null) {
      Paint fillPaint = Paint();

      if (fillShader != null) {
        fillPaint.shader = fillShader;
      } else if (fillGradient != null) {
        fillPaint.shader = fillGradient!.createShader(
          gradientBounds ?? (this.gradientBounds!),
        );
      } else {
        fillPaint.color = fillColor!;
      }
      if (blendMode != null) {
        fillPaint.blendMode = blendMode!;
      }
      return fillPaint;
    }
    return null;
  }

  Paint? getStrokePaint({Rect? gradientBounds}) {
    if (gradientBounds == null || strokeGradient == null) {
      return _strokePaint; // return cached paint
    }
    return _createStrokePaint(gradientBounds: gradientBounds);
  }

  Paint? _createStrokePaint({Rect? gradientBounds}) {
    if (strokeColor != null || strokeGradient != null) {
      Paint strokePaint = Paint();
      strokePaint.style = PaintingStyle.stroke;

      if (strokeShader != null) {
        strokePaint.shader = strokeShader;
      } else if (strokeGradient != null) {
        strokePaint.shader = strokeGradient!.createShader(
          gradientBounds ?? (this.gradientBounds!),
        );
      } else {
        strokePaint.color = strokeColor!;
      }

      if (blendMode != null) {
        strokePaint.blendMode = blendMode!;
      }
      if (strokeWidth != null) {
        strokePaint.strokeWidth = strokeWidth!;
      }
      if (strokeCap != null) {
        strokePaint.strokeCap = strokeCap!;
      }
      if (strokeJoin != null) {
        strokePaint.strokeJoin = strokeJoin!;
      }
      if (strokeMiterLimit != null) {
        strokePaint.strokeMiterLimit = strokeMiterLimit!;
      }
      return strokePaint;
    }
    return null;
  }

  /// The color to fill the shape.
  ///
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final Color? fillColor;

  /// The gradient to fill the shape.
  ///
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final painting.Gradient? fillGradient;

  /// The shader to fill the shape.
  ///
  /// It won't be interpolated in animation.
  ///
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final Shader? fillShader;

  /// The color for shape's outlines.
  ///
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final Color? strokeColor;

  /// The gradient for shape's outlines.
  ///
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final painting.Gradient? strokeGradient;

  /// The shader for shape's outlines.
  ///
  /// It won't be interpolated in animation.
  ///
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final Shader? strokeShader;

  /// The bounds of [fillGradient] and [strokeGradient].
  final Rect? gradientBounds;

  /// The blend mode of the shape.
  final BlendMode? blendMode;

  /// Width of the shape's outlines.
  ///
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final double? strokeWidth;

  /// The kind of finish to place on the end of the shape's outlines.
  ///
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final StrokeCap? strokeCap;

  /// The kind of finish to place on the joins between segments of the shape's outlines.
  ///
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final StrokeJoin? strokeJoin;

  /// The limit for miters to be drawn on segments of the shape's outlines.
  ///
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final double? strokeMiterLimit;

  /// The elevation of the shape's shadow.
  final double? elevation;

  /// The color of the shape's shadow.
  ///
  /// It can only be set when [elevation] is not null. If null, it will be same
  /// as [fillColor] (if fillColor is set) or Color(0xFF000000).
  final Color? shadowColor;

  /// The dash list of the shape's outlines.
  final List<double>? dash;

  /// The dash offset of the shape's outlines.
  ///
  /// It can only be set when [dash] is not null.
  final DashOffset? dashOffset;

  @override
  List<Object?> get props => [
    fillColor,
    fillGradient,
    strokeColor,
    strokeGradient,
    gradientBounds,
    blendMode,
    strokeWidth,
    strokeCap,
    strokeJoin,
    strokeMiterLimit,
    elevation,
    shadowColor,
    dash,
    dashOffset,
  ];
}
