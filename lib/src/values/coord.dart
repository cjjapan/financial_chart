import 'dart:ui';

import '../components/viewport_h.dart';
import '../components/viewport_v.dart';
import 'pair.dart';

/// Base class for chart coordinates.
abstract class GCoordinate extends GDoublePair {
  /// Gets the x coordinate value.
  double get x => super.begin!;

  /// Gets the y coordinate value.
  double get y => super.end!;

  /// Creates a coordinate with x and y values.
  GCoordinate(super.x, super.y) : super.pair();

  /// Converts the coordinate to a position in the view area.
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  });

  /// Creates a new coordinate from a position.
  GCoordinate copyByPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  });
}

/// Coordinate with x and y as positions or ratios in the view area.
class GPositionCoord extends GCoordinate {
  /// Whether x is a ratio of view width.
  final bool xIsRatio;

  /// Whether y is a ratio of view height.
  final bool yIsRatio;

  /// Additional x offset from the calculated position.
  final double xOffset;

  /// Additional y offset from the calculated position.
  final double yOffset;

  /// Whether x offset is relative to the right side.
  final bool xIsInverted;

  /// Whether y offset is relative to the bottom side.
  final bool yIsInverted;

  /// Creates a position coordinate.
  GPositionCoord({
    required double x,
    required double y,
    this.xIsRatio = false,
    this.yIsRatio = false,
    this.xOffset = 0,
    this.yOffset = 0,
    this.xIsInverted = false,
    this.yIsInverted = false,
  }) : super(x, y);

  /// Creates a copy with specified changes.
  GPositionCoord copyWith({
    double? x,
    double? y,
    double? xOffset,
    double? yOffset,
    bool? xIsInverted,
    bool? yIsInverted,
  }) {
    return GPositionCoord(
      x: x ?? this.x,
      y: y ?? this.y,
      xIsRatio: xIsRatio,
      yIsRatio: yIsRatio,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
      xIsInverted: xIsInverted ?? this.xIsInverted,
      yIsInverted: yIsInverted ?? this.yIsInverted,
    );
  }

  /// Creates a coordinate with absolute position.
  GPositionCoord.absolute({
    required double x,
    required double y,
    bool xIsInverted = false,
    bool yIsInverted = false,
  }) : this(
         x: x,
         y: y,
         xIsRatio: false,
         yIsRatio: false,
         xIsInverted: xIsInverted,
         yIsInverted: yIsInverted,
       );

  /// create a coordinate with ratio of the width and height of the view area
  GPositionCoord.rational({
    required double x,
    required double y,
    double xOffset = 0,
    double yOffset = 0,
    bool xIsInverted = false,
    bool yIsInverted = false,
  }) : this(
         x: x,
         y: y,
         xOffset: xOffset,
         yOffset: yOffset,
         xIsRatio: true,
         yIsRatio: true,
         xIsInverted: xIsInverted,
         yIsInverted: yIsInverted,
       );

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return Offset(
      xIsInverted
          ? (area.right - (xIsRatio ? (area.width * x) : x) - xOffset)
          : (xIsRatio ? (area.width * x) : x) + area.left + xOffset,
      yIsInverted
          ? (area.bottom - (yIsRatio ? (area.height * y) : y) - yOffset)
          : (yIsRatio ? (area.height * y) : y) + area.top + yOffset,
    );
  }

  @override
  GCoordinate copyByPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    double newX = xIsInverted
        ? (position.dx + xOffset)
        : (position.dx - xOffset);
    double newY = yIsInverted
        ? (position.dy + yOffset)
        : (position.dy - yOffset);
    if (xIsRatio) {
      newX /= area.width;
    }
    if (xIsInverted) {
      newX = area.right - newX;
    } else {
      newX -= area.left;
    }
    if (yIsRatio) {
      newY /= area.height;
    }
    if (yIsInverted) {
      newY = area.bottom - newY;
    } else {
      newY -= area.top;
    }
    return GPositionCoord(
      x: newX,
      y: newY,
      xIsRatio: xIsRatio,
      yIsRatio: yIsRatio,
      xOffset: xOffset,
      yOffset: yOffset,
      xIsInverted: xIsInverted,
      yIsInverted: yIsInverted,
    );
  }
}

/// Coordinate with x as point in the point view port and y as value in the value view port.
///
/// see [GPointViewPort] and [GValueViewPort] for details of viewports.
class GViewPortCoord extends GCoordinate {
  double get point => super.begin!;
  double get value => super.end!;

  GViewPortCoord({required double point, required double value})
    : super(point, value);

  /// create a copy of this coordinate with some changes
  GViewPortCoord copyWith({double? point, double? value}) {
    return GViewPortCoord(
      point: point ?? this.point,
      value: value ?? this.value,
    );
  }

  /// create a coordinate from position in the view area
  GViewPortCoord.fromPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) : this(
         point: pointViewPort.positionToPoint(area, position.dx),
         value: valueViewPort.positionToValue(area, position.dy),
       );

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return Offset(
      pointViewPort.pointToPosition(area, point),
      valueViewPort.valueToPosition(area, value),
    );
  }

  @override
  GCoordinate copyByPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    double newPoint = pointViewPort.positionToPoint(area, position.dx);
    double newValue = valueViewPort.positionToValue(area, position.dy);
    return GViewPortCoord(point: newPoint, value: newValue);
  }
}

/// User defined function to convert a value pair ([x], [y]) to position in the view area
typedef GCoordinateConvertor =
    Offset Function({
      required double x,
      required double y,
      required Rect area,
      required GPointViewPort pointViewPort,
      required GValueViewPort valueViewPort,
    });

typedef GCoordinateReverseConvertor =
    GCoordinate Function({
      required double x,
      required double y,
      required Rect area,
      required Offset position,
      required GPointViewPort pointViewPort,
      required GValueViewPort valueViewPort,
    });

/// predefined [GCoordinateConvertor] to convert [x] in position and [y] in viewport to position in the view area.
Offset kCoordinateConvertorXPositionYValue({
  required double x,
  required double y,
  required Rect area,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  return Offset(
    (area.width * x) + area.left,
    valueViewPort.valueToPosition(area, y),
  );
}

GCoordinate kCoordinateConvertorXPositionYValueReverse({
  required double x,
  required double y,
  required Rect area,
  required Offset position,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  double newX = (position.dx - area.left) / area.width;
  double newY = valueViewPort.positionToValue(area, position.dy);
  return GCustomCoord(
    x: newX,
    y: newY,
    coordinateConvertor: kCoordinateConvertorXPositionYValue,
    coordinateConvertorReverse: kCoordinateConvertorXPositionYValueReverse,
  );
}

/// predefined [GCoordinateConvertor] to convert [x] in viewport and [y] in position to position in the view area.
Offset kCoordinateConvertorXPointYPosition({
  required double x,
  required double y,
  required Rect area,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  return Offset(
    pointViewPort.pointToPosition(area, x),
    (area.height * y) + area.top,
  );
}

GCoordinate kCoordinateConvertorXPointYPositionReverse({
  required double x,
  required double y,
  required Rect area,
  required Offset position,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  double newX = pointViewPort.positionToPoint(area, position.dx);
  double newY = (position.dy - area.top) / area.height;
  return GCustomCoord(
    x: newX,
    y: newY,
    coordinateConvertor: kCoordinateConvertorXPointYPosition,
    coordinateConvertorReverse: kCoordinateConvertorXPointYPositionReverse,
  );
}

/// Coordinate with [x] and [y] along with a user defined convertor functions.
///
/// convertor is function with type of [GCoordinateConvertor].
class GCustomCoord extends GCoordinate {
  final GCoordinateConvertor coordinateConvertor;
  final GCoordinateReverseConvertor coordinateConvertorReverse;
  GCustomCoord({
    required double x,
    required double y,
    required this.coordinateConvertor,
    required this.coordinateConvertorReverse,
  }) : super(x, y);

  /// create a copy of this coordinate with some changes
  GCustomCoord copyWith({
    double? x,
    double? y,
    GCoordinateConvertor? coordinateConvertor,
    GCoordinateReverseConvertor? reverseConvertor,
  }) {
    return GCustomCoord(
      x: x ?? this.x,
      y: y ?? this.y,
      coordinateConvertor: coordinateConvertor ?? this.coordinateConvertor,
      coordinateConvertorReverse:
          reverseConvertor ?? coordinateConvertorReverse,
    );
  }

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return coordinateConvertor(
      x: x,
      y: y,
      area: area,
      pointViewPort: pointViewPort,
      valueViewPort: valueViewPort,
    );
  }

  @override
  GCoordinate copyByPosition({
    required Rect area,
    required Offset position,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return coordinateConvertorReverse(
      x: x,
      y: y,
      area: area,
      position: position,
      pointViewPort: pointViewPort,
      valueViewPort: valueViewPort,
    );
  }
}
