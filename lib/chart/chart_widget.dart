import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'chart.dart';

Widget _defaultLoadingWidgetBuilder(BuildContext context, GChart chart) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    alignment: Alignment.center,
    color: Colors.black.withAlpha(100),
    child: const CircularProgressIndicator(),
  );
}

Widget _defaultNoDataWidgetBuilder(BuildContext context, GChart chart) {
  return Center(
    child: Text(
      "No data",
      style: TextStyle(
        color:
            chart.theme.pointAxisTheme.labelTheme.labelStyle.textStyle?.color,
        fontSize: 24,
      ),
    ),
  );
}

// ignore_for_file: avoid_print
class GChartWidget extends StatefulWidget {
  final GChart chart;
  final Widget Function(BuildContext context, GChart chart)
  loadingWidgetBuilder;
  final Widget Function(BuildContext context, GChart chart) noDataWidgetBuilder;
  const GChartWidget({
    super.key,
    required this.chart,
    this.noDataWidgetBuilder = _defaultNoDataWidgetBuilder,
    this.loadingWidgetBuilder = _defaultLoadingWidgetBuilder,
  });

  @override
  GChartWidgetState createState() => GChartWidgetState();
}

class GChartWidgetState extends State<GChartWidget>
    with TickerProviderStateMixin {
  GChartWidgetState();
  bool printEvents = false;

  void repaint() {}

  @override
  void initState() {
    super.initState();
    widget.chart.initialize(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.chart.ensureInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chart = widget.chart;
    final controller = chart.controller;
    return LayoutBuilder(
      builder: (context, constraints) {
        Size viewSize = MediaQuery.of(context).size;
        Rect rect = Rect.fromLTRB(
          0,
          0,
          (constraints.maxWidth == double.infinity)
              ? (viewSize.width - 10)
              : constraints.maxWidth,
          (constraints.maxHeight == double.infinity)
              ? (viewSize.height - 10)
              : constraints.maxHeight,
        );
        chart.resize(newArea: rect);
        return Stack(
          children: [
            GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.deferToChild,
              child: Listener(
                onPointerSignal: (PointerSignalEvent event) {
                  if (event is PointerScrollEvent) {
                    if (kDebugMode && printEvents) {
                      print(
                        "PointerScrollEvent: ${event.position} delta= ${event.scrollDelta} ",
                      );
                    }
                    controller.pointerScroll(
                      position: event.position,
                      scrollDelta: event.scrollDelta,
                    );
                  }
                },
                child: MouseRegion(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: chart.size,
                      painter: GChartPainter(
                        chart: chart,
                        repaintListener: chart,
                      ),
                    ),
                  ),
                  onEnter: (PointerEvent details) {
                    controller.mouseEnter(position: details.localPosition);
                  },
                  onExit: (PointerEvent details) {
                    controller.mouseExit();
                  },
                  onHover: (PointerEvent details) {
                    controller.mouseHover(position: details.localPosition);
                  },
                ),
              ),
              onScaleStart: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleStart offset: ${details.localFocalPoint}");
                }
                controller.scaleStart(
                  start: details.localFocalPoint,
                  pointerCount: details.pointerCount,
                );
              },
              onScaleUpdate: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleUpdate offset: ${details.localFocalPoint}");
                }
                controller.scaleUpdate(
                  position: details.localFocalPoint,
                  scale: details.scale,
                  verticalScale: details.verticalScale,
                );
              },
              onScaleEnd: (details) {
                if (kDebugMode && printEvents) {
                  print("onScaleEnd offset: ${details.velocity}");
                }
                controller.scaleEnd(details.velocity);
              },
              onTapDown: (TapDownDetails details) {
                if (kDebugMode && printEvents) {
                  print("onTapDown kind: ${details.kind}");
                }
                controller.tapDown(
                  position: details.localPosition,
                  isTouch: details.kind == PointerDeviceKind.touch,
                );
              },
              onTapUp: (TapUpDetails details) {
                if (kDebugMode && printEvents) {
                  print("onTapUp kind: ${details.kind}");
                }
                controller.tapUp(
                  position: details.localPosition,
                  isTouch: details.kind == PointerDeviceKind.touch,
                );
              },
              onDoubleTapDown: (TapDownDetails details) {
                if (kDebugMode && printEvents) {
                  print("onDoubleTapDown kind: ${details.kind}");
                }
                controller.doubleTap(position: details.localPosition);
              },
              onVerticalDragStart: (DragStartDetails details) {
                controller.scaleStart(
                  start: details.localPosition,
                  pointerCount: 1,
                );
              },
              onLongPressStart: (LongPressStartDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressStart: ${details.localPosition}");
                }
                controller.longPressStart(position: details.localPosition);
              },
              onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressMoveUpdate: ${details.localPosition}");
                }
                controller.longPressMove(position: details.localPosition);
              },
              onLongPressEnd: (LongPressEndDetails details) {
                if (kDebugMode && printEvents) {
                  print("onLongPressEnd kind: ${details.localPosition}");
                }
                controller.longPressEnd(position: details.localPosition);
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                if (kDebugMode && printEvents) {
                  print("onVerticalDragUpdate kind: ${details.localPosition}");
                }
                controller.scaleUpdate(
                  position: details.localPosition,
                  scale: 1,
                  verticalScale: 1,
                );
              },
              onVerticalDragEnd: (DragEndDetails details) {
                controller.scaleEnd(details.velocity);
              },
            ),
            ListenableBuilder(
              listenable: widget.chart.dataSource,
              builder: (context, child) {
                if (widget.chart.dataSource.isLoading) {
                  return widget.loadingWidgetBuilder(context, widget.chart);
                }
                if (widget.chart.dataSource.dataList.isEmpty) {
                  return widget.noDataWidgetBuilder(context, widget.chart);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}

class GChartPainter extends CustomPainter {
  final GChart chart;
  GChartPainter({required this.chart, Listenable? repaintListener})
    : super(repaint: repaintListener);

  @override
  void paint(Canvas canvas, Size size) {
    chart.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
