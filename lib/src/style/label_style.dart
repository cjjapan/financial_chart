import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'paint_style.dart';

/// The style of a text label.
class LabelStyle extends Equatable {
  /// Creates a label style.
  LabelStyle({
    this.textStyle,
    this.span,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.maxLines,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.minWidth,
    this.maxWidth,
    this.backgroundStyle,
    this.backgroundPadding,
    this.backgroundCornerRadius,
    this.offset,
    this.rotation,
    this.align,
  }) : assert(isSingle([textStyle, span]));

  LabelStyle copyWith({
    TextStyle? textStyle,
    InlineSpan Function(String)? span,
    TextAlign? textAlign,
    TextDirection? textDirection,
    TextScaler? textScaler,
    int? maxLines,
    String? ellipsis,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    double? minWidth,
    double? maxWidth,
    PaintStyle? backgroundStyle,
    EdgeInsetsGeometry? backgroundPadding,
    double? backgroundCornerRadius,
    Offset? offset,
    double? rotation,
    Alignment? align,
  }) => LabelStyle(
    textStyle: textStyle ?? this.textStyle,
    span: span ?? this.span,
    textAlign: textAlign ?? this.textAlign,
    textDirection: textDirection ?? this.textDirection,
    textScaler: textScaler ?? this.textScaler,
    maxLines: maxLines ?? this.maxLines,
    ellipsis: ellipsis ?? this.ellipsis,
    locale: locale ?? this.locale,
    strutStyle: strutStyle ?? this.strutStyle,
    textWidthBasis: textWidthBasis ?? this.textWidthBasis,
    textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
    minWidth: minWidth ?? this.minWidth,
    maxWidth: maxWidth ?? this.maxWidth,
    backgroundStyle: backgroundStyle ?? this.backgroundStyle,
    backgroundPadding: backgroundPadding ?? this.backgroundPadding,
    backgroundCornerRadius:
        backgroundCornerRadius ?? this.backgroundCornerRadius,
    offset: offset ?? this.offset,
    rotation: rotation ?? this.rotation,
    align: align ?? this.align,
  );

  /// The offset of the block element from the anchor.
  final Offset? offset;

  /// The rotation of the block element.
  ///
  /// The rotation axis is the anchor point with [offset].
  final double? rotation;

  /// How the block element align to the anchor point.
  final Alignment? align;

  /// The text style of the label.
  ///
  /// If set, it will construct the [TextPainter.text] with the text string, and
  /// [span] is not allowed.
  ///
  /// Note that the default color is white.
  final TextStyle? textStyle;

  /// The function to get the [TextPainter.text] form the text string.
  ///
  /// If set, [textStyle] is not allowed.
  final InlineSpan Function(String)? span;

  /// How the text should be aligned horizontally.
  ///
  /// It defaults to [TextAlign.start].
  final TextAlign? textAlign;

  /// The default directionality of the text.
  ///
  /// This controls how the [TextAlign.start], [TextAlign.end], and
  /// [TextAlign.justify] values of [textAlign] are resolved.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the text string is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// It is default to [TextDirection.ltr]. **This default value is only for conciseness.
  /// We cherish the diversity of cultures, and insist that not any language habit
  /// should be regarded as "default".**
  final TextDirection? textDirection;

  /// The font scaling strategy to use when laying out and rendering the text.
  ///
  /// The value usually comes from [MediaQuery.textScalerOf],
  /// which typically reflects the user-specified text scaling value in the platform's accessibility settings.
  /// The [TextStyle.fontSize] of the text will be adjusted by the [TextScaler] before the text is laid out and rendered.
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  ///
  /// If the text exceeds the given number of lines, it is truncated such that
  /// subsequent lines are dropped.
  final int? maxLines;

  /// The string used to ellipsize overflowing text. Setting this to a non-empty
  /// string will cause this string to be substituted for the remaining text
  /// if the text can not fit within the specified maximum width.
  ///
  /// Specifically, the ellipsis is applied to the last line before the line
  /// truncated by [maxLines], if [maxLines] is non-null and that line overflows
  /// the width constraint, or to the first line that is wider than the width
  /// constraint, if [maxLines] is null. The width constraint is the [maxWidth].
  final String? ellipsis;

  /// The locale used to select region-specific glyphs.
  final Locale? locale;

  /// The strut style to use. Strut style defines the strut, which sets minimum
  /// vertical layout metrics.
  ///
  /// Omitting or providing null will disable strut.
  ///
  /// Omitting or providing null for any properties of [StrutStyle] will result in
  /// default values being used. It is highly recommended to at least specify a
  /// [StrutStyle.fontSize].
  ///
  /// See [StrutStyle] for details.
  final StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the
  /// first line and descent of the last line.
  ///
  /// Each boolean value represents whether the [TextStyle.height] modifier will
  /// be applied to the corresponding metric. By default, all properties are true,
  /// and [TextStyle.height] is applied as normal. When set to false, the font's
  /// default ascent will be used.
  final TextHeightBehavior? textHeightBehavior;

  /// The minimum width of the text layouting.
  ///
  /// It defaults to 0.
  final double? minWidth;

  /// The maximum width of the text layouting.
  ///
  /// It defaults to [double.infinity].
  final double? maxWidth;

  final PaintStyle? backgroundStyle;
  final EdgeInsetsGeometry? backgroundPadding;
  final double? backgroundCornerRadius;

  @override
  List<Object?> get props => [
    offset,
    rotation,
    align,
    textStyle,
    span,
    textAlign,
    textDirection,
    textScaler,
    maxLines,
    ellipsis,
    locale,
    strutStyle,
    textWidthBasis,
    textHeightBehavior,
    minWidth,
    maxWidth,
    backgroundStyle,
    backgroundPadding,
    backgroundCornerRadius,
  ];
}
