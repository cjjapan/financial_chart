import 'dart:math';
import 'dart:ui';

import '../components/viewport_h.dart';
import '../components/viewport_v.dart';
import 'value.dart';

/// User defined function to convert a value to size in view [area] with [pointViewPort] and [valueViewPort].
///
/// see [GPointViewPort] and [GValueViewPort] for more details about viewports.
typedef ViewSizeConvertor =
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
  /// see [ViewSizeConvertor] for more details.
  custom,
}

/// A value defines size in view area.
///
/// see different [sizeType] defined in [GSizeValueType].
class GSize extends GValue<double> {
  final GSizeValueType sizeType;
  final ViewSizeConvertor? viewSizeConvertor;
  double get sizeValue => value;

  /// Create a size value with [size] as value in view area.
  GSize.valueSize(double size)
    : sizeType = GSizeValueType.valueSize,
      viewSizeConvertor = null,
      super(size);

  /// Create a size value with [size] as points in point viewport.
  GSize.pointSize(double size)
    : sizeType = GSizeValueType.pointSize,
      viewSizeConvertor = null,
      super(size);

  /// Create a size value with [size] as view size.
  GSize.viewSize(double size)
    : sizeType = GSizeValueType.viewSize,
      viewSizeConvertor = null,
      super(size);

  /// Create a size value with [ratio] as ratio of view height which is view height * ratio.
  GSize.viewHeightRatio(double ratio)
    : sizeType = GSizeValueType.viewHeightRatio,
      viewSizeConvertor = null,
      super(ratio);

  /// Create a size value with [ratio] as ratio of view width which is view width * ratio.
  GSize.viewWidthRatio(double ratio)
    : sizeType = GSizeValueType.viewWidthRatio,
      viewSizeConvertor = null,
      super(ratio);

  /// Create a size value with [ratio] as ratio of min of view width and height which is min(view width, view height) * ratio.
  GSize.viewMinRatio(double ratio)
    : sizeType = GSizeValueType.viewMinRatio,
      viewSizeConvertor = null,
      super(ratio);

  /// Create a size value with [ratio] as ratio of max of view width and height which is max(view width, view height) * ratio.
  GSize.viewMaxRatio(double ratio)
    : sizeType = GSizeValueType.viewMaxRatio,
      viewSizeConvertor = null,
      super(ratio);

  /// Create a size value with [sizeValue] calculated by a user defined custom function.
  GSize.custom(double sizeValue, this.viewSizeConvertor)
    : sizeType = GSizeValueType.custom,
      assert(viewSizeConvertor != null),
      super(sizeValue);

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
        return viewSizeConvertor!(
          sizeValue: sizeValue,
          area: area,
          pointViewPort: pointViewPort,
          valueViewPort: valueViewPort,
        );
    }
  }
}
