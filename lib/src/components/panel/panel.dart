import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../components.dart';
import '../../values/coord.dart';
import '../../values/value.dart';
import '../../data/data_source.dart';

/// Pan mode for the graph area of a panel.
enum GGraphPanMode {
  /// Pan interaction disabled.
  none,

  /// Pan the graph area.
  auto,
}

/// Panel component containing axes, graphs, and viewports.
class GPanel extends GComponent {
  /// Value viewports for this panel.
  final List<GValueViewPort> valueViewPorts;

  /// Point axes in this panel.
  final List<GPointAxis> pointAxes;

  /// Value axes in this panel.
  final List<GValueAxis> valueAxes;

  /// Graphs displayed in this panel.
  final List<GGraph> graphs;

  /// Tooltip for this panel.
  final GTooltip? tooltip;

  final GValue<bool> _resizable = GValue(true);

  /// Gets whether this panel is resizable.
  bool get resizable => _resizable.value && visible;

  /// Sets whether this panel is resizable.
  set resizable(bool value) => _resizable.value = value;

  final GValue<double> _heightWeight = GValue(1.0);

  /// Gets the height weight for this panel.
  double get heightWeight => _heightWeight.value;

  /// Sets the height weight for this panel.
  set heightWeight(double value) => _heightWeight.value = value;

  final GValue<double> _momentumScrollSpeed = GValue(0.5);

  /// Gets the momentum scrolling speed (0 to 1).
  double get momentumScrollSpeed => _momentumScrollSpeed.value;

  /// Sets the momentum scrolling speed (0 to 1).
  set momentumScrollSpeed(double value) =>
      _momentumScrollSpeed.value = min(max(value, 0), 1.0);

  final GValue<GGraphPanMode> _graphPanMode = GValue(GGraphPanMode.auto);

  /// Gets the pan mode for the graph area.
  GGraphPanMode get graphPanMode => _graphPanMode.value;

  /// Sets the pan mode for the graph area.
  set graphPanMode(GGraphPanMode value) => _graphPanMode.value = value;

  @override
  bool get visible => super.visible && heightWeight > 0;

  final List<Rect> _areas = [];

  /// Height of the splitter handle in pixels.
  final double splitterHeight;

  /// Returns true if layout calculations are complete.
  bool get isLayoutReady => _areas.isNotEmpty;

  /// Gets the render area for a point axis by index.
  Rect pointAxisArea(int index) => _areas[index];

  /// Gets the render area for a specific point axis.
  Rect pointAxisAreaOf(GPointAxis axis) => _areas[pointAxes.indexOf(axis)];

  /// Gets the render area for a value axis by index.
  Rect valueAxisArea(int index) => _areas[pointAxes.length + index];

  /// Gets the render area for a specific value axis.
  Rect valueAxisAreaOf(GValueAxis axis) =>
      _areas[pointAxes.length + valueAxes.indexOf(axis)];

  /// Gets the render area for all graphs.
  Rect graphArea() => _areas[pointAxes.length + valueAxes.length];

  /// Gets the render area for the entire panel.
  Rect panelArea() => _areas[_areas.length - 2];

  /// Gets the render area for the splitter handle.
  Rect splitterArea() => _areas.last;

  /// Gets the last graph in the list (active graph).
  GGraph get activeGraph => graphs.last;

  final GValue<Function(Offset)?> _onTapGraphArea = GValue(null);

  /// Gets the callback for tap events on the graph area.
  Function(Offset)? get onTapGraphArea => _onTapGraphArea.value;

  /// Sets the callback for tap events on the graph area.
  set onTapGraphArea(Function(Offset)? value) => _onTapGraphArea.value = value;

  final GValue<Function(Offset)?> _onSecondaryTapGraphArea = GValue(null);

  /// Gets the callback for secondary tap events on the graph area.
  Function(Offset)? get onSecondaryTapGraphArea =>
      _onSecondaryTapGraphArea.value;

  /// Sets the callback for secondary tap events on the graph area.
  set onSecondaryTapGraphArea(Function(Offset)? value) =>
      _onSecondaryTapGraphArea.value = value;

  final GValue<Function(Offset)?> _onDoubleTapGraphArea = GValue(null);

  /// Gets the callback for double tap events on the graph area.
  Function(Offset)? get onDoubleTapGraphArea => _onDoubleTapGraphArea.value;

  /// Sets the callback for double tap events on the graph area.
  set onDoubleTapGraphArea(Function(Offset)? value) =>
      _onDoubleTapGraphArea.value = value;

  final GValue<Function(Offset)?> _onLongPressStartGraphArea = GValue(null);

  /// Gets the callback for long press start events on the graph area.
  Function(Offset)? get onLongPressStartGraphArea =>
      _onLongPressStartGraphArea.value;

  /// Sets the callback for long press start events on the graph area.
  set onLongPressStartGraphArea(Function(Offset)? value) =>
      _onLongPressStartGraphArea.value = value;

  final GValue<Function(Offset)?> _onLongPressEndGraphArea = GValue(null);

  /// Gets the callback for long press end events on the graph area.
  Function(Offset)? get onLongPressEndGraphArea =>
      _onLongPressEndGraphArea.value;

  /// Sets the callback for long press end events on the graph area.
  set onLongPressEndGraphArea(Function(Offset)? value) =>
      _onLongPressEndGraphArea.value = value;

  final GValue<Function(Offset)?> _onLongPressMoveGraphArea = GValue(null);

  /// Gets the callback for long press move events on the graph area.
  Function(Offset)? get onLongPressMoveGraphArea =>
      _onLongPressMoveGraphArea.value;

  /// Sets the callback for long press move events on the graph area.
  set onLongPressMoveGraphArea(Function(Offset)? value) =>
      _onLongPressMoveGraphArea.value = value;

  /// Creates a panel.
  GPanel({
    super.id,
    required this.pointAxes,
    required this.valueAxes,
    required this.valueViewPorts,
    required this.graphs,
    this.tooltip,
    double heightWeight = 1.0,
    bool resizable = true,
    GGraphPanMode graphPanMode = GGraphPanMode.auto,
    this.splitterHeight = 16.0,
    double momentumScrollSpeed = 0.5,
    Function(Offset)? onTapGraphArea,
    Function(Offset)? onDoubleTapGraphArea,
    Function(Offset)? onSecondaryTapGraphArea,
    Function(Offset)? onLongPressDownGraphArea,
    Function(Offset)? onLongPressUpGraphArea,
    Function(Offset)? onLongPressMoveGraphArea,
    GPanelTheme? theme,
    GPanelRender? render,
  }) : super(render: render ?? const GPanelRender(), theme: theme) {
    assert(heightWeight >= 0);
    _heightWeight.value = heightWeight;
    _resizable.value = resizable;
    _momentumScrollSpeed.value = min(max(momentumScrollSpeed, 0), 1.0);
    _graphPanMode.value = graphPanMode;
    _onTapGraphArea.value = onTapGraphArea;
    _onDoubleTapGraphArea.value = onDoubleTapGraphArea;
    _onSecondaryTapGraphArea.value = onSecondaryTapGraphArea;
    _onLongPressStartGraphArea.value = onLongPressDownGraphArea;
    _onLongPressEndGraphArea.value = onLongPressUpGraphArea;
    _onLongPressMoveGraphArea.value = onLongPressMoveGraphArea;
    // at least one value viewport is required
    assert(valueViewPorts.isNotEmpty);
    // no duplicate id for value viewport
    assert(
      valueViewPorts.map((e) => e.id).toSet().length == valueViewPorts.length,
      "Duplicate id for value viewport is not allowed.",
    );
    // only one value viewport with empty id is allowed
  }

  void layout(Rect panelArea, bool hasSplitter) {
    _areas.clear();
    final (axesAreas, graphArea) = GAxis.placeAxes(panelArea, [
      ...pointAxes,
      ...valueAxes,
    ]);
    final splitterArea = hasSplitter
        ? Rect.fromCenter(
            center: panelArea.bottomCenter,
            width: panelArea.width,
            height: splitterHeight,
          )
        : Rect.zero;
    _areas
      ..addAll(axesAreas)
      ..add(graphArea)
      ..add(panelArea)
      ..add(splitterArea);
  }

  GValueViewPort findValueViewPortById(String id) {
    final found = valueViewPorts
        .where((element) => element.id == id)
        .firstOrNull;
    if (found == null) {
      throw Exception(
        "Value viewport with id $id not found. Available ids: ${valueViewPorts.map((e) => e.id).toList()}",
      );
    }
    return found;
  }

  GViewPortCoord? positionToViewPortCoord({
    required Offset position,
    required GPointViewPort pointViewPort,
    String valueViewPortId = "",
  }) {
    if (!graphArea().contains(position)) {
      return null;
    }
    final valueViewPort = valueViewPorts
        .where((element) => element.id == valueViewPortId)
        .firstOrNull;
    if (valueViewPort == null) {
      return null;
    }
    return GViewPortCoord(
      point: pointViewPort.positionToPoint(graphArea(), position.dx),
      value: valueViewPort.positionToValue(graphArea(), position.dy),
    );
  }

  GGraph? findGraphById(String id) {
    return graphs.where((element) => element.id == id).firstOrNull;
  }

  (GGraph?, GOverlayMarker? marker) hitTestGraphs({required Offset position}) {
    if (!graphArea().contains(position)) {
      return (null, null);
    }
    for (int g = graphs.length - 1; g > 0; g--) {
      GGraph graph = graphs[g];
      if (graph.visible) {
        GOverlayMarker? marker = graph.hitTestOverlayMarkers(
          position: position,
        );
        if (marker != null) {
          return (graph, marker);
        }
        if (graph.getRender().hitTest(position: position)) {
          return (graph, null);
        }
      }
    }
    return (null, null);
  }

  /// Find the closest data point in the graph area of this panel.
  /// Returns the closest point and the key of the data value.
  /// If no data point is found, returns null.
  (int, String)? closestDataPoint({
    required Offset position,
    required GDataSource dataSource,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
    required List<String> dataKeysToSearch,
  }) {
    if (!graphArea().contains(position)) {
      return null;
    }
    final closestPoint = pointViewPort
        .positionToPoint(graphArea(), position.dx)
        .round();
    final value = valueViewPort.positionToValue(graphArea(), position.dy);
    final data = dataSource.getData(closestPoint);
    if (data == null) {
      return null;
    }
    String? closestKey;
    double closestDistance = double.infinity;

    for (final key in dataKeysToSearch) {
      final dataValue = dataSource.getSeriesValue(
        point: closestPoint,
        key: key,
      );
      if (dataValue != null) {
        final distance = (dataValue - value).abs();
        if (distance < closestDistance) {
          closestKey = key;
          closestDistance = distance;
        }
      }
    }

    return closestKey != null ? (closestPoint, closestKey) : null;
  }

  void dispose() {
    for (final valueViewPort in valueViewPorts) {
      valueViewPort.dispose();
    }
    tooltip?.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<List<GValueViewPort>>(
        'valueViewPorts',
        valueViewPorts,
      ),
    );
    properties.add(
      DiagnosticsProperty<List<GPointAxis>>('pointAxes', pointAxes),
    );
    properties.add(
      DiagnosticsProperty<List<GValueAxis>>('valueAxes', valueAxes),
    );
    properties.add(DiagnosticsProperty<List<GGraph>>('graphs', graphs));
    properties.add(DiagnosticsProperty<GTooltip>('tooltip', tooltip));
    properties.add(DiagnosticsProperty<bool>('resizable', resizable));
    properties.add(DoubleProperty('heightWeight', heightWeight));
    properties.add(DoubleProperty('momentumScrollSpeed', momentumScrollSpeed));
    properties.add(EnumProperty<GGraphPanMode>('graphPanMode', graphPanMode));
    properties.add(
      DiagnosticsProperty<bool>('onTapGraphArea', onTapGraphArea != null),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'onDoubleTapGraphArea',
        onDoubleTapGraphArea != null,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'onLongPressDownGraphArea',
        onLongPressStartGraphArea != null,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'onLongPressUpGraphArea',
        onLongPressEndGraphArea != null,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        'onLongPressMoveGraphArea',
        onLongPressMoveGraphArea != null,
      ),
    );
    properties.add(
      DiagnosticsProperty<double>('splitterHeight', splitterHeight),
    );
    properties.add(DiagnosticsProperty<bool>('isLayoutReady', isLayoutReady));
    if (isLayoutReady) {
      properties.add(DiagnosticsProperty<Rect>('graphArea', graphArea()));
      properties.add(DiagnosticsProperty<Rect>('panelArea', panelArea()));
      properties.add(DiagnosticsProperty<Rect>('splitterArea', splitterArea()));
      properties.add(
        IterableProperty<Rect>(
          'pointAxisAreas',
          pointAxes.map((a) => pointAxisAreaOf(a)).toList(),
        ),
      );
      properties.add(
        IterableProperty<Rect>(
          'valueAxisAreas',
          valueAxes.map((a) => valueAxisAreaOf(a)).toList(),
        ),
      );
    }
  }
}
