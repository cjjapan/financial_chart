part of 'chart_interaction.dart';

/// Custom gesture recognizers for handling touch events on the chart.
extension GChartInteractionGestures on GChartInteractionHandler {
  Map<Type, GestureRecognizerFactory> createGestureRecognizers(
    BuildContext context, {
    Set<PointerDeviceKind>? supportedDevices,
  }) {
    final controller = this;
    final team = GestureArenaTeam();
    final gestureSettings = MediaQuery.maybeOf(context)?.gestureSettings;
    return {
      // ----- ScaleGestureRecognizer -----
      GChartScaleGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<GChartScaleGestureRecognizer>(
            () =>
                GChartScaleGestureRecognizer(
                    supportedDevices: supportedDevices,
                    chart: _chart,
                  )
                  ..team = team
                  ..gestureSettings = gestureSettings,
            (GChartScaleGestureRecognizer instance) {
              team.captain = instance;
              instance.onStart = (details) {
                controller.scaleStart(
                  start: details.localFocalPoint,
                  pointerCount: details.pointerCount,
                );
              };
              instance.onUpdate = (details) {
                controller.scaleUpdate(
                  position: details.localFocalPoint,
                  scale: details.scale,
                  verticalScale: details.verticalScale,
                );
              };
              instance.onEnd = (details) {
                controller.scaleEnd(
                  details.pointerCount,
                  details.scaleVelocity,
                  details.velocity,
                );
              };
            },
          ),
      // ----- VerticalDragGestureRecognizer -----
      GChartVerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            GChartVerticalDragGestureRecognizer
          >(
            () =>
                GChartVerticalDragGestureRecognizer(
                    supportedDevices: supportedDevices,
                    chart: _chart,
                  )
                  ..team = team
                  ..dragStartBehavior = DragStartBehavior.down
                  ..gestureSettings = gestureSettings,
            (GChartVerticalDragGestureRecognizer instance) {
              instance.onStart = (details) {
                controller.scaleStart(
                  start: details.localPosition,
                  pointerCount: 1,
                );
              };
              instance.onUpdate = (details) {
                controller.scaleUpdate(
                  position: details.localPosition,
                  scale: 1,
                  verticalScale: 1,
                );
              };
              instance.onEnd = (details) {
                controller.scaleEnd(1, 0, details.velocity);
              };
              instance.gestureSettings = MediaQuery.maybeOf(
                context,
              )?.gestureSettings;
            },
          ),
      // ----- HorizontalDragGestureRecognizer -----
      GChartHorizontalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            GChartHorizontalDragGestureRecognizer
          >(
            () =>
                GChartHorizontalDragGestureRecognizer(
                    supportedDevices: supportedDevices,
                    chart: _chart,
                  )
                  ..team = team
                  ..dragStartBehavior = DragStartBehavior.down,
            (GChartHorizontalDragGestureRecognizer instance) {
              instance.onStart = (details) {
                controller.scaleStart(
                  start: details.localPosition,
                  pointerCount: 1,
                );
              };
              instance.onUpdate = (details) {
                controller.scaleUpdate(
                  position: details.localPosition,
                  scale: 1,
                  verticalScale: 1,
                );
              };
              instance.onEnd = (details) {
                controller.scaleEnd(1, 0, details.velocity);
              };
              instance.gestureSettings = MediaQuery.maybeOf(
                context,
              )?.gestureSettings;
            },
          ),
      // ----- TapGestureRecognizer -----
      GChartDoubleTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            GChartDoubleTapGestureRecognizer
          >(
            () => GChartDoubleTapGestureRecognizer(
              supportedDevices: supportedDevices,
              chart: _chart,
            ),
            (GChartDoubleTapGestureRecognizer instance) {
              instance
                ..onDoubleTapDown = (details) {
                  controller.doubleTap(position: details.localPosition);
                  for (final panel in _chart.panels) {
                    if (panel.onDoubleTapGraphArea != null &&
                        panel.graphArea().contains(details.localPosition)) {
                      panel.onDoubleTapGraphArea?.call(details.localPosition);
                      break;
                    }
                  }
                  //widget.onDoubleTapDown?.call(details);
                }
                ..gestureSettings = MediaQuery.maybeOf(
                  context,
                )?.gestureSettings;
            },
          ),
      // ----- LongPressGestureRecognizer -----
      GChartLongPressGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            GChartLongPressGestureRecognizer
          >(
            () => GChartLongPressGestureRecognizer(
              supportedDevices: supportedDevices,
              chart: _chart,
            ),
            (GChartLongPressGestureRecognizer instance) {
              instance.onLongPressStart = (details) {
                controller.longPressStart(position: details.localPosition);
                for (final panel in _chart.panels) {
                  if (panel.onLongPressStartGraphArea != null &&
                      panel.graphArea().contains(details.localPosition)) {
                    panel.onLongPressStartGraphArea?.call(
                      details.localPosition,
                    );
                    break;
                  }
                }
              };
              instance.onLongPressMoveUpdate = (details) {
                controller.longPressMove(position: details.localPosition);
                for (final panel in _chart.panels) {
                  if (panel.onLongPressMoveGraphArea != null &&
                      panel.graphArea().contains(details.localPosition)) {
                    panel.onLongPressMoveGraphArea?.call(details.localPosition);
                    break;
                  }
                }
              };
              instance.onLongPressEnd = (details) {
                controller.longPressEnd(position: details.localPosition);
                for (final panel in _chart.panels) {
                  if (panel.onLongPressEndGraphArea != null &&
                      panel.graphArea().contains(details.localPosition)) {
                    panel.onLongPressEndGraphArea?.call(details.localPosition);
                    break;
                  }
                }
              };
              instance.gestureSettings = MediaQuery.maybeOf(
                context,
              )?.gestureSettings;
            },
          ),
      // ----- TapGestureRecognizer -----
      GChartTapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<GChartTapGestureRecognizer>(
            () => GChartTapGestureRecognizer(
              supportedDevices: supportedDevices,
              chart: _chart,
            ),
            (GChartTapGestureRecognizer instance) {
              instance
                ..onTapDown = (details) {
                  controller.tapDown(
                    position: details.localPosition,
                    isTouch: details.kind == PointerDeviceKind.touch,
                  );
                  //widget.onTapDown?.call(details);
                }
                ..onTapUp = (details) {
                  controller.tapUp();
                  for (final panel in _chart.panels) {
                    if (panel.onTapGraphArea != null &&
                        panel.graphArea().contains(details.localPosition)) {
                      panel.onTapGraphArea?.call(details.localPosition);
                      break;
                    }
                  }
                  //widget.onTapUp?.call(details);
                }
                ..onSecondaryTapUp = (details) {
                  for (final panel in _chart.panels) {
                    if (panel.onSecondaryTapGraphArea != null &&
                        panel.graphArea().contains(details.localPosition)) {
                      panel.onSecondaryTapGraphArea?.call(
                        details.localPosition,
                      );
                      break;
                    }
                  }
                }
                ..gestureSettings = MediaQuery.maybeOf(
                  context,
                )?.gestureSettings;
            },
          ),
    };
  }
}
