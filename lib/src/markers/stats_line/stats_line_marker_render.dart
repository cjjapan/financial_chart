import 'dart:math';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';

class GStatsLineMarkerRender
    extends GOverlayMarkerRender<GStatsLineMarker, GOverlayMarkerTheme> {
  static const double _rayExtension = 100000;

  GStatsLineMarkerRender();

  @override
  void doRenderMarker({
    required Canvas canvas,
    required GChart chart,
    required GPanel panel,
    required GComponent component,
    required GStatsLineMarker marker,
    required Rect area,
    required GOverlayMarkerTheme theme,
    required GPointViewPort pointViewPort,
    required GValueViewPort valueViewPort,
  }) {
    if (marker.keyCoordinates.length < 2) {
      return;
    }
    controlHandles.clear();
    _hitTestLinePoints.clear();
    for (int i = 0; i < marker.keyCoordinates.length - 1; i++) {
      final startPosition = marker.keyCoordinates[i].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      final endPosition = marker.keyCoordinates[i + 1].toPosition(
        area: area,
        valueViewPort: valueViewPort,
        pointViewPort: pointViewPort,
      );
      if (chart.hitTestEnable && marker.hitTestEnable) {
        controlHandles.addAll({
          "start": GControlHandle(
            position: Offset(startPosition.dx, startPosition.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 0,
          ),
          "end": GControlHandle(
            position: Offset(endPosition.dx, endPosition.dy),
            type: GControlHandleType.resize,
            keyCoordinateIndex: 1,
          ),
        });
        _hitTestLinePoints.addAll([
          [
            Vector2(startPosition.dx, startPosition.dy),
            Vector2(endPosition.dx, endPosition.dy),
          ],
        ]);
      }

      GArrowLineMarkerRender.drawArrow(
        canvas: canvas,
        start: startPosition,
        end: endPosition,
        startHead: marker.startHead,
        endHead: marker.endHead,
        arrowStyle: theme.markerStyle,
        lineStyle: theme.markerStyle,
      );

      Offset startOffset = startPosition;
      Offset endOffset = endPosition;
      if (marker.endRay) {
        final direction = endOffset - startOffset;
        final length = direction.distance;
        if (length > 1e-6) {
          final normalizedDirection = direction / length;
          endOffset =
              endOffset + normalizedDirection * _rayExtension; // Extend the ray
          Path path = addLinePath(
            x1: endPosition.dx,
            y1: endPosition.dy,
            x2: endOffset.dx,
            y2: endOffset.dy,
          );
          drawPath(canvas: canvas, path: path, style: theme.markerStyle);
          _hitTestLinePoints.add([
            Vector2(endPosition.dx, endPosition.dy),
            Vector2(endOffset.dx, endOffset.dy),
          ]);
        }
      }
      if (marker.startRay) {
        final direction = startOffset - endOffset;
        final length = direction.distance;
        if (length > 1e-6) {
          final normalizedDirection = direction / length;
          startOffset =
              startOffset +
              normalizedDirection * _rayExtension; // Extend the ray
          Path path = addLinePath(
            x1: startPosition.dx,
            y1: startPosition.dy,
            x2: startOffset.dx,
            y2: startOffset.dy,
          );
          drawPath(canvas: canvas, path: path, style: theme.markerStyle);
          _hitTestLinePoints.add([
            Vector2(startPosition.dx, startPosition.dy),
            Vector2(startOffset.dx, startOffset.dy),
          ]);
        }
      }

      // statistics
      if (component is GGraph) {
        final graph = component;
        final valueViewPort = panel.findValueViewPortById(
          graph.valueViewPortId,
        );
        final pointViewPort = chart.pointViewPort;
        if (valueViewPort.isValid && pointViewPort.isValid) {
          final startPrice = valueViewPort.positionToValue(
            area,
            startPosition.dy,
          );
          final endPrice = valueViewPort.positionToValue(area, endPosition.dy);
          final startPoint = pointViewPort
              .positionToPoint(area, startPosition.dx)
              .round();
          final endPoint = pointViewPort
              .positionToPoint(area, endPosition.dx)
              .round();
          final startPointValue = chart.dataSource.getPointValue(
            startPoint.round(),
          );
          final endPointValue = chart.dataSource.getPointValue(
            endPoint.round(),
          );
          double angleRadian = -atan2(
            endPosition.dy - startPosition.dy,
            endPosition.dx - startPosition.dx,
          );
          double angleDegree = angleRadian * 180 / pi;

          final dottedLineStyle = theme.markerStyle.copyWith(
            dash: [2, 2],
            strokeWidth: 1,
          );
          final rawTextStyle = theme.labelStyle!;

          // fill the area
          if (marker.fillStyle == GStatsLineFillStyle.rectangle) {
            final rectPath = GRenderUtil.addRectPath(
              rect: Rect.fromPoints(startPosition, endPosition),
            );
            GRenderUtil.drawPath(
              canvas: canvas,
              path: rectPath,
              style: dottedLineStyle,
            );
          } else if (marker.fillStyle == GStatsLineFillStyle.triangle) {
            final trianglePath = Path()
              ..moveTo(startPosition.dx, startPosition.dy)
              ..lineTo(endPosition.dx, startPosition.dy)
              ..lineTo(endPosition.dx, endPosition.dy)
              ..close();
            GRenderUtil.drawPath(
              canvas: canvas,
              path: trianglePath,
              style: dottedLineStyle,
            );
          }

          Alignment alignment = Alignment(
            endPosition.dx < startPosition.dx ? 1 : -1,
            endPosition.dy > startPosition.dy ? 1 : -1,
          );
          // calculate stats anchor position based on statsPosition (0.0 - 1.0)
          if (marker.statsBoxPosition != null) {
            final statsAnchor =
                startPosition +
                (endPosition - startPosition) * marker.statsBoxPosition!;
            final stats = GLineStats(
              startPosition: startPosition,
              endPosition: endPosition,
              startValue: startPrice.toStringAsFixed(3),
              endValue: endPrice.toStringAsFixed(3),
              startPoint: startPoint,
              endPoint: endPoint,
              startPointValue: startPointValue ?? 0,
              endPointValue: endPointValue ?? 0,
              angleRadian: angleRadian,
              angleDegree: angleDegree,
            );

            GTableLayoutPainter
            tablePainter = GTableLayoutPainter.twoColumnIconAndText(
              iconAndTexts: [
                (
                  Icons.height,
                  "${(endPrice - startPrice).toStringAsFixed(3)} (${(startPosition.dy - endPosition.dy).toStringAsFixed(0)}px)",
                ),
                (
                  Icons.swap_horiz_outlined,
                  (startPointValue != null && endPointValue != null)
                      ? "${endPoint - startPoint}bars (${formatTimespan(endPointValue - startPointValue)}, ${(endPosition.dx - startPosition.dx).toStringAsFixed(0)}px)"
                      : "${endPoint - startPoint} bars (${(endPosition.dx - startPosition.dx).toStringAsFixed(0)}px)",
                ),
                (
                  Icons.signal_cellular_0_bar_outlined,
                  "${stats.angleRadian.toStringAsFixed(2)} rad (${stats.angleDegree.toStringAsFixed(2)}°)",
                ),
                (
                  Icons.north_east,
                  "${(endPosition - startPosition).distance.toStringAsFixed(0)} px",
                ),
              ],
              textStyle: theme.labelStyle!.textStyle!,
              leftCellPadding: const EdgeInsets.all(4),
              blockCornerRadius: 5,
              blockStyle: theme.labelStyle!.backgroundStyle,
              anchor: statsAnchor,
              alignment: alignment,
              iconSize: 16,
              iconColor: theme.labelStyle!.textStyle!.color,
            );
            tablePainter.paint(canvas);

            if (chart.hitTestEnable && marker.hitTestEnable) {
              controlHandles.addAll({
                "stats": GControlHandle(
                  position: Offset(statsAnchor.dx, statsAnchor.dy),
                  type: GControlHandleType.align,
                ),
              });
            }
          }
          if (marker.showPointStats) {
            // horizontal line
            final horizontalPath = GRenderUtil.addLinePath(
              x1: startPosition.dx,
              y1: startPosition.dy,
              x2: endPosition.dx,
              y2: startPosition.dy,
            );
            drawPath(
              canvas: canvas,
              path: horizontalPath,
              style: dottedLineStyle,
            );
            // horizontal line text

            drawText(
              canvas: canvas,
              text: (startPointValue != null && endPointValue != null)
                  ? "${endPoint - startPoint}bars (${formatTimespan(endPointValue - startPointValue)}, ${(endPosition.dx - startPosition.dx).toStringAsFixed(0)}px)"
                  : "${endPoint - startPoint} bars (${(endPosition.dx - startPosition.dx).toStringAsFixed(0)}px)",
              style: rawTextStyle,
              anchor: Offset(
                (startPosition.dx + endPosition.dx) / 2,
                startPosition.dy + (angleRadian >= 0 ? 2 : -2),
              ),
              defaultAlign: angleRadian < 0
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
            );
          }

          if (marker.showValueStats) {
            // vertical line
            final verticalPath = GRenderUtil.addLinePath(
              x1: endPosition.dx,
              y1: startPosition.dy,
              x2: endPosition.dx,
              y2: endPosition.dy,
            );
            drawPath(
              canvas: canvas,
              path: verticalPath,
              style: dottedLineStyle,
            );
            // vertical line text
            drawText(
              canvas: canvas,
              text:
                  "${(endPrice - startPrice).toStringAsFixed(3)} (${(startPosition.dy - endPosition.dy).toStringAsFixed(0)}px)",
              style: rawTextStyle,
              anchor: Offset(
                endPosition.dx + (angleDegree.abs() < 90 ? 2 : -2),
                (startPosition.dy + endPosition.dy) / 2,
              ),
              defaultAlign: angleDegree.abs() < 90
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
            );
          }
          if (marker.showAngleStats) {
            // draw angle arc
            final arcPath = GRenderUtil.addArcPath(
              center: startPosition,
              radius: marker.angleMarkRadius,
              startAngle: angleRadian > 0 ? -angleRadian : 0,
              endAngle: angleRadian > 0 ? 0 : -angleRadian,
              closeType: GArcCloseType.center,
            );
            GRenderUtil.drawPath(
              canvas: canvas,
              path: arcPath,
              style: dottedLineStyle,
              strokeOnly: true,
            );

            // draw angle text
            drawText(
              canvas: canvas,
              text:
                  "${angleRadian.toStringAsFixed(2)} rad (${angleDegree.toStringAsFixed(2)}°)",
              style: rawTextStyle,
              anchor:
                  startPosition +
                  Offset(marker.angleMarkRadius + 2, angleRadian >= 0 ? -2 : 2),
              defaultAlign: angleRadian >= 0
                  ? Alignment.topRight
                  : Alignment.bottomRight,
            );
          }
          if (marker.showDistance) {
            // draw distance text
            final distance = (endPosition - startPosition).distance;
            drawText(
              canvas: canvas,
              text: "${distance.toStringAsFixed(0)} px",
              style: rawTextStyle,
              anchor: Offset(
                (startPosition.dx + endPosition.dx) / 2,
                (startPosition.dy + endPosition.dy) / 2,
              ),
              defaultAlign: angleDegree.abs() < 90
                  ? (angleRadian >= 0
                        ? Alignment.topLeft
                        : Alignment.bottomLeft)
                  : (angleRadian >= 0
                        ? Alignment.topRight
                        : Alignment.bottomRight),
            );
          }

          if (marker.highlighted || marker.selected) {
            super.drawControlHandles(
              canvas: canvas,
              marker: marker,
              theme: theme,
              area: area,
              valueViewPort: valueViewPort,
              pointViewPort: pointViewPort,
            );
          }
        }
      }
    }
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String formatTimespan(int milliseconds) {
    if (milliseconds < 0) {
      return "-${formatTimespan(-milliseconds)}";
    }
    final duration = Duration(milliseconds: milliseconds);
    if (milliseconds >= 86400000) {
      // more than one day
      final days = duration.inDays;
      final hours = duration.inHours.remainder(24);
      if (hours == 0) {
        return "${days}d";
      }
      return "${days}d${twoDigits(hours)}h";
    }
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }

  final List<List<Vector2>> _hitTestLinePoints = [];

  @override
  bool hitTest({required Offset position, double? epsilon}) {
    if (_hitTestLinePoints.isEmpty) {
      return false;
    }
    if (super.hitTestControlHandles(position: position, epsilon: epsilon)) {
      return true;
    }
    if (super.hitTestLines(lines: _hitTestLinePoints, position: position)) {
      return true;
    }
    return false;
  }
}
