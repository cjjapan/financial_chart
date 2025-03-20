import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';

import 'chart.dart';
import 'components/graph/graph.dart';
import 'components/panel/panel.dart';
import 'components/viewport_v.dart';
import 'components/axis/axis.dart';
import 'components/viewport_h.dart';
import 'values/range.dart';
import 'values/value.dart';

/// GChartController for handling user interactions for the attached chart.
// ignore_for_file: avoid_print
// ignore: must_be_immutable
class GChartController extends ChangeNotifier {
  final bool autoSyncPointViewPorts;
  late final GChart _chart;
  int? resizingPanelIndex;
  final GValue<bool> _isTouchEvent = GValue(false);
  final GValue<bool> _isTouchCrossMode = GValue(false);

  GChartController({this.autoSyncPointViewPorts = true});

  void Function({
    required Offset position,
    required double scale,
    required double verticalScale,
  })?
  _hookScaleUpdate;
  void Function(Velocity? velocity)? _hookScaleEnd;

  void attach(GChart chart) {
    _chart = chart;
  }

  void mouseEnter({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _notify();
  }

  void mouseExit() {
    _chart.crosshair.clearCrossPosition();
    _notify();
  }

  void mouseHover({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      for (int g = 0; g < panel.graphs.length; g++) {
        panel.graphs[g].highlight(newValue: false);
      }
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      if (panel.panelArea().contains(position)) {
        int? graphIndex = _hitTestPanelGraphs(panel: panel, position: position);
        if (graphIndex != null) {
          panel.graphs[graphIndex].highlight(newValue: true);
          break;
        }
      }
    }
    _notify();
  }

  void pointerScroll({required Offset position, required Offset scrollDelta}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_chart.pointerScrollMode == GPointerScrollMode.none) {
      return;
    }
    for (int n = 0; n < _chart.panels.length; n++) {
      Rect area = _chart.panels[n].graphArea();
      if (area.contains(position)) {
        final pointViewPort = _chart.pointViewPort;
        pointViewPort.stopAnimation();
        if (_chart.pointerScrollMode == GPointerScrollMode.move) {
          final pointSize = pointViewPort.pointSize(area.width);
          final distance = scrollDelta.dy / pointSize;
          final newRange = GRange.range(
            pointViewPort.startPoint - distance,
            pointViewPort.endPoint - distance,
          );
          pointViewPort.animateToRange(_chart, newRange, true, false);
        } else if (_chart.pointerScrollMode == GPointerScrollMode.zoom) {
          final centerPoint =
              pointViewPort
                  .positionToPoint(area, position.dx)
                  .round()
                  .toDouble();
          final scaleRatio = 1 + scrollDelta.dy / area.height;
          pointViewPort.zoomUpdate(
            pointViewPort.range,
            area,
            scaleRatio,
            centerPoint,
          );
        }
        _notify();
        break;
      }
    }
  }

  void scaleStart({required Offset start, required int pointerCount}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      // hit test splitter
      if (n < _chart.panels.length - 1 &&
          panel.splitterArea().contains(start)) {
        GPanel? splitterPanel = _tryScalingSplitter(
          n,
          _chart.panels[n],
          _chart.panels[n + 1],
          start,
        );
        if (splitterPanel != null) {
          break;
        }
      }
      if (panel.panelArea().contains(start)) {
        // hit test hAxis
        GPointAxis? pointAxis = _tryScalingPointAxis(panel, start);
        if (pointAxis != null) {
          break;
        }
        // hit test vAxis
        GValueAxis? valueAxis = _tryScalingValueAxis(panel, start);
        if (valueAxis != null) {
          break;
        }
        // hit test graph
        if (panel.graphArea().contains(start)) {
          _tryScalingGraph(panel, start, pointerCount);
        }
        break;
      }
    }
    _notify();
  }

  void scaleUpdate({
    required Offset position,
    required double scale,
    required double verticalScale,
  }) {
    if (_hookScaleUpdate != null) {
      _hookScaleUpdate!(
        position: position,
        scale: scale,
        verticalScale: verticalScale,
      );
    }
    _notify();
  }

  void scaleEnd(Velocity velocity) {
    if (_hookScaleEnd != null) {
      _hookScaleEnd!(velocity);
      _hookScaleUpdate = null;
      _hookScaleEnd = null;
      _notify();
    }
    _notify();
  }

  void longPressStart({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_isTouchEvent()) {
      _isTouchCrossMode(newValue: true);
      _chart.crosshair.setCrossPosition(position.dx, position.dy);
      _notify();
    }
  }

  void longPressMove({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _notify();
  }

  void longPressEnd({required Offset position}) {}

  void tapDown({required Offset position, required bool isTouch}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    _isTouchEvent(newValue: isTouch);
  }

  void tapUp({required Offset position, required bool isTouch}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_isTouchCrossMode()) {
      _isTouchCrossMode(newValue: false);
      _isTouchEvent(newValue: false);
      _chart.crosshair.clearCrossPosition();
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      if (panel.panelArea().contains(position)) {
        int? graphIndex = _hitTestPanelGraphs(panel: panel, position: position);
        if (graphIndex != null) {
          break;
        }
      }
    }
    _notify();
  }

  void doubleTap({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      if (panel.panelArea().contains(position)) {
        for (int a = 0; a < panel.valueAxes.length; a++) {
          GValueAxis axis = panel.valueAxes[a];
          Rect axisArea = panel.valueAxisArea(a);
          if (axisArea.contains(position)) {
            GValueViewPort? valueViewPort = panel.findValueViewPortById(
              axis.viewPortId,
            );
            valueViewPort?.autoScaleReset(
              chart: _chart,
              panel: panel,
              autoScaleFlg: true,
            );
            break;
          }
        }
        for (int a = 0; a < panel.pointAxes.length; a++) {
          Rect axisArea = panel.pointAxisArea(a);
          if (axisArea.contains(position)) {
            _chart.pointViewPort.autoScaleReset(
              chart: _chart,
              panel: panel,
              finished: true,
              animation: true,
            );
            break;
          }
        }
        break;
      }
    }
    _notify();
  }

  int? _hitTestPanelGraphs({required GPanel panel, required Offset position}) {
    for (int g = panel.graphs.length - 1; g > 0; g--) {
      GGraph graph = panel.graphs[g];
      if (graph.visible && graph.getRender().hitTest(position: position)) {
        return g;
      }
    }
    return null;
  }

  GPanel? _tryScalingSplitter(
    int panel1Index,
    GPanel panel1,
    GPanel panel2,
    Offset start,
  ) {
    if (!panel1.resizable || !panel2.resizable) {
      return null;
    }
    if (panel1.splitterArea().contains(start)) {
      double h1 = panel1.panelArea().height;
      double h2 = panel2.panelArea().height;
      double moveToleranceMin = -panel1.graphArea().height + 50;
      double moveToleranceMax = panel2.graphArea().height - 50;
      double weightUnit = panel1.heightWeight / (h1 / _chart.size.height);
      resizingPanelIndex = panel1Index;
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        double moveDistance = min(
          max((position.dy - start.dy), moveToleranceMin),
          moveToleranceMax,
        );
        double h1New = h1 + moveDistance;
        double h2New = h2 - moveDistance;
        panel1.heightWeight = h1New * weightUnit;
        panel2.heightWeight = h2New * weightUnit;
        _chart.layout(_chart.area);
      };
      _hookScaleEnd = (Velocity? velocity) {
        resizingPanelIndex = null;
      };
      return panel1;
    }
    return null;
  }

  GPointAxis? _tryScalingPointAxis(GPanel panel, Offset start) {
    for (int a = 0; a < panel.pointAxes.length; a++) {
      GPointAxis axis = panel.pointAxes[a];
      Rect axisArea = panel.pointAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          //print("scaling: panel=$panel, hAxis=$a");
          GPointViewPort pointViewPort = _chart.pointViewPort;
          pointViewPort.interactionStart();
          double lastX = start.dx;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            _chart.crosshair.setCrossPosition(position.dx, position.dy);
            if (axis.scaleMode == GAxisScaleMode.zoom) {
              double scaleRatio =
                  (axisArea.right - position.dx) / (axisArea.right - start.dx);
              pointViewPort.interactionZoomUpdate(axisArea, scaleRatio);
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              double moveDistance = (position.dx - start.dx);
              pointViewPort.interactionMoveUpdate(axisArea, moveDistance);
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPort.interactionSelectUpdate(
                _chart,
                axisArea,
                start.dx,
                position.dx,
                finished: false,
              );
            }
            lastX = position.dx;
          };
          _hookScaleEnd = (Velocity? velocity) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPort.interactionSelectUpdate(
                _chart,
                axisArea,
                start.dx,
                lastX,
                finished: true,
              );
            }
            pointViewPort.interactionEnd();
          };
        }
        return axis;
      }
    }
    return null;
  }

  GValueAxis? _tryScalingValueAxis(GPanel panel, Offset start) {
    // test if hit vAxis
    for (int a = 0; a < panel.valueAxes.length; a++) {
      GValueAxis axis = panel.valueAxes[a];
      Rect axisArea = panel.valueAxisArea(a);
      if (axisArea.contains(start)) {
        if (axis.scaleMode != GAxisScaleMode.none) {
          //print("scaling: panel=$panel, vAxis=$a");
          GValueViewPort? viewPort = panel.findValueViewPortById(
            axis.viewPortId,
          );
          viewPort?.autoScaleFlg = false;
          viewPort?.interactionStart();
          double lastY = start.dy;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            _chart.crosshair.setCrossPosition(position.dx, position.dy);
            if (axis.scaleMode == GAxisScaleMode.zoom) {
              double scaleRatio = min(
                max(
                  (axisArea.bottom - start.dy) /
                      (axisArea.bottom - min(position.dy, axisArea.bottom - 1)),
                  0.01,
                ),
                100,
              );
              viewPort?.interactionZoomUpdate(axisArea, scaleRatio);
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              double moveDistance = (position.dy - start.dy);
              viewPort?.interactionMoveUpdate(axisArea, moveDistance);
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              viewPort?.interactionSelectUpdate(
                _chart,
                axisArea,
                start.dy,
                position.dy,
                finished: false,
              );
            }
            lastY = position.dy;
          };
          _hookScaleEnd = (Velocity? velocity) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              viewPort?.interactionSelectUpdate(
                _chart,
                axisArea,
                start.dy,
                lastY,
                finished: true,
              );
            }
            viewPort?.interactionEnd();
          };
          return axis;
        }
      }
    }
    return null;
  }

  GGraph? _tryScalingGraph(GPanel panel, Offset start, int pointerCount) {
    if (!panel.graphArea().contains(start)) {
      return null;
    }
    int graphIndex =
        _hitTestPanelGraphs(panel: panel, position: start) ??
        (panel.graphs.length - 1);
    GGraph graph = panel.graphs[graphIndex];
    GPointViewPort pointViewPort = _chart.pointViewPort;
    GValueViewPort? valueViewPort =
        panel.findValueViewPortById(graph.valueViewPortId)!;
    Rect graphArea = panel.graphArea();
    if (_isTouchCrossMode.value) {
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        _chart.crosshair.setCrossPosition(position.dx, position.dy);
      };
      _hookScaleEnd = (Velocity? velocity) {};
      return graph;
    }
    pointViewPort.interactionStart();
    pointViewPort.stopAnimation();
    bool scaleValue = !valueViewPort.autoScaleFlg;
    if (scaleValue) {
      valueViewPort.interactionStart();
    }
    _hookScaleUpdate = ({
      required Offset position,
      required double scale,
      required double verticalScale,
    }) {
      _chart.crosshair.clearCrossPosition();
      double moveDistanceX = (position.dx - start.dx);
      if (scale != 1.0) {
        if (scale != 1.0 && scale > 0) {
          //pointViewPort.interactionMoveUpdate(graphArea, moveDistanceX);
          pointViewPort.interactionZoomUpdate(graphArea, scale);
        }
        if (verticalScale != 1.0 && verticalScale > 0 && scaleValue) {
          //valueViewPort.interactionZoomUpdate(graphArea, verticalScale);
        }
        return;
      }
      pointViewPort.interactionMoveUpdate(graphArea, moveDistanceX);
      if (scaleValue) {
        double moveDistanceY = (position.dy - start.dy);
        valueViewPort.interactionMoveUpdate(graphArea, moveDistanceY);
      }
    };
    _hookScaleEnd = (Velocity? velocity) {
      pointViewPort.interactionEnd();
      if (scaleValue) {
        valueViewPort.interactionEnd();
      }
      if (velocity != null) {
        // momentum scrolling
        final pointSize = pointViewPort.pointSize(panel.graphArea().width);
        final distance = velocity.pixelsPerSecond.dx / pointSize / 2.0;
        final newRange = GRange.range(
          pointViewPort.startPoint - distance,
          pointViewPort.endPoint - distance,
        );
        final simulation = FrictionSimulation.through(0, 1, 1, 0.9);
        pointViewPort.animateToRange(
          _chart,
          newRange,
          true,
          true,
          simulation: simulation,
        );
      }
    };
    return graph;
  }

  void _notify() {
    notifyListeners();
  }
}
