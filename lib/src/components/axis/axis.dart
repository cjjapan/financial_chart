import 'dart:ui';

import 'package:financial_chart/src/components/marker/axis_marker.dart';
import 'package:flutter/foundation.dart';

import '../../values/value.dart';
import '../component.dart';
import '../marker/overlay_marker.dart';
import 'axis_render.dart';
import '../ticker.dart';

/// Default horizontal axis size in pixels.
const defaultHAxisSize = 30.0;

/// Default vertical axis size in pixels.
const defaultVAxisSize = 60.0;

/// Position of an axis relative to the graph area.
enum GAxisPosition {
  /// Axis is placed outside the graph area at the start (left or top).
  start,

  /// Axis is placed outside the graph area at the end (right or bottom).
  end,

  /// Axis is placed inside the graph area at the start (left or top).
  startInside,

  /// Axis is placed inside the graph area at the end (right or bottom).
  endInside;

  /// Returns true if this position is inside the graph area.
  bool get isInside =>
      this == GAxisPosition.startInside || this == GAxisPosition.endInside;
}

/// Scale mode for interactive axis dragging.
enum GAxisScaleMode {
  /// No scaling allowed.
  none,

  /// Drag to zoom in or out.
  zoom,

  /// Drag to pan the axis.
  move,

  /// Drag to select a portion to zoom in.
  select,
}

/// Base class for axis components.
abstract class GAxis extends GComponent {
  final GValue<GAxisPosition> _position;

  /// Gets the position of this axis relative to the graph area.
  GAxisPosition get position => _position.value;

  /// Sets the position of this axis relative to the graph area.
  set position(GAxisPosition value) => _position.value = value;

  final GValue<double> _size;

  /// Gets the size of this axis in pixels.
  double get size => _size.value;

  /// Sets the size of this axis in pixels.
  set size(double value) => _size.value = value;

  final GValue<GAxisScaleMode> _scaleMode;

  /// Gets the scale mode for interactive axis dragging.
  GAxisScaleMode get scaleMode => _scaleMode.value;

  /// Sets the scale mode for interactive axis dragging.
  set scaleMode(GAxisScaleMode value) => _scaleMode.value = value;

  /// Markers displayed on this axis.
  final List<GAxisMarker> axisMarkers = [];

  /// Overlay markers displayed on this axis.
  final List<GOverlayMarker> overlayMarkers = [];

  /// Creates an axis.
  GAxis({
    super.id,
    super.visible,
    required GAxisPosition position,
    required double size,
    GAxisScaleMode scaleMode = GAxisScaleMode.zoom,
    super.render,
    super.theme,
    List<GAxisMarker> axisMarkers = const [],
    List<GOverlayMarker> overlayMarkers = const [],
  }) : _position = GValue<GAxisPosition>(position),
       _size = GValue<double>(size),
       _scaleMode = GValue<GAxisScaleMode>(scaleMode),
       super() {
    if (axisMarkers.isNotEmpty) {
      this.axisMarkers.addAll(axisMarkers);
    }
    if (overlayMarkers.isNotEmpty) {
      this.overlayMarkers.addAll(overlayMarkers);
    }
  }

  /// Places multiple axes within a given area and returns their rectangles and remaining space.
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

  /// Places this axis within the given area and returns the axis rectangle and remaining space.
  (Rect used, Rect areaLeft) placeTo(Rect area);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GAxisPosition>('position', position));
    properties.add(DoubleProperty('size', size));
    properties.add(EnumProperty<GAxisScaleMode>('scaleMode', scaleMode));
  }
}

/// Value axis for displaying vertical numerical values.
class GValueAxis extends GAxis {
  /// The viewport ID this axis is associated with.
  final String viewPortId;

  /// Strategy for calculating value ticks.
  final GValueTickerStrategy valueTickerStrategy;

  /// Formatter for displaying value labels.
  final String Function(double value, int precision)? valueFormatter;

  /// Creates a value axis.
  GValueAxis({
    super.id,
    this.viewPortId = "", // empty means the default view port id
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultVAxisSize,
    this.valueTickerStrategy = const GValueTickerStrategyDefault(),
    this.valueFormatter,
    List<GValueAxisMarker> axisMarkers = const [],
    super.overlayMarkers,
    super.theme,
    super.render = const GValueAxisRender(),
  }) : super(axisMarkers: axisMarkers);

  /// Returns true if labels should align to the right.
  bool get isAlignRight =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;

  /// Returns true if labels should align to the left.
  bool get isAlignLeft =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('viewPortId', viewPortId));
  }
}

/// Point axis for displaying horizontal data point labels.
class GPointAxis extends GAxis {
  /// Strategy for calculating point ticks.
  final GPointTickerStrategy pointTickerStrategy;

  /// Formatter for displaying point labels.
  final String Function(int, dynamic)? pointFormatter;

  /// Creates a point axis.
  GPointAxis({
    super.id,
    super.position = GAxisPosition.end,
    super.scaleMode = GAxisScaleMode.zoom,
    super.size = defaultHAxisSize,
    super.overlayMarkers,
    List<GPointAxisMarker> axisMarkers = const [],
    this.pointTickerStrategy = const GPointTickerStrategyDefault(),
    this.pointFormatter,
    super.theme,
    super.render = const GPointAxisRender(),
  }) : super(axisMarkers: axisMarkers);

  /// Returns true if labels should align to the bottom.
  bool get isAlignBottom =>
      position == GAxisPosition.start || position == GAxisPosition.endInside;

  /// Returns true if labels should align to the top.
  bool get isAlignTop =>
      position == GAxisPosition.end || position == GAxisPosition.startInside;

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
