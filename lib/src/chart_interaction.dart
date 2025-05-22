import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import 'chart.dart';
import 'components/graph/graph.dart';
import 'components/panel/panel.dart';
import 'components/viewport_v.dart';
import 'components/axis/axis.dart';
import 'components/viewport_h.dart';
import 'values/range.dart';
import 'values/value.dart';

part 'chart_interaction_gesture_recognizers.dart';
part 'chart_interaction_gesture_factory.dart';
part 'chart_interaction_viewports.dart';

/// [GChartInteractionHandler] for handling user interactions for the attached chart.
// ignore: must_be_immutable
class GChartInteractionHandler {
  late final GChart _chart;

  final GValue<bool> _isTouchEvent = GValue(false);
  final GValue<bool> _isTouchCrossMode = GValue(false);

  GPointViewPortInteractionHelper pointViewPortInteractionHelper =
      GPointViewPortInteractionHelper();
  GValueViewPortInteractionHelper valueViewPortInteractionHelper =
      GValueViewPortInteractionHelper();
  bool get isScaling =>
      pointViewPortInteractionHelper.isScaling ||
      valueViewPortInteractionHelper.isScaling;

  GChartInteractionHandler();

  void Function({
    required Offset position,
    required double scale,
    required double verticalScale,
  })?
  _hookScaleUpdate;
  void Function(int pointerCount, double scaleVelocity, Velocity? velocity)?
  _hookScaleEnd;

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

  MouseCursor _mouseCursor({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return _chart.dataSource.isLoading
          ? SystemMouseCursors.wait
          : SystemMouseCursors.basic;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      // test if hit resize splitter
      if (panel.resizable &&
          p < _chart.panels.length - 1 &&
          _chart.panels[p + 1].resizable &&
          panel.splitterArea().contains(position)) {
        return SystemMouseCursors.resizeUpDown;
      }
      // test if hit axes (in case the axes may be inside graph area we test before testing graph)
      for (int n = 0; n < panel.valueAxes.length; n++) {
        Rect axisArea = panel.valueAxisArea(n);
        if (axisArea.contains(position)) {
          if (panel.valueAxes[n].scaleMode == GAxisScaleMode.move) {
            return SystemMouseCursors.grab;
          } else if (panel.valueAxes[n].scaleMode == GAxisScaleMode.zoom) {
            return SystemMouseCursors.resizeUpDown;
          } else if (panel.valueAxes[n].scaleMode == GAxisScaleMode.select) {
            return SystemMouseCursors.resizeUpDown;
          }
          return SystemMouseCursors.basic;
        }
      }
      for (int n = 0; n < panel.pointAxes.length; n++) {
        Rect axisArea = panel.pointAxisArea(n);
        if (axisArea.contains(position)) {
          if (panel.pointAxes[n].scaleMode == GAxisScaleMode.move) {
            return SystemMouseCursors.grab;
          } else if (panel.pointAxes[n].scaleMode == GAxisScaleMode.zoom) {
            return SystemMouseCursors.resizeLeftRight;
          } else if (panel.pointAxes[n].scaleMode == GAxisScaleMode.select) {
            return SystemMouseCursors.resizeLeftRight;
          }
          return SystemMouseCursors.basic;
        }
      }
      // test if hit graph
      if (panel.graphArea().contains(position)) {
        return SystemMouseCursors.precise;
      }
    }
    return SystemMouseCursors.basic;
  }

  void mouseHover({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _chart.mouseCursor.value = _mouseCursor(position: position);
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (int p = 0; p < _chart.panels.length; p++) {
      GPanel panel = _chart.panels[p];
      for (int g = 0; g < panel.graphs.length; g++) {
        panel.graphs[g].highlight = false;
      }
    }
    if (!(pointViewPortInteractionHelper.isScaling ||
        _chart.pointViewPort.isAnimating)) {
      final hit = _chart.hitTestGraph(position: position);
      if (hit != null) {
        hit.$2.highlight = true;
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
          pointViewPort.autoScaleFlg = false;
          pointViewPort.animateToRange(newRange, true, false);
        } else if (_chart.pointerScrollMode == GPointerScrollMode.zoom) {
          final centerPoint =
              pointViewPort.positionToPoint(area, position.dx).toDouble();
          final scaleRatio = 1 - scrollDelta.dy / area.height;
          pointViewPort.autoScaleFlg = false;
          pointViewPort.zoom(area, scaleRatio, centerPoint: centerPoint);
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
    // hit test splitters
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      GPanel? nextPanel = _chart.nextVisiblePanel(startIndex: n + 1);
      if (nextPanel != null && panel.splitterArea().contains(start)) {
        GPanel? splitterPanel = _tryScalingSplitter(n, panel, nextPanel, start);
        if (splitterPanel != null) {
          _notify();
          return;
        }
      }
    }
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      if (panel.panelArea().contains(start)) {
        // hit test hAxis
        GPointAxis? pointAxis = _tryScalingPointAxis(panel, start);
        if (pointAxis != null) {
          _notify();
          return;
        }
        // hit test vAxis
        GValueAxis? valueAxis = _tryScalingValueAxis(panel, start);
        if (valueAxis != null) {
          _notify();
          return;
        }
      }
    }
    for (int n = 0; n < _chart.panels.length; n++) {
      GPanel panel = _chart.panels[n];
      // hit test graph
      if (panel.graphArea().contains(start)) {
        final graph = _tryScalingGraph(panel, start, pointerCount);
        if (graph != null) {
          _notify();
          return;
        }
      }
    }
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
    } else {
      _chart.crosshair.setCrossPosition(position.dx, position.dy);
    }
    _notify();
  }

  void scaleEnd(int pointerCount, double scaleVelocity, Velocity velocity) {
    if (_hookScaleEnd != null) {
      _hookScaleEnd!(pointerCount, scaleVelocity, velocity);
      _hookScaleUpdate = null;
      _hookScaleEnd = null;
    }
    _notify();
  }

  void longPressStart({required Offset position}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    if (_isTouchEvent.value) {
      _isTouchCrossMode.value = true;
      _chart.crosshair.setCrossPosition(position.dx, position.dy);
      _notify();
    }
  }

  void longPressMove({required Offset position}) {
    _chart.crosshair.setCrossPosition(position.dx, position.dy);
    _notify();
  }

  void longPressEnd({required Offset position}) {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
      _chart.crosshair.clearCrossPosition();
      _notify();
    }
  }

  void tapDown({required Offset position, required bool isTouch}) {
    if (_chart.dataSource.isLoading || _chart.dataSource.isEmpty) {
      return;
    }
    for (final panel in _chart.panels) {
      if (panel.panelArea().contains(position) &&
          (!panel.resizable || !panel.splitterArea().contains(position))) {
        _isTouchEvent.value = isTouch;
        _notify();
        return;
      }
    }
  }

  void tapUp() {
    _isTouchEvent.value = false;
    _clearTouchCross();
  }

  void _clearTouchCross() {
    if (_isTouchCrossMode.value) {
      _isTouchCrossMode.value = false;
      _isTouchEvent.value = false;
      _chart.crosshair.clearCrossPosition();
      _notify();
    }
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
            valueViewPort.autoScaleReset(
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
      double weightDensity =
          (panel1.heightWeight + panel2.heightWeight) / (h1 + h2);
      _chart.splitter.resizingPanelIndex = panel1Index;
      _chart.crosshair.crossPosition.clear();
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
        panel1.heightWeight = h1New * weightDensity;
        panel2.heightWeight = h2New * weightDensity;
        _chart.resize(newArea: _chart.area, force: true);
      };
      _hookScaleEnd = (
        int pointerCount,
        double scaleVelocity,
        Velocity? velocity,
      ) {
        _chart.splitter.resizingPanelIndex = null;
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
          GPointViewPort pointViewPort = _chart.pointViewPort;
          pointViewPortInteractionHelper.interactionStart(pointViewPort);
          pointViewPort.autoScaleFlg = false;
          double lastX = start.dx;
          _hookScaleUpdate = ({
            required Offset position,
            required double scale,
            required double verticalScale,
          }) {
            _chart.crosshair.setCrossPosition(position.dx, position.dy);
            if (axis.scaleMode == GAxisScaleMode.zoom ||
                (scale > 0 && scale != 1.0)) {
              double scaleRatio =
                  (axisArea.right - position.dx) / (axisArea.right - start.dx);
              if (scale > 0 && scale != 1.0) {
                pointViewPortInteractionHelper.interactionZoomUpdate(
                  axisArea,
                  start,
                  position,
                  scale,
                );
              } else {
                pointViewPortInteractionHelper.interactionZoomUpdate(
                  axisArea,
                  start,
                  null,
                  scaleRatio,
                );
              }
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              double moveDistance = (position.dx - start.dx);
              pointViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dx,
                position.dx,
                finished: false,
              );
            }
            lastX = position.dx;
          };
          _hookScaleEnd = (
            int pointerCount,
            double scaleVelocity,
            Velocity? velocity,
          ) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              pointViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dx,
                lastX,
                finished: true,
              );
            }
            pointViewPortInteractionHelper.interactionEnd();
          };
          return axis;
        }
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
          GValueViewPort? viewPort = panel.findValueViewPortById(
            axis.viewPortId,
          );
          viewPort.autoScaleFlg = false;
          valueViewPortInteractionHelper.interactionStart(viewPort);
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
              valueViewPortInteractionHelper.interactionZoomUpdate(
                axisArea,
                scaleRatio,
              );
            } else if (axis.scaleMode == GAxisScaleMode.move) {
              double moveDistance = (position.dy - start.dy);
              valueViewPortInteractionHelper.interactionMoveUpdate(
                axisArea,
                moveDistance,
              );
            } else if (axis.scaleMode == GAxisScaleMode.select) {
              valueViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dy,
                position.dy,
                finished: false,
              );
            }
            lastY = position.dy;
          };
          _hookScaleEnd = (
            int pointerCount,
            double scaleVelocity,
            Velocity? velocity,
          ) {
            if (axis.scaleMode == GAxisScaleMode.select) {
              valueViewPortInteractionHelper.interactionSelectUpdate(
                axisArea,
                start.dy,
                lastY,
                finished: true,
              );
            }
            valueViewPortInteractionHelper.interactionEnd();
          };
          return axis;
        }
      }
    }
    return null;
  }

  GGraph? _tryScalingGraph(GPanel panel, Offset start, int pointerCount) {
    Rect graphArea = panel.graphArea();
    if (!graphArea.contains(start)) {
      return null;
    }
    final graph =
        _chart.hitTestPanelGraphs(panel: panel, position: start) ??
        panel.graphs.last;
    if (_isTouchCrossMode.value || panel.graphPanMode == GGraphPanMode.none) {
      // move crosshair only
      _hookScaleUpdate = ({
        required Offset position,
        required double scale,
        required double verticalScale,
      }) {
        _chart.mouseCursor.value = SystemMouseCursors.precise;
        _chart.crosshair.setCrossPosition(position.dx, position.dy);
      };
      _hookScaleEnd =
          (int pointerCount, double scaleVelocity, Velocity? velocity) {};
      return graph;
    }
    GPointViewPort pointViewPort = _chart.pointViewPort;
    GValueViewPort? valueViewPort = panel.findValueViewPortById(
      graph.valueViewPortId,
    );
    pointViewPortInteractionHelper.interactionStart(pointViewPort);
    pointViewPort.stopAnimation();
    pointViewPort.autoScaleFlg = false;
    bool scaleValue = !valueViewPort.autoScaleFlg;
    if (scaleValue) {
      valueViewPortInteractionHelper.interactionStart(valueViewPort);
    }
    _hookScaleUpdate = ({
      required Offset position,
      required double scale,
      required double verticalScale,
    }) {
      _chart.crosshair.clearCrossPosition();
      _chart.mouseCursor.value = SystemMouseCursors.grab;
      double moveDistanceX = (position.dx - start.dx);
      if (scale != 1.0) {
        if (scale != 1.0 && scale > 0) {
          //pointViewPort.interactionMoveUpdate(graphArea, moveDistanceX);
          pointViewPortInteractionHelper.interactionZoomUpdate(
            graphArea,
            start,
            position,
            scale,
          );
        }
        if (verticalScale != 1.0 && verticalScale > 0 && scaleValue) {
          //valueViewPort.interactionZoomUpdate(graphArea, verticalScale);
        }
        return;
      }
      pointViewPortInteractionHelper.interactionMoveUpdate(
        graphArea,
        moveDistanceX,
      );
      if (scaleValue) {
        double moveDistanceY = (position.dy - start.dy);
        valueViewPortInteractionHelper.interactionMoveUpdate(
          graphArea,
          moveDistanceY,
        );
      }
    };
    _hookScaleEnd = (
      int pointerCount,
      double scaleVelocity,
      Velocity? velocity,
    ) {
      _hookScaleEnd = null;
      _chart.mouseCursor.value = SystemMouseCursors.precise;
      bool momentum =
          velocity != null &&
          panel.momentumScrollSpeed > 0 &&
          velocity.pixelsPerSecond.dx.abs() > 1;
      pointViewPortInteractionHelper.interactionEnd(notify: !momentum);
      if (scaleValue) {
        valueViewPortInteractionHelper.interactionEnd();
      }
      if (momentum) {
        // momentum scrolling
        final pointSize = pointViewPort.pointSize(graphArea.width);
        final distance =
            velocity.pixelsPerSecond.dx / pointSize * panel.momentumScrollSpeed;
        GRange newRange = GRange.range(
          pointViewPort.startPoint - distance,
          pointViewPort.endPoint - distance,
        );
        // make sure do not scroll too far that it goes out of current data point range
        final startMin =
            _chart.dataSource.firstPoint - pointViewPort.pointRangeSize;
        final endMax =
            _chart.dataSource.lastPoint + pointViewPort.pointRangeSize;
        newRange = pointViewPort.clampRange(
          newRange.first!,
          newRange.last!,
          startMin: startMin,
          endMax: endMax,
        );
        final simulation = FrictionSimulation.through(0, 1, 1, 0.9);
        pointViewPort.animateToRange(
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
    _chart.repaint(layout: false);
  }
}
