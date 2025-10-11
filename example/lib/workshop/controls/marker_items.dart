import 'dart:math';

import 'package:example/widgets/toggle_buttons.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../workshop_state.dart';

class MarkerItemsControlView extends StatefulWidget {
  const MarkerItemsControlView({super.key});

  @override
  State<MarkerItemsControlView> createState() => _MarkerItemsControlViewState();
}

class _MarkerItemsControlViewState extends State<MarkerItemsControlView> {
  String currentMarkerType = "";

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
            AppToggleButtons<String>(
              minWidth: 240,
              maxWidth: 240,
              direction: Axis.vertical,
              items: const [
                "Arc 1",
                "Arc 2",
                "Arrow 1",
                "Arrow 2",
                "crossline 1",
                "crossline 2",
                "statsLine 1",
                "statsLine 2",
                "fibonacci retracement",
                "fibonacci circle",
                "fibonacci arc 1",
                "fibonacci arc 2",
                "fibonacci resistance fan 1",
                "fibonacci resistance fan 2",
                "fibonacci timezone 1",
                "fibonacci timezone 2",
                "callout",
                "label",
                "oval",
                "polygon",
                "polyline",
                "rect 1",
                "rect 2",
                "heart",
                "star",
                "spline",
                "svg",
              ],
              labelResolver: (m) => m,
              selected: currentMarkerType,
              onSelected: (coordinateType) {
                setState(() {
                  currentMarkerType = coordinateType;
                  createMarker(coordinateType, state, chart, panel, graph);
                });
              },
            ),
            const SizedBox(height: 10),
            AppToggleButtons<String>(
              minWidth: 160,
              maxWidth: 240,
              direction: Axis.vertical,
              items: const ["CLEAR"],
              labelResolver: (m) => m,
              selected: currentMarkerType,
              onSelected: (coordinateType) {
                setState(() {
                  currentMarkerType = "CLEAR";
                  graph.clearMarkers();
                  state.notify();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  void createMarker(
    String markerType,
    WorkshopState state,
    GChart chart,
    GPanel panel,
    GGraph graph,
  ) {
    graph.clearMarkers();
    final coordinate = GPositionCoord.rational(x: 0.5, y: 0.5);
    GOverlayMarker? marker;
    switch (markerType) {
      case "Arc 1":
        marker = GArcMarker.anchorAndRadius(
          centerOCoord: coordinate,
          alignment: Alignment.center,
          radiusSize: GSize.viewSize(100),
          startTheta: -pi / 4,
          endTheta: pi / 4,
          closeType: GArcCloseType.center,
        );
        break;
      case "Arc 2":
        marker = GArcMarker.anchorAndRadius(
          centerOCoord: coordinate,
          alignment: Alignment.center,
          radiusSize: GSize.viewSize(100),
          startTheta: pi / 4,
          endTheta: pi * 7 / 4,
          closeType: GArcCloseType.none,
        );
        break;
      case "Arrow 1":
        marker = GArrowLineMarker(
          startCoord: coordinate,
          endCoord: GPositionCoord.rational(x: 0.8, y: 0.2),
        );
        break;
      case "Arrow 2":
        marker = GArrowLineMarker(
          startCoord: coordinate,
          endCoord: GPositionCoord.rational(x: 0.8, y: 0.2),
          startHead: GArrowHead(type: GArrowHeadType.diamond),
          endHead: GArrowHead(type: GArrowHeadType.stealth),
        );
        break;
      case "crossline 1":
        marker = GCrosslineMarker(anchor: coordinate);
        break;
      case "crossline 2":
        final point = (chart.pointViewPort.endPoint.toInt() - 10);
        marker = GCrosslineMarker(
          anchor: GViewPortCoord(
            point: point.toDouble(),
            value:
                chart.dataSource.getSeriesValue(point: point, key: "close") ??
                chart.dataSource.getSeriesValue(
                  point: chart.dataSource.lastPoint,
                  key: "close",
                )!,
          ),
          rightRay: false,
        );
        break;
      case "statsLine 1":
        marker = GStatsLineMarker(
          startCoord: GPositionCoord.rational(x: 0.1, y: 0.5),
          endCoord: GPositionCoord.rational(x: 0.5, y: 0.9),
          theme: chart.theme.overlayMarkerTheme.copyWith(
            labelStyle: chart.theme.overlayMarkerTheme.labelStyle?.copyWith(
              backgroundStyle: PaintStyle(),
            ),
          ),
        );
        break;
      case "statsLine 2":
        marker = GStatsLineMarker(
          startCoord: GPositionCoord.rational(x: 0.1, y: 0.9),
          endCoord: GPositionCoord.rational(x: 0.5, y: 0.5),
          statsBoxPosition: 0.5,
          startRay: true,
          endRay: true,
          showAngleStats: true,
          showPointStats: false,
          showValueStats: false,
          showDistance: false,
          fillStyle: GStatsLineFillStyle.triangle,
        );
        break;
      case "fibonacci retracement":
        marker = GFibRetracementMarker(
          startCoord: GPositionCoord.rational(x: 0.3, y: 0.3),
          endCoord: GPositionCoord.rational(x: 0.7, y: 0.7),
          startRay: false,
          endRay: false,
        );
        break;
      case "fibonacci circle":
        marker = GFibCircleMarker(
          startCoord: GPositionCoord.rational(x: 0.5, y: 0.5),
          endCoord: GPositionCoord.rational(x: 0.7, y: 0.7),
        );
        break;
      case "fibonacci arc 1":
        marker = GFibArcMarker(
          startCoord: GPositionCoord.rational(x: 0.5, y: 0.5),
          endCoord: GPositionCoord.rational(x: 0.7, y: 0.7),
          startTheta: 0,
          endTheta: pi,
        );
        break;
      case "fibonacci arc 2":
        marker = GFibArcMarker(
          startCoord: GPositionCoord.rational(x: 0.5, y: 0.5),
          endCoord: GPositionCoord.rational(x: 0.7, y: 0.7),
          startTheta: pi + pi / 2,
          endTheta: 2 * pi - pi / 8,
        );
        break;
      case "fibonacci resistance fan 1":
        marker = GFibResistanceFanMarker(
          startCoord: GPositionCoord.rational(x: 0.3, y: 0.7),
          endCoord: GPositionCoord.rational(x: 0.8, y: 0.3),
        );
        break;
      case "fibonacci resistance fan 2":
        marker = GFibResistanceFanMarker(
          startCoord: GPositionCoord.rational(x: 0.7, y: 0.3),
          endCoord: GPositionCoord.rational(x: 0.3, y: 0.7),
          extendRay: false,
          showPointLevelStartLabels: false,
          showValueLevelStartLabels: false,
          theme: chart.theme.overlayMarkerTheme.copyWith(
            labelStyle: chart.theme.overlayMarkerTheme.labelStyle?.copyWith(
              backgroundStyle: PaintStyle(),
            ),
          ),
        );
        break;
      case "fibonacci timezone 1":
        final startPoint = (chart.pointViewPort.startPoint + 1)
            .ceil()
            .toDouble();
        marker = GFibTimeZoneMarker(
          startCoord: GCustomCoord(
            x: startPoint.toDouble(),
            y: 0.5,
            coordinateConvertor: kCoordinateConvertorXPointYPosition,
            coordinateConvertorReverse:
                kCoordinateConvertorXPointYPositionReverse,
          ),
          endCoord: GCustomCoord(
            x: startPoint.toDouble() + 1.0,
            y: 0.5,
            coordinateConvertor: kCoordinateConvertorXPointYPosition,
            coordinateConvertorReverse:
                kCoordinateConvertorXPointYPositionReverse,
          ),
        );
        break;
      case "fibonacci timezone 2":
        final endPoint = (chart.pointViewPort.endPoint - 1).floor().toDouble();
        marker = GFibTimeZoneMarker(
          startCoord: GCustomCoord(
            x: endPoint,
            y: 0.5,
            coordinateConvertor: kCoordinateConvertorXPointYPosition,
            coordinateConvertorReverse:
                kCoordinateConvertorXPointYPositionReverse,
          ),
          endCoord: GCustomCoord(
            x: endPoint - 2.0,
            y: 0.5,
            coordinateConvertor: kCoordinateConvertorXPointYPosition,
            coordinateConvertorReverse:
                kCoordinateConvertorXPointYPositionReverse,
          ),
        );
        break;
      case "callout":
        marker = GCalloutMarker(
          anchorCoord: coordinate,
          alignment: Alignment.topLeft,
          text:
              "A long long long long long long message line 1\nA long message line 2. \nA long message line 3. \nA long message line 4. \nA long message line 5.",
        );
        break;
      case "label":
        marker = GLabelMarker(
          anchorCoord: coordinate,
          alignment: Alignment.center,
          text: "Some message.",
        );
        break;
      case "oval":
        marker = GOvalMarker.anchorAndRadius(
          anchorCoord: coordinate,
          pointRadiusSize: GSize.viewWidthRatio(0.2),
          valueRadiusSize: GSize.viewHeightRatio(0.2),
          alignment: Alignment.center,
        );
        break;
      case "polygon":
        marker = GPolygonMarker(
          coordinates: List.generate(
            6,
            (i) => GPositionCoord.rational(
              x: 0.5 + 0.1 * cos(2 * pi * i / 6),
              y: 0.5 + 0.15 * sin(2 * pi * i / 6),
            ),
          ),
          close: true,
        );
        break;
      case "polyline":
        marker = GPolyLineMarker(
          coordinates: List.generate(
            11,
            (i) => GPositionCoord.rational(
              x: 0 + 0.1 * i,
              y: 0.5 + (i % 2 == 0 ? -0.1 : 0.1),
            ),
          ),
        );
        break;
      case "rect 1":
        marker = GRectMarker.anchorAndRadius(
          anchorCoord: coordinate,
          pointRadiusSize: GSize.viewWidthRatio(0.2),
          valueRadiusSize: GSize.viewHeightRatio(0.2),
          cornerRadiusSize: GSize.valueSize(0),
          alignment: Alignment.center,
        );
        break;
      case "rect 2":
        marker = GRectMarker.anchorAndRadius(
          anchorCoord: coordinate,
          pointRadiusSize: GSize.viewWidthRatio(0.2),
          valueRadiusSize: GSize.viewHeightRatio(0.2),
          cornerRadiusSize: GSize.viewMinRatio(0.1),
          alignment: Alignment.center,
        );
        break;
      case "heart":
        marker = GShapeMarker(
          anchorCoord: coordinate,
          radiusSize: GSize.viewSize(50),
          pathGenerator: GShapes.heart,
        );
        break;
      case "star":
        marker = GShapeMarker(
          anchorCoord: coordinate,
          radiusSize: GSize.viewSize(50),
          pathGenerator: (r) => GShapes.star(r, vertexCount: 5),
          rotation: pi / 2,
        );
        break;
      case "spline":
        marker = GSplineMarker(
          coordinates: List.generate(
            11,
            (i) => GPositionCoord.rational(
              x: 0 + 0.1 * i,
              y: 0.5 + (i % 2 == 0 ? 0.1 : -0.1) * ((i > 0 && i < 10) ? 2 : 0),
            ),
          ),
        );
        break;
      case "svg":
        marker = GSvgMarker(
          anchorPosition: coordinate,
          alignment: Alignment.center,
          size: Size(120, 120),
          svgAssetKey: "assets/flutter.svg",
        );
        break;
      default:
        break;
    }

    if (marker != null) {
      graph.addMarker(marker);
    }
    state.notify();
  }
}
