part of 'chart_interaction.dart';

/// Custom gesture recognizers for handling events on the chart.
class GChartScaleGestureRecognizer extends ScaleGestureRecognizer {
  GChart? chart;
  GChartScaleGestureRecognizer({
    super.supportedDevices,
    this.chart,
    super.dragStartBehavior = DragStartBehavior.down,
  });

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (team?.captain != this) {
      // get back as captain
      team?.captain = this;
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        super.addAllowedPointer(event);
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // scalable point axes allow scale
      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition) &&
            axis.scaleMode != GAxisScaleMode.none) {
          super.addAllowedPointer(event);
          return;
        }
      }
      // scalable value axes allow scale
      for (final axis in panel.valueAxes) {
        if (axis.scaleMode != GAxisScaleMode.none &&
            panel.valueAxisAreaOf(axis).contains(event.localPosition)) {
          super.addAllowedPointer(event);
          return;
        }
      }
    }
    // graph area allow scale when graphPanMode is not none
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.graphPanMode != GGraphPanMode.none &&
          panel.graphArea().contains(event.localPosition)) {
        super.addAllowedPointer(event);
        return;
      }
    }
  }
}

/// Custom gesture recognizer for handling vertical drag events on the chart.
class GChartVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  GChart? chart;
  GChartVerticalDragGestureRecognizer({super.supportedDevices, this.chart});

  GestureArenaMember? _hijackedCaptain;
  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  void _hijackCaptain() {
    _hijackedCaptain = team?.captain;
    team?.captain = this;
  }

  void _restoreCaptainIfNecessary() {
    if (_hijackedCaptain != null) {
      team?.captain = _hijackedCaptain;
      _hijackedCaptain = null;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // resizable splitters allows vertical drag
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.splitterArea().contains(event.localPosition) &&
          panel.resizable) {
        _hijackCaptain();
        super.addAllowedPointer(event);
        return;
      }
    }
    // scalable value axes allow vertical drag
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      for (final axis in panel.valueAxes) {
        if (axis.scaleMode != GAxisScaleMode.none &&
            panel.valueAxisAreaOf(axis).contains(event.localPosition)) {
          super.addAllowedPointer(event);
          return;
        }
      }
    }
    // graph with allow vertical drag when graphPanMode is not none
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.graphArea().contains(event.localPosition) &&
          panel.graphPanMode != GGraphPanMode.none) {
        final (graph, marker) = panel.hitTestGraphs(
          position: event.localPosition,
        );
        final graphHit = graph ?? panel.graphs.lastOrNull;
        if (graphHit != null &&
            !panel
                .findValueViewPortById(graphHit.valueViewPortId)
                .autoScaleFlg) {
          super.addAllowedPointer(event);
          return;
        }
      }
    }
  }
}

/// Custom gesture recognizer for handling horizontal drag events on the chart.
class GChartHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  GChart? chart;
  GChartHorizontalDragGestureRecognizer({super.supportedDevices, this.chart});
  GestureArenaMember? _hijackedCaptain;

  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  @override
  void rejectGesture(int pointer) {
    super.rejectGesture(pointer);
    _restoreCaptainIfNecessary();
  }

  void _hijackCaptain() {
    _hijackedCaptain = team?.captain;
    team?.captain = this;
  }

  void _restoreCaptainIfNecessary() {
    if (_hijackedCaptain != null) {
      team?.captain = _hijackedCaptain;
      _hijackedCaptain = null;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // splitters do not allow horizontal drag
    for (final panel in (chart?.panels ?? [])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        return;
      }
    }
    // scalable point axes can be scaled by horizontal drag
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition) &&
            axis.scaleMode != GAxisScaleMode.none) {
          _hijackCaptain();
          super.addAllowedPointer(event);
          return;
        }
      }
    }
    // graph areas can be panned by horizontal drag if graphPanMode is not none
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.graphPanMode != GGraphPanMode.none &&
          panel.graphArea().contains(event.localPosition)) {
        // _hijackCaptain();
        super.addAllowedPointer(event);
        return;
      }
    }
  }
}

class GChartLongPressGestureRecognizer extends LongPressGestureRecognizer {
  GChart? chart;

  GChartLongPressGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.resizable &&
          panel.splitterArea().contains(event.localPosition)) {
        // splitters do not allow long press
        return;
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      // allow long press on the graph area (which turns touchCrossMode on)
      if (panel.graphArea().contains(event.localPosition)) {
        super.addAllowedPointer(event);
        return;
      }
    }
  }
}

class GChartTapGestureRecognizer extends TapGestureRecognizer {
  GChart? chart;

  GChartTapGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // always allow tap
    super.addAllowedPointer(event);
  }
}

class GChartDoubleTapGestureRecognizer extends DoubleTapGestureRecognizer {
  GChart? chart;

  GChartDoubleTapGestureRecognizer({super.supportedDevices, this.chart});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      for (final axis in panel.valueAxes) {
        if (panel.valueAxisAreaOf(axis).contains(event.localPosition) &&
            panel.findValueViewPortById(axis.viewPortId).autoScaleStrategy !=
                null) {
          // double tap on a auto-scalable value axis is allowed
          super.addAllowedPointer(event);
          return;
        }
      }

      for (final axis in panel.pointAxes) {
        if (panel.pointAxisAreaOf(axis).contains(event.localPosition) &&
            chart?.pointViewPort.autoScaleStrategy != null) {
          // double tap on a auto-scalable point axis is allowed
          super.addAllowedPointer(event);
          return;
        }
      }
    }
    for (final panel in (chart?.panels ?? <GPanel>[])) {
      if (panel.graphArea().contains(event.localPosition) &&
          panel.onDoubleTapGraphArea != null) {
        // double tap graph area which has a onDoubleTapGraphArea callback is allowed
        super.addAllowedPointer(event);
        return;
      }
    }
  }
}
