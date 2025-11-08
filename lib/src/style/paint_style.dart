// Adapted from :
//   https://github.com/entronad/graphic/blob/main/lib/src/graffiti/element/element.dart

// MIT License
//
// Copyright (c) 2024 LIN Chen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart' as painting;

import 'dash_path.dart';

/// Checks whether only one parameter is set.
bool isSingle(List params, {allowNone = false}) {
  int count = 0;
  for (final param in params) {
    if (param != null) {
      count++;
    }
  }
  return allowNone ? count <= 1 : count == 1;
}

/// Style for painting shapes with fill and stroke options.
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
       assert(dash != null || dashOffset == null) {
    _fillPaint = _createFillPaint();
    _strokePaint = _createStrokePaint();
    isSimple =
        (fillGradient == null &&
        fillShader == null &&
        strokeGradient == null &&
        strokeShader == null &&
        gradientBounds == null &&
        dash == null &&
        dashOffset == null);
    isEmpty = (_fillPaint == null && _strokePaint == null);
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
      dash: dash ?? this.dash,
      dashOffset: dashOffset ?? this.dashOffset,
    );
  }

  late final Paint? _fillPaint;
  late final Paint? _strokePaint;

  Paint? getFillPaint({Rect? gradientBounds}) {
    if (gradientBounds == null ||
        gradientBounds == this.gradientBounds ||
        fillGradient == null) {
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
          gradientBounds ?? this.gradientBounds ?? Rect.zero,
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
    if (gradientBounds == null ||
        gradientBounds == this.gradientBounds ||
        strokeGradient == null) {
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
          gradientBounds ?? this.gradientBounds ?? Rect.zero,
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

  late final bool isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Whether the style is simple with only pure colors and strokeWidth.
  ///
  /// If true, the style would be used for optimization by apply batch drawing.
  late final bool isSimple;

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
    dash,
    dashOffset,
  ];
}
