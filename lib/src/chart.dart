import 'dart:async';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'chart_interaction.dart';
import 'chart_render.dart';
import 'components/components.dart';
import 'data/data_source.dart';
import 'theme/theme.dart';
import 'values/value.dart';

/// Helper class for debouncing actions.
class DebounceHelper {
  /// Delay in milliseconds before executing the action.
  final int milliseconds;
  Timer? _timer;

  /// Creates a debounce helper with the specified delay.
  DebounceHelper({required this.milliseconds});

  /// Runs the action after the debounce delay.
  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

/// Action mode for pointer scroll event (mouse wheel scrolling).
enum GPointerScrollMode {
  /// no action
  none,

  /// zoom the point viewport
  zoom,

  /// move the point viewport
  move,
}

/// Chart model that manages data, components, and interactions.
class GChart extends ChangeNotifier with Diagnosticable {
  /// The data source providing chart data.
  final GDataSource dataSource;

  /// The shared point viewport for all components in the panel.
  final GPointViewPort pointViewPort;

  final GValue<GPointerScrollMode> _pointerScrollMode;

  /// Sets the action mode for pointer scroll events.
  set pointerScrollMode(GPointerScrollMode value) {
    _pointerScrollMode.value = value;
    _notify();
  }

  /// Gets the action mode for pointer scroll events.
  GPointerScrollMode get pointerScrollMode => _pointerScrollMode.value;

  /// The background component for the chart.
  final GBackground background;

  /// The panel components drawn from top to bottom.
  final List<GPanel> panels;

  /// The splitter component for resizing between panels.
  final GSplitter splitter;

  /// The crosshair component displaying pointer position and lines.
  final GCrosshair crosshair;

  final GValue<GTheme> _theme;

  /// Gets the current theme of the chart.
  GTheme get theme => _theme.value;

  /// Sets the theme for the chart.
  set theme(GTheme value) {
    _theme.value = value;
    _notify();
  }

  /// The renderer for the chart.
  final GChartRender render;

  final GValue<Rect> _area;

  /// Gets the current view area of the chart.
  Rect get area => _area.value;

  /// Gets the current view size of the chart.
  Size get size => area.size;

  /// Painting counter for debugging purposes.
  final GValue<int> _paintCount = GValue(0);

  /// The minimum allowed view size of the chart.
  final Size minSize;

  /// Callback invoked before rendering to allow chart updates.
  /// Avoid updates that trigger repaints.
  final void Function(GChart chart, Canvas canvas, Rect area)? preRender;

  /// Callback invoked after rendering to allow additional drawing.
  /// Avoid updates that trigger repaints.
  final void Function(GChart chart, Canvas canvas, Rect area)? postRender;

  /// The current mouse cursor style.
  final GValue<MouseCursor> mouseCursor = GValue<MouseCursor>(
    SystemMouseCursors.basic,
  );

  final GValue<bool> _hitTestEnable;

  /// Gets whether hit testing is enabled.
  bool get hitTestEnable => _hitTestEnable.value;

  /// Sets whether hit testing is enabled.
  set hitTestEnable(bool value) {
    _hitTestEnable.value = value;
    _notify();
  }

  final _debounceHelper = DebounceHelper(milliseconds: 500);

  bool _initialized = false;

  /// Gets whether the chart has been initialized.
  bool get initialized => _initialized;
  TickerProvider? _tickerProvider;

  GChartInteractionHandler? _interactionHandler;

  /// Gets whether the viewport is currently being scaled.
  bool get isScaling => _interactionHandler?.isScalingViewPort == true;

  /// Whether to print debug paint count information.
  final bool printDebugPaintCount;

  /// Creates a chart with the specified configuration.
  GChart({
    required this.dataSource,
    required this.panels,
    required GTheme theme,
    this.render = const GChartRender(),
    GPointViewPort? pointViewPort,
    GBackground? background,
    GSplitter? splitter,
    GCrosshair? crosshair,
    GPointerScrollMode pointerScrollMode = GPointerScrollMode.zoom,
    Rect area = const Rect.fromLTWH(0, 0, 500, 500),
    this.minSize = const Size(200, 200),
    this.preRender,
    this.postRender,
    bool hitTestEnable = true,
    this.printDebugPaintCount = false,
  }) : background = (background ?? GBackground()),
       crosshair = (crosshair ?? GCrosshair()),
       splitter = (splitter ?? GSplitter()),
       _pointerScrollMode = GValue(pointerScrollMode),
       pointViewPort =
           pointViewPort ??
           GPointViewPort(
             autoScaleStrategy: const GPointViewPortAutoScaleStrategyLatest(),
           ),
       _theme = GValue(theme),
       _area = GValue(area),
       _hitTestEnable = GValue(hitTestEnable);

  /// Initializes the chart internals.
  /// Should be called only once by [GChartWidget].
  void internalInitialize({
    TickerProvider? vsync,
    required GChartInteractionHandler interactionHandler,
  }) {
    assert(!_initialized, 'Chart is already initialized');
    _tickerProvider = vsync;
    _initialized = true;
    _interactionHandler = interactionHandler;
    dataSource.addListener(_notify);
    if (vsync != null) {
      pointViewPort.initializeAnimation(vsync);
    }
    pointViewPort.addListener(_pointViewPortChanged);
    for (final panel in panels) {
      for (final valueViewPort in panel.valueViewPorts) {
        valueViewPort.addListener(
          () => _valueViewPortChanged(updatedViewPort: valueViewPort),
        );
        if (vsync != null) {
          valueViewPort.initializeAnimation(vsync);
        }
      }
    }
  }

  /// Adds a new panel to the chart.
  void addPanel(GPanel panel) {
    panels.add(panel);
    for (final valueViewPort in panel.valueViewPorts) {
      valueViewPort.addListener(
        () => _valueViewPortChanged(updatedViewPort: valueViewPort),
      );
      if (_tickerProvider != null) {
        valueViewPort.initializeAnimation(_tickerProvider!);
      }
    }
    resize(newArea: area, force: true);
    autoScaleViewports();
  }

  /// Removes a panel from the chart.
  void removePanel(GPanel panel) {
    panels.remove(panel);
    resize(newArea: area, force: true);
  }

  /// Loads initial data when the data source is empty.
  /// Should be called only once after chart widget initialization.
  void ensureInitialData() {
    assert(!dataSource.isLoading);
    layout(area);
    final fromPoint = pointViewPort.isValid
        ? pointViewPort.startPoint.floor()
        : dataSource.indexToPoint(0);
    final points =
        panels[0].graphArea().width / pointViewPort.defaultPointWidth;
    final toPoint = pointViewPort.isValid
        ? pointViewPort.endPoint.ceil()
        : ((fromPoint + points).ceil() + 10);
    dataSource.ensureData(fromPoint: fromPoint, toPoint: toPoint).then((_) {
      if (!pointViewPort.isValid) {
        // if not being set with initial value, set it with the auto scaled value.
        if (pointViewPort.autoScaleStrategy != null) {
          pointViewPort.autoScaleReset(
            chart: this,
            panel: panels[0],
            finished: true,
            animation: false,
          );
        } else {
          pointViewPort.setRange(
            startPoint: dataSource.lastPoint - points,
            endPoint: dataSource.lastPoint.toDouble(),
            finished: true,
          );
        }
      }
      autoScaleViewports(
        resetPointViewPort: false,
        resetValueViewPort: true,
        animation: false,
      );
    });
  }

  /// Paints the chart on the given canvas.
  void paint(Canvas canvas, Size size) {
    if (kDebugMode && printDebugPaintCount) {
      _paintCount.value += 1;
      if (_paintCount.value % 100 == 0) {
        // ignore: avoid_print
        print("paintCount = ${_paintCount.value}");
      }
    }
    preRender?.call(this, canvas, area);
    render.render(canvas: canvas, chart: this);
    postRender?.call(this, canvas, area);
  }

  /// Saves the current chart as an image.
  Future<Image> saveAsImage() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, area);
    render.render(canvas: canvas, chart: this);
    final picture = recorder.endRecording();
    return picture.toImage(size.width.floor(), size.height.floor());
  }

  /// Resizes the chart to the specified view area.
  void resize({required Rect newArea, bool force = false}) {
    if (newArea == _area.value && !force) {
      return;
    }
    Rect refinedArea = newArea.translate(0, 0);
    if (refinedArea.width < minSize.width) {
      refinedArea = Rect.fromLTWH(
        refinedArea.left,
        refinedArea.top,
        minSize.width,
        refinedArea.height,
      );
    }
    if (refinedArea.height < minSize.height) {
      refinedArea = Rect.fromLTWH(
        refinedArea.left,
        refinedArea.top,
        refinedArea.width,
        minSize.height,
      );
    }
    if (_area.value != refinedArea || force) {
      final visiblePanel = panels.where((p) => p.visible).first;
      double graphWidthBefore = visiblePanel.isLayoutReady
          ? visiblePanel.graphArea().width
          : 0;
      double graphHeightBefore = visiblePanel.isLayoutReady
          ? visiblePanel.graphArea().height
          : 0;
      crosshair.updateCrossPosition(
        chart: this,
        trigger: GCrosshairTrigger.resized,
      );
      _area.value = refinedArea;
      List<double> panelsGraphHeightBefore = panels
          .map(
            (panel) => (panel.isLayoutReady ? panel.graphArea().height : 0.0),
          )
          .toList(growable: false);
      layout(_area.value);

      if (graphWidthBefore > 0 || graphHeightBefore > 0) {
        // update viewports
        if (graphWidthBefore > 0 &&
            graphWidthBefore != visiblePanel.graphArea().width) {
          pointViewPort.resize(
            graphWidthBefore,
            visiblePanel.graphArea().width,
            false,
          );
          autoScaleViewports(
            resetPointViewPort: false,
            resetValueViewPort: true,
            animation: false,
          );
          _debounceHelper.run(() {
            _pointViewPortChanged();
            pointViewPort.notifyListeners();
          });
        }
        if (graphHeightBefore > 0) {
          for (int p = 0; p < panels.length; p++) {
            final panel = panels[p];
            final panelGraphHeightBefore = panelsGraphHeightBefore[p];
            for (final valueViewPort in panel.valueViewPorts) {
              if (!valueViewPort.autoScaleFlg &&
                  panelGraphHeightBefore > 0 &&
                  panelGraphHeightBefore != panel.graphArea().height) {
                valueViewPort.resize(
                  graphHeightBefore,
                  panel.graphArea().height,
                  true,
                );
              }
            }
          }
        }
      } else {
        autoScaleViewports(
          resetPointViewPort: false,
          resetValueViewPort: true,
          animation: false,
        );
        _notify();
      }
    }
  }

  /// Recalculates the layout of chart components based on panel weights and axis positions.
  void layout([Rect? toArea]) {
    final area = toArea ?? _area.value;
    double totalHeightWeight = panels.fold(
      0,
      (sum, panel) => sum + (panel.visible ? panel.heightWeight : 0),
    );
    double y = area.top;
    List<Rect> panelAreas = panels.map((panel) {
      if (!panel.visible) {
        return Rect.zero;
      }
      double height = area.height * panel.heightWeight / totalHeightWeight;
      Rect panelArea = Rect.fromLTRB(area.left, y, area.right, y + height);
      y += height;
      return panelArea;
    }).toList();
    for (int p = 0; p < panels.length; p++) {
      GPanel? nextPanel = nextVisiblePanel(startIndex: p + 1);
      bool hasSplitter =
          nextPanel != null && panels[p].resizable && nextPanel.resizable;
      panels[p].layout(panelAreas[p], hasSplitter);
    }
  }

  /// Auto-scales all viewports with an auto-scale strategy.
  void autoScaleViewports({
    bool resetPointViewPort = true,
    bool resetValueViewPort = true,
    bool animation = true,
  }) {
    if (resetPointViewPort &&
        pointViewPort.isValid &&
        pointViewPort.autoScaleStrategy != null &&
        pointViewPort.autoScaleFlg) {
      pointViewPort.autoScaleReset(
        chart: this,
        panel: panels[0],
        finished: true,
        animation: animation,
      );
    }
    for (int p = 0; p < panels.length; p++) {
      final panel = panels[p];
      if (!panel.visible) {
        continue;
      }
      for (final valueViewPort in panel.valueViewPorts) {
        if (resetValueViewPort &&
            valueViewPort.isValid &&
            valueViewPort.autoScaleFlg &&
            valueViewPort.autoScaleStrategy != null) {
          valueViewPort.autoScaleReset(
            chart: this,
            panel: panel,
            animation: animation,
          );
        }
      }
    }
  }

  /// Performs hit testing on panel graphs at the given position.
  (GPanel, GGraph, GOverlayMarker?)? hitTestPanelGraphs({
    required Offset position,
  }) {
    if (dataSource.isLoading || dataSource.isEmpty) {
      return null;
    }
    for (int p = 0; p < panels.length; p++) {
      GPanel panel = panels[p];
      final (graph, marker) = panel.hitTestGraphs(position: position);
      if (graph != null) {
        return (panel, graph, marker);
      }
    }
    return null;
  }

  /// Gets the next visible panel starting from the given index.
  GPanel? nextVisiblePanel({int startIndex = 0}) {
    for (int p = startIndex; p < panels.length; p++) {
      GPanel panel = panels[p];
      if (panel.visible) {
        return panel;
      }
    }
    return null;
  }

  void _pointViewPortChanged() {
    final updatedViewPort = pointViewPort;
    if (!updatedViewPort.isAnimating && !isScaling) {
      // load data if necessary
      dataSource
          .ensureData(
            fromPoint: updatedViewPort.startPoint.floor(),
            toPoint: updatedViewPort.endPoint.ceil(),
          )
          .then((_) {
            autoScaleViewports(
              resetPointViewPort: false,
              resetValueViewPort: true,
              animation: true,
            );
          });
    } else {
      autoScaleViewports(
        resetPointViewPort: false,
        resetValueViewPort: true,
        animation: false,
      );
    }
    _notify();
  }

  void _valueViewPortChanged({required GValueViewPort updatedViewPort}) {
    _notify();
  }

  /// Notifies all registered listeners of changes.
  void _notify() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  /// Triggers a repaint of the chart.
  void repaint({bool layout = true}) {
    if (layout) {
      this.layout(area);
    }
    _notify();
  }

  /// Disposes of the chart and releases resources.
  @override
  void dispose() {
    pointViewPort.dispose();
    for (final panel in panels) {
      panel.dispose();
    }
    dataSource.removeListener(_notify);
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GDataSource>('dataSource', dataSource));
    properties.add(
      DiagnosticsProperty<GPointViewPort>('pointViewPort', pointViewPort),
    );
    properties.add(DiagnosticsProperty<GBackground>('background', background));
    for (int n = 0; n < panels.length; n++) {
      properties.add(DiagnosticsProperty<GPanel>('panel[$n]', panels[n]));
    }
    properties.add(DiagnosticsProperty<GSplitter>('splitter', splitter));
    properties.add(DiagnosticsProperty<GCrosshair>('crosshair', crosshair));
    properties.add(DiagnosticsProperty<GTheme>('theme', theme));
    properties.add(DiagnosticsProperty<Rect>('area', area));
  }
}
