import 'dart:ui';

import '../../values/value.dart';
import '../component.dart';
import 'axis_render.dart';
import '../ticker.dart';

const defaultHAxisSize = 30.0; // in pixel
const defaultVAxisSize = 60.0; // in pixel

/// The position of the axis relative to the graph area.
enum GAxisPosition {
  /// the axis is placed besides the graph area at the start (left or top) position.
  start,

  /// the axis is placed besides the graph area at the end (right or bottom) position.
  end,

  /// the axis is placed inside the graph area at the start (left or top) position
  startInside,

  /// the axis is placed inside the graph area at the end (right or bottom) position
  endInside;

  bool get isInside =>
      this == GAxisPosition.startInside || this == GAxisPosition.endInside;
}

/// The scale mode when drags of the axis interactively.
enum GAxisScaleMode {
  /// no scale
  none,

  /// drag to zoom in/out
  zoom,

  /// drag to move the axis
  move,

  /// drag and select a portion to zoom in
  select,
}

/// The base class of the axis component.
abstract class GAxis extends GComponent {
  /// The position of the axis relative to the graph area.
  ///
  /// see [GAxisPosition] for more details.
  final GValue<GAxisPosition> _position;
  GAxisPosition get position => _position.value;
  set position(GAxisPosition value) => _position.value = value;

  /// The size of the axis in pixels.
  final GValue<double> _size;
  double get size => _size.value;
  set size(double value) => _size.value = value;

  /// The scale mode when drags the axis interactively.
  ///
  /// see [GAxisScaleMode] for more details.
  final GValue<GAxisScaleMode> _scaleMode;
  GAxisScaleMode get scaleMode => _scaleMode.value;
  set scaleMode(GAxisScaleMode value) => _scaleMode.value = value;

  GAxis({
    super.id,
    super.visible,
    required GAxisPosition position,
    required double size,
    GAxisScaleMode scaleMode = GAxisScaleMode.zoom,
    super.render,
    super.theme,
  }) : _position = GValue<GAxisPosition>(position),
       _size = GValue<double>(size),
       _scaleMode = GValue<GAxisScaleMode>(scaleMode),
       super();

  /// Place the [axes] to the given [area] and return the areas of the axes ([axesAreas]) and the area left ([areaLeft]) for graph.
  static (List<Rect> axesAreas, Rect areaLeft) placeAxes(
    Rect area,
    List<GAxis> axes,
  ) {
    List<Rect> axesAreas = [];
    Rect areaAxis = Rect.zero;
    Rect areaLeft = area;
    // place the axes
    for (int n = 0; n < axes.length; n++) {
      final axis = axes[n];
      if (axis.position == GAxisPosition.startInside ||
          axis.position == GAxisPosition.endInside) {
        axesAreas.add(Rect.zero);
        continue;
      }
      (areaAxis, areaLeft) = axis.placeTo(areaLeft);
      axesAreas.add(areaAxis);
    }
    // adjust the area of inside axes
    for (int n = 0; n < axes.length; n++) {
      final axis = axes[n];
      if (axis.position == GAxisPosition.startInside ||
          axis.position == GAxisPosition.endInside) {
        (areaAxis, areaLeft) = axis.placeTo(areaLeft);
        axesAreas[n] = areaAxis;
      }
    }
    // adjust the area of the axes to fit final graph size
    for (int n = 0; n < axes.length; n++) {
      if (axes[n] is GPointAxis) {
        axesAreas[n] = Rect.fromLTRB(
          areaLeft.left,
          axesAreas[n].top,
          areaLeft.right,
          axesAreas[n].bottom,
        );
      } else {
        axesAreas[n] = Rect.fromLTRB(
          axesAreas[n].left,
          areaLeft.top,
          axesAreas[n].right,
          areaLeft.bottom,
        );
      }
    }
    return (axesAreas, areaLeft);
  }

  (Rect used, Rect areaLeft) placeTo(Rect area);
}

/// value axis for vertical direction.
class GValueAxis extends GAxis {
  /// The view port id of the value axis.
  final String viewPortId;

  /// The strategy to calculate the value ticks.
  final GValueTickerStrategy valueTickerStrategy;

  /// The formatter to format the value.
  final String Function(double value, int precision)? valueFormatter;
  GValueAxis({
    super.id,
    required this.viewPortId,
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultVAxisSize,
    this.valueTickerStrategy = const GValueTickerStrategyDefault(),
    this.valueFormatter,
    super.theme,
    super.render = const GValueAxisRender(),
  });

  bool get isAlignRight =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;
  bool get isAlignLeft =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

  /// place the axis to the given [area] and return the areas of the axis ([areaAxis]) and the area left ([areaLeft]).
  @override
  (Rect areaAxis, Rect areaLeft) placeTo(Rect area) {
    if (position == GAxisPosition.start) {
      return (
        Rect.fromLTWH(area.left, area.top, size, area.height),
        Rect.fromLTWH(
          area.left + size,
          area.top,
          area.width - size,
          area.height,
        ),
      );
    } else if (position == GAxisPosition.end) {
      return (
        Rect.fromLTWH(area.right - size, area.top, size, area.height),
        Rect.fromLTWH(area.left, area.top, area.width - size, area.height),
      );
    } else if (position == GAxisPosition.startInside) {
      return (
        Rect.fromLTWH(area.left, area.top, size, area.height),
        area.inflate(0),
      );
    } else if (position == GAxisPosition.endInside) {
      return (
        Rect.fromLTWH(area.right - size, area.top, size, area.height),
        area.inflate(0),
      );
    } else {
      return (Rect.zero, area.inflate(0));
    }
  }
}

/// point axis for horizontal direction.
class GPointAxis extends GAxis {
  /// The strategy to calculate the point ticks.
  final GPointTickerStrategy pointTickerStrategy;

  /// The formatter to format the point value.
  final String Function(int, dynamic)? pointFormatter;
  GPointAxis({
    super.id,
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultHAxisSize,
    this.pointTickerStrategy = const GPointTickerStrategyDefault(),
    this.pointFormatter,
    super.theme,
    super.render = const GPointAxisRender(),
  });

  bool get isAlignBottom =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;
  bool get isAlignTop =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

  /// place the axis to the given [area] and return the areas of the axis ([areaAxis]) and the area left ([areaLeft]).
  @override
  (Rect areaAxis, Rect areaLeft) placeTo(Rect area) {
    if (position == GAxisPosition.start) {
      return (
        Rect.fromLTWH(area.left, area.top, area.width, size),
        Rect.fromLTWH(
          area.left,
          area.top + size,
          area.width,
          area.height - size,
        ),
      );
    } else if (position == GAxisPosition.end) {
      return (
        Rect.fromLTWH(area.left, area.bottom - size, area.width, size),
        Rect.fromLTWH(area.left, area.top, area.width, area.height - size),
      );
    } else if (position == GAxisPosition.startInside) {
      return (
        Rect.fromLTWH(area.left, area.top, area.width, size),
        area.inflate(0),
      );
    } else if (position == GAxisPosition.endInside) {
      return (
        Rect.fromLTWH(area.left, area.bottom - size, area.width, size),
        area.inflate(0),
      );
    } else {
      return (Rect.zero, area.inflate(0));
    }
  }
}
