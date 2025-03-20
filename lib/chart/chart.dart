import 'dart:async';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'chart_controller.dart';
import 'chart_render.dart';
import 'components/background/background.dart';
import 'components/crosshair/crosshair.dart';
import 'components/splitter/splitter.dart';
import 'components/viewport_h.dart';
import 'components/viewport_h_scaler.dart';
import 'components/viewport_v.dart';
import 'data/data_source.dart';
import 'components/panel/panel.dart';
import 'theme/theme.dart';
import 'values/value.dart';

class DebounceHelper {
  final int milliseconds;
  Timer? _timer;
  DebounceHelper({required this.milliseconds});
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

/// Chart model.
class GChart extends ChangeNotifier {
  /// The data source.
  final GDataSource dataSource;

  /// The only one point viewport of the panel which shared by all the components in the panel.
  final GPointViewPort pointViewPort;

  /// The action mode for pointer scroll event.
  final GValue<GPointerScrollMode> _pointerScrollMode;
  set pointerScrollMode(GPointerScrollMode value) {
    _pointerScrollMode.value = value;
    _notify();
  }

  GPointerScrollMode get pointerScrollMode => _pointerScrollMode.value;

  /// The background component.
  final GBackground background;

  /// The panel components.
  ///
  /// The panels are drawn in order which the first at top side and the last at bottom side.
  final List<GPanel> panels;

  /// The splitter component.
  ///
  /// Splitter is the resize handle between panels.
  final GSplitter splitter;

  /// The crosshair component.
  ///
  /// Crosshair keeps latest mouse pointer position and draw crosshair lines over the chart.
  final GCrosshair crosshair;

  /// The theme container for all chart components.
  final GValue<GTheme> _theme;

  /// The current theme of the chart.
  GTheme get theme => _theme.value;
  set theme(GTheme value) {
    _theme.value = value;
    _notify();
  }

  /// The render for the chart.
  final GChartRender render;

  /// The view area of the chart.
  final GValue<Rect> _area;

  /// The current view area of the chart.
  Rect get area => _area.value;

  /// The current view size of the chart.
  Size get size => area.size;

  /// Painting counter. for debug purpose.
  final GValue<int> _paintCount = GValue(0);

  /// The minimum view size of the chart.
  final Size minSize;

  /// The controller for user interaction.
  late final GChartController _controller;
  GChartController get controller => _controller;

  /// The pre-render callback which is called right before rendering.
  ///
  /// This gives a chance to modify the chart before rendering.
  final void Function(GChart chart, Size size)? preRender;

  /// The post-render callback which is called right after rendering finished.
  final void Function(GChart chart, Size size)? postRender;

  final _debounceHelper = DebounceHelper(milliseconds: 500);

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
  }) : _controller = GChartController(),
       background = (background ?? GBackground()),
       crosshair = (crosshair ?? GCrosshair()),
       splitter = (splitter ?? GSplitter()),
       _pointerScrollMode = GValue(pointerScrollMode),
       pointViewPort =
           pointViewPort ??
           GPointViewPort(
             autoScaleStrategy: const GPointViewPortAutoScaleStrategyLatest(),
           ),
       _theme = GValue(theme),
       _area = GValue(area) {
    controller.attach(this);
  }

  /// Internal initialization of the chart.
  void initialize({TickerProvider? vsync}) {
    controller.addListener(_notify);
    dataSource.addListener(_notify);
    if (vsync != null) {
      pointViewPort.initializeAnimation(vsync);
    }
    pointViewPort.addListener(_pointViewPortChanged);
    for (var panel in panels) {
      for (var valueViewPort in panel.valueViewPorts) {
        valueViewPort.addListener(
          () => _valueViewPortChanged(updatedViewPort: valueViewPort),
        );
        if (vsync != null) {
          valueViewPort.initializeAnimation(vsync);
        }
      }
    }
  }

  /// Load initial data when there is no data in [dataSource].
  ///
  /// Should called only once right after the chart widget is initialized.
  void ensureInitialData() {
    assert(!dataSource.isLoading);
    layout(area);
    final fromPoint =
        pointViewPort.isValid
            ? pointViewPort.startPoint.floor()
            : dataSource.indexToPoint(0);
    final points =
        panels[0].graphArea().width / pointViewPort.defaultPointWidth;
    final toPoint =
        pointViewPort.isValid
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

  /// Paint the chart on the canvas.
  void paint(Canvas canvas, Size size) {
    if (kDebugMode && _paintCount.value % 100 == 0) {
      // ignore: avoid_print
      print("paintCount = ${_paintCount.value}");
    }
    _paintCount.value += 1;
    preRender?.call(this, area.size);
    render.render(canvas: canvas, chart: this);
    postRender?.call(this, size);
  }

  /// Resize the chart view area.
  void resize({required Rect newArea}) {
    if (newArea == _area()) {
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
    if (_area() != refinedArea) {
      final visiblePanel = panels.where((p) => p.visible).first;
      double graphSizeBefore =
          visiblePanel.isLayoutReady ? visiblePanel.graphArea().width : 0;
      crosshair.clearCrossPosition();
      layout(_area(newValue: refinedArea));

      if (graphSizeBefore > 0) {
        // reset point viewport's startPoint to keep point width same as before
        pointViewPort.resize(
          graphSizeBefore,
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

  /// Recalculate layout of the chart components.
  ///
  /// - Decide the size of each panel in [panels] based on the height weight of each panel.
  /// - Decide the axis areas of each panel based on the position of the axes.
  /// - Decide the graph areas of each panel from panel area and axis areas.
  void layout(Rect area) {
    double totalHeightWeight = panels.fold(
      0,
      (sum, panel) => sum + (panel.visible ? panel.heightWeight : 0),
    );
    double y = area.top;
    List<Rect> panelAreas =
        panels.map((panel) {
          if (!panel.visible) {
            return Rect.zero;
          }
          double height = area.height * panel.heightWeight / totalHeightWeight;
          Rect panelArea = Rect.fromLTRB(area.left, y, area.right, y + height);
          y += height;
          return panelArea;
        }).toList();
    for (int p = 0; p < panels.length; p++) {
      var panel = panels[p];
      var panelArea = panelAreas[p];
      panel.layout(this, panelArea);
    }
  }

  /// Auto scale all viewports that have a autoScaleStrategy.
  void autoScaleViewports({
    bool resetPointViewPort = true,
    bool resetValueViewPort = true,
    bool animation = true,
  }) {
    if (resetPointViewPort && pointViewPort.autoScaleStrategy != null) {
      pointViewPort.autoScaleReset(
        chart: this,
        panel: panels[0],
        finished: true,
        animation: animation,
      );
    }
    for (int p = 0; p < panels.length; p++) {
      var panel = panels[p];
      if (!panel.visible) {
        continue;
      }
      for (var valueViewPort in panel.valueViewPorts) {
        if (resetValueViewPort &&
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

  void _pointViewPortChanged() {
    final updatedViewPort = pointViewPort;
    if (!updatedViewPort.isAnimating && !updatedViewPort.isScaling) {
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
              animation: false,
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

  /// Notify the listeners.
  void _notify() {
    notifyListeners();
  }

  void repaint({bool layout = true}) {
    if (layout) {
      this.layout(area);
    }
    _notify();
  }

  /// dispose the chart.
  @override
  void dispose() {
    dataSource.removeListener(_notify);
    controller.removeListener(_notify);
    controller.dispose();
    super.dispose();
  }
}
