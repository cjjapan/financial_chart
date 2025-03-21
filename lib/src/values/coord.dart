import 'dart:ui';

import '../components/viewport_h.dart';
import '../components/viewport_v.dart';
import 'pair.dart';

/// base class for coordinate
abstract class GCoordinate extends GDoublePair {
  double get x => super.begin!;
  double get y => super.end!;
  GCoordinate(double x, double y) : super.pair(x, y);

  /// convert the coordinate to position in the view area
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  });
}

/// Coordinate with x and y as position in the view area.
///
/// [x] and [y] can be absolute position or ratio of the width and height of the view area.
class GPositionCoord extends GCoordinate {
  /// true if [x] is ratio of the width of the view area, false if x is absolute position
  final bool xIsRatio;

  /// true if [y] is ratio of the height of the view area, false if y is absolute position
  final bool yIsRatio;

  /// An additional x offset to the position
  ///
  /// useful when need to add some offset to the position calculated from rational position.
  final double xOffset;

  /// An additional y offset to the position
  ///
  /// useful when need to add some offset to the position calculated from rational position.
  final double yOffset;

  GPositionCoord({
    required double x,
    required double y,
    this.xIsRatio = false,
    this.yIsRatio = false,
    this.xOffset = 0,
    this.yOffset = 0,
  }) : super(x, y);

  /// create a coordinate with absolute position in the view area
  GPositionCoord.absolute({required double x, required double y})
    : this(x: x, y: y, xIsRatio: false, yIsRatio: false);

  /// create a coordinate with ratio of the width and height of the view area
  GPositionCoord.rational({
    required double x,
    required double y,
    double xOffset = 0,
    double yOffset = 0,
  }) : this(
         x: x,
         y: y,
         xOffset: xOffset,
         yOffset: yOffset,
         xIsRatio: true,
         yIsRatio: true,
       );

  /// convert the coordinate to position in the view area
  @override
  Offset toPosition({
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    return Offset(
      (xIsRatio ? (area.width * x) : x) + area.left + xOffset,
      (yIsRatio ? (area.height * y) : y) + area.top + yOffset,
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

/// Coordinate with [x] and [y] along with a user defined convertor function
///
/// convertor is function with type of [GCoordinateConvertor].
class GCustomCoord extends GCoordinate {
  final GCoordinateConvertor coordinateConvertor;
  GCustomCoord({
    required double x,
    required double y,
    required this.coordinateConvertor,
  }) : super(x, y);

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
}
