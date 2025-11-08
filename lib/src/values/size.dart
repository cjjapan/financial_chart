import 'dart:math';
import 'dart:ui';

import '../components/viewport_h.dart';
import '../components/viewport_v.dart';
import 'value.dart';

/// Function to convert a value to size in the view area with viewports.
typedef GViewSizeConvertor =
    double Function({
      required double sizeValue,
      required Rect area,
      required GPointViewPort pointViewPort,
      required GValueViewPort valueViewPort,
    });

/// Type of size value.
enum GSizeValueType {
  /// Size in point viewport units.
  pointSize,

  /// Size in value viewport units.
  valueSize,

  /// Absolute view size.
  viewSize,

  /// Ratio of view height.
  viewHeightRatio,

  /// Ratio of view width.
  viewWidthRatio,

  /// Ratio of minimum dimension.
  viewMinRatio,

  /// Ratio of maximum dimension.
  viewMaxRatio,

  /// Custom size calculation.
  custom,
}

/// Defines size in the view area with various size types.
class GSize extends GValue<double> {
  /// The type of size value.
  final GSizeValueType sizeType;

  /// Converter to transform value to view size.
  final GViewSizeConvertor? viewSizeConverter;

  /// Reverse converter to transform view size back.
  final GViewSizeConvertor? viewSizeConverterReverse;

  /// Gets the size value.
  double get sizeValue => value;

  /// Creates a size in value viewport units.
  GSize.valueSize(super.size)
    : sizeType = GSizeValueType.valueSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size in point viewport units.
  GSize.pointSize(super.size)
    : sizeType = GSizeValueType.pointSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates an absolute view size.
  GSize.viewSize(super.size)
    : sizeType = GSizeValueType.viewSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size as a ratio of view height.
  GSize.viewHeightRatio(super.ratio)
    : sizeType = GSizeValueType.viewHeightRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size as a ratio of view width.
  GSize.viewWidthRatio(super.ratio)
    : sizeType = GSizeValueType.viewWidthRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size as a ratio of minimum dimension.
  GSize.viewMinRatio(super.ratio)
    : sizeType = GSizeValueType.viewMinRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size as a ratio of maximum dimension.
  GSize.viewMaxRatio(super.ratio)
    : sizeType = GSizeValueType.viewMaxRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Creates a size with custom conversion logic.
  GSize.viewMaxRatio(super.ratio)
    : sizeType = GSizeValueType.viewMaxRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [sizeValue] calculated by a user defined custom function.
  GSize.custom(
    super.sizeValue,
    this.viewSizeConverter,
    this.viewSizeConverterReverse,
  ) : sizeType = GSizeValueType.custom,
      assert(
        viewSizeConverter != null && viewSizeConverterReverse != null,
        'viewSizeConverter and viewSizeConverterReverse must not be null for custom size type.',
      );

  /// Convert the size value to view size.
  double toViewSize({
    required Rect area,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    switch (sizeType) {
      case GSizeValueType.viewSize:
        return sizeValue;
      case GSizeValueType.valueSize:
        return valueViewPort.valueToSize(area.height, sizeValue);
      case GSizeValueType.pointSize:
        return pointViewPort.pointToSize(area.width, sizeValue);
      case GSizeValueType.viewHeightRatio:
        return area.height * sizeValue;
      case GSizeValueType.viewWidthRatio:
        return area.width * sizeValue;
      case GSizeValueType.viewMinRatio:
        return min(area.width, area.height) * sizeValue;
      case GSizeValueType.viewMaxRatio:
        return max(area.width, area.height) * sizeValue;
      case GSizeValueType.custom:
        return viewSizeConverter!(
          sizeValue: sizeValue,
          area: area,
          pointViewPort: pointViewPort,
          valueViewPort: valueViewPort,
        );
    }
  }

  GSize copyFromViewSize({
    required double viewSize,
    required Rect area,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    switch (sizeType) {
      case GSizeValueType.viewSize:
        return GSize.viewSize(viewSize);
      case GSizeValueType.valueSize:
        return GSize.valueSize(
          valueViewPort.sizeToValue(area.height, viewSize),
        );
      case GSizeValueType.pointSize:
        return GSize.pointSize(pointViewPort.sizeToPoint(area.width, viewSize));
      case GSizeValueType.viewHeightRatio:
        return GSize.viewHeightRatio(viewSize / area.height);
      case GSizeValueType.viewWidthRatio:
        return GSize.viewWidthRatio(viewSize / area.width);
      case GSizeValueType.viewMinRatio:
        return GSize.viewMinRatio(viewSize / min(area.width, area.height));
      case GSizeValueType.viewMaxRatio:
        return GSize.viewMaxRatio(viewSize / max(area.width, area.height));
      case GSizeValueType.custom:
        return GSize.custom(
          viewSizeConverterReverse!(
            sizeValue: viewSize,
            area: area,
            pointViewPort: pointViewPort,
            valueViewPort: valueViewPort,
          ),
          viewSizeConverterReverse!,
          viewSizeConverter!,
        );
    }
  }
}
