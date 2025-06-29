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
                "Arrow",
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
      case "Arrow":
        marker = GArrowMarker(
          startCoord: coordinate,
          endCoord: GPositionCoord.rational(x: 0.8, y: 0.2),
        );
        break;
      case "callout":
        marker = GCalloutMarker(
          anchorCoord: coordinate,
          alignment: Alignment.topLeft,
          text:
              "I ran to where the sun shines and the wind blows soft, \nto where the grass is green and the water is clear. \nAnd I found peace.",
        );
        break;
      case "label":
        marker = GLabelMarker(
          anchorCoord: coordinate,
          alignment: Alignment.center,
          text: "You gotta put the past behind you before you can move on.",
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
      default:
        break;
    }

    if (marker != null) {
      graph.addMarker(marker);
    }
    state.notify();
  }
}
