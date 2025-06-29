import 'package:example/widgets/toggle_buttons.dart';
import 'package:example/widgets/control_label.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/indicator_providers.dart';
import '../workshop_state.dart';

class MarkerCoordinateControlView extends StatefulWidget {
  const MarkerCoordinateControlView({super.key});

  @override
  State<MarkerCoordinateControlView> createState() =>
      _MarkerCoordinateControlViewState();
}

class _MarkerCoordinateControlViewState
    extends State<MarkerCoordinateControlView> {
  final coordinateList = [
    "absolute",
    "absolute (inverted)",
    "rational",
    "rational (inverted)",
    "viewport",
    "mixed (absolute x, rational y)",
    "mixed (viewport x, absolute y)",
  ];

  String coordinateType = "absolute";
  GCoordinate coordinate = GPositionCoord(x: 0, y: 0);

  final sizeList = [
    "view size 100",
    "20% of view width",
    "20% of view height",
    "10 bars",
    "\$20 price",
  ];
  String sizeType = "view size 100";
  GSize size = GSize.viewSize(100);

  @override
  Widget build(BuildContext context) {
    final WorkshopState state = Provider.of<WorkshopState>(
      context,
      listen: true,
    );
    final chart = state.chart!;
    final panel = chart.panels[0];
    final graph = panel.findGraphById("g-ohlc")!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Column(
          children: [
            const ControlLabel(
              label: "coordinate",
              description:
                  "coordinate decides the location (x and y offset) where to draw the component.",
            ),
            AppToggleButtons<String>(
              minWidth: 240,
              maxWidth: 240,
              direction: Axis.vertical,
              items: coordinateList,
              labelResolver: (m) => m,
              selected: coordinateType,
              onSelected: (coordinateType) {
                setState(() {
                  this.coordinateType = coordinateType;
                  createMarker(state, chart, panel, graph);
                });
              },
            ),
            const ControlLabel(
              label: "size",
              description:
                  "size decides the dimension size (radius, length etc.) of the component.",
            ),
            AppToggleButtons<String>(
              minWidth: 240,
              maxWidth: 240,
              direction: Axis.vertical,
              items: sizeList,
              labelResolver: (m) => m,
              selected: sizeType,
              onSelected: (sizeType) {
                setState(() {
                  this.sizeType = sizeType;
                  createMarker(state, chart, panel, graph);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void createMarker(
    WorkshopState state,
    GChart chart,
    GPanel panel,
    GGraph graph,
  ) {
    graph.clearMarkers();
    final (coordinate, size, markerIndicators) = _getCoordinate(
      coordinateType,
      sizeType,
      chart,
      panel,
      graph,
    );
    this.coordinate = coordinate;
    this.size = size;

    graph.addMarker(
      GShapeMarker(
        anchorCoord: coordinate,
        radiusSize: size,
        pathGenerator: GShapes.circle,
      ),
    );
    graph.addMarker(
      GShapeMarker(
        anchorCoord: coordinate,
        radiusSize: GSize.viewSize(2),
        pathGenerator: GShapes.circle,
        theme: chart.theme.overlayMarkerTheme.copyWith(
          markerStyle: chart.theme.overlayMarkerTheme.markerStyle.copyWith(
            strokeWidth: 2,
          ),
        ),
      ),
    );

    for (final indicator in markerIndicators) {
      graph.addMarker(indicator);
    }

    state.notify();
  }

  (GCoordinate, GSize size, List<GOverlayMarker>) _getCoordinate(
    String coordinateType,
    String sizeType,
    GChart chart,
    GPanel panel,
    GGraph graph,
  ) {
    const x = 100.0;
    const y = 100.0;
    const xRatio = 0.3;
    const yRatio = 0.3;
    final xPercent = (xRatio * 100).toStringAsFixed(1);
    final yPercent = (yRatio * 100).toStringAsFixed(1);
    final size = getSize(sizeType, chart, panel, graph);
    switch (coordinateType) {
      case "absolute":
        final coord = GPositionCoord.absolute(x: x, y: y);
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = $x from top\n"
                  "y = $y from left\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.bottomRight,
            ),
          ],
        );
      case "absolute (inverted)":
        final coord = GPositionCoord.absolute(
          x: x,
          y: y,
          xIsInverted: true,
          yIsInverted: true,
        );
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = $x from bottom\n"
                  "y = $y from right\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.topLeft,
            ),
          ],
        );
      case "rational":
        final coord = GPositionCoord.rational(x: xRatio, y: yRatio);
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = $xPercent% of width from top\n"
                  "y = $yPercent% of height from left\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.bottomRight,
            ),
          ],
        );
      case "rational (inverted)":
        final coord = GPositionCoord.rational(
          x: xRatio,
          y: yRatio,
          xIsInverted: true,
          yIsInverted: true,
        );
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = $xPercent% of width from bottom\n"
                  "y = $yPercent% of height from right\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.topLeft,
            ),
          ],
        );
      case "viewport":
        final point = chart.dataSource.lastPoint;
        final coord = GViewPortCoord(
          point: point.toDouble(),
          value: chart.dataSource.getSeriesValue(point: point, key: keyClose)!,
        );
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = last point\n"
                  "y = last close value\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.bottomLeft,
            ),
          ],
        );
      case "mixed (absolute x, rational y)":
        final coord = GPositionCoord(
          x: x,
          y: yRatio,
          xIsRatio: false,
          yIsRatio: true,
        );
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = $x from left\n"
                  "y = $yPercent% of height from top\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.bottomRight,
            ),
          ],
        );
      case "mixed (viewport x, absolute y)":
        final point = chart.dataSource.lastPoint;
        const yFromBottom = 100.0;
        final coord = GCustomCoord(
          x: point.toDouble(),
          y: yFromBottom,
          coordinateConvertor: customConvertor,
          coordinateConvertorReverse: customConvertorReverse,
        );
        return (
          coord,
          size,
          [
            GCalloutMarker(
              text:
                  "x = last point\n"
                  "y = $yFromBottom from bottom\n"
                  "size(radius) = $sizeType",
              anchorCoord: coord,
              alignment: Alignment.topLeft,
            ),
          ],
        );
      default:
        throw ArgumentError("Unknown coordinate type: $coordinateType");
    }
  }

  GSize getSize(String sizeType, GChart chart, GPanel panel, GGraph graph) {
    switch (sizeType) {
      case "view size 100":
        return GSize.viewSize(100);
      case "20% of view width":
        return GSize.viewWidthRatio(0.2);
      case "20% of view height":
        return GSize.viewHeightRatio(0.2);
      case "10 bars":
        return GSize.pointSize(10.0);
      case "\$20 price":
        return GSize.valueSize(20);
      default:
        throw ArgumentError("Unknown size type: $sizeType");
    }
  }
}

Offset customConvertor({
  required double x,
  required double y,
  required Rect area,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  return Offset(pointViewPort.pointToPosition(area, x), area.bottom - y);
}

GCoordinate customConvertorReverse({
  required double x,
  required double y,
  required Rect area,
  required Offset position,
  required GPointViewPort pointViewPort,
  required GValueViewPort valueViewPort,
}) {
  double newX = pointViewPort.positionToPoint(area, position.dx);
  double newY = y;
  return GCustomCoord(
    x: newX,
    y: newY,
    coordinateConvertor: customConvertor,
    coordinateConvertorReverse: customConvertorReverse,
  );
}
