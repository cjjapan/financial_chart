import 'dart:math';
import 'dart:ui';

import '../components/viewport_h.dart';
import '../components/viewport_v.dart';
import 'value.dart';

/// User defined function to convert a value to size in view [area] with [pointViewPort] and [valueViewPort].
///
/// see [GPointViewPort] and [GValueViewPort] for more details about viewports.
typedef GViewSizeConvertor =
    double Function({
      required double sizeValue,
      required Rect area,
      required GPointViewPort pointViewPort,
      required GValueViewPort valueViewPort,
    });

/// Type of size value
enum GSizeValueType {
  /// size is points in point viewport.
  pointSize,

  /// size is value in value viewport.
  valueSize,

  /// size is view size.
  viewSize,

  /// size is ration of view height which is view height * ratio.
  viewHeightRatio,

  /// size is ration of view width which is view width * ratio.
  viewWidthRatio,

  /// size is ration of min of view width and height which is min(view width, view height) * ratio.
  viewMinRatio,

  /// size is ration of max of view width and height which is max(view width, view height) * ratio.
  viewMaxRatio,

  /// size is calculated by a user defined custom function.
  ///
  /// see [GViewSizeConvertor] for more details.
  custom,
}

/// A value defines size in view area.
///
/// see different [sizeType] defined in [GSizeValueType].
class GSize extends GValue<double> {
  /// defines the type of the value.
  final GSizeValueType sizeType;

  /// The converter function to convert a value to view size in view area.
  final GViewSizeConvertor? viewSizeConverter;

  /// The converter function to convert view size back to specified size type value.
  final GViewSizeConvertor? viewSizeConverterReverse;

  /// size value with meaning defined by [sizeType].
  double get sizeValue => value;

  /// Create a size value with [size] as value in view area.
  GSize.valueSize(super.size)
    : sizeType = GSizeValueType.valueSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [size] as points in point viewport.
  GSize.pointSize(super.size)
    : sizeType = GSizeValueType.pointSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [size] as view size.
  GSize.viewSize(super.size)
    : sizeType = GSizeValueType.viewSize,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [ratio] as ratio of view height which is view height * ratio.
  GSize.viewHeightRatio(super.ratio)
    : sizeType = GSizeValueType.viewHeightRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [ratio] as ratio of view width which is view width * ratio.
  GSize.viewWidthRatio(super.ratio)
    : sizeType = GSizeValueType.viewWidthRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [ratio] as ratio of min of view width and height which is min(view width, view height) * ratio.
  GSize.viewMinRatio(super.ratio)
    : sizeType = GSizeValueType.viewMinRatio,
      viewSizeConverter = null,
      viewSizeConverterReverse = null;

  /// Create a size value with [ratio] as ratio of max of view width and height which is max(view width, view height) * ratio.
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
