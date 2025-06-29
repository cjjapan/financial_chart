import 'dart:math';

import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

import '../../data/indicator_providers.dart';
import '../widgets/label_widget.dart';
import 'demo.dart';

class DemoMarkersPage extends DemoBasePage {
  const DemoMarkersPage({super.key}) : super(title: 'Markers');

  @override
  DemoMarkersPageState createState() => DemoMarkersPageState();
}

class DemoMarkersPageState extends DemoBasePageState {
  DemoMarkersPageState();

  @override
  int get simulateDataLatencyMillis => 0; // disable async data which needed to create sample markers from data

  @override
  GChart buildChart(GDataSource dataSource) {
    final chartTheme = themes.first;
    List<GPanel> panels = [
      GPanel(
        valueViewPorts: [
          GValueViewPort(
            id: "price",
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyHigh, keyLow],
            ),
          ),
        ],
        valueAxes: [
          GValueAxis(
            size: 80,
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
            axisMarkers: [
              GValueAxisMarker.label(
                labelValue:
                    dataSource.getSeriesValue(
                      point: dataSource.lastPoint,
                      key: keySMA,
                    )!,
              ),
            ],
            overlayMarkers: [
              GLabelMarker(
                id: "a marker to show a title in axis",
                text: "Price in dollar",
                anchorCoord: GPositionCoord.rational(x: 0.75, y: 0.5),
                alignment: Alignment.center,
                theme: chartTheme.overlayMarkerTheme.copyWith(
                  markerStyle: PaintStyle(),
                  labelStyle: LabelStyle(
                    textStyle: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 20.0,
                    ),
                    backgroundStyle: PaintStyle(),
                    backgroundPadding: const EdgeInsets.all(5),
                    backgroundCornerRadius: 0,
                    rotation: pi / 2,
                  ),
                ),
              ),
            ],
          ),
        ],
        pointAxes: [
          GPointAxis(
            position: GAxisPosition.end,
            axisMarkers: [
              GPointAxisMarker.label(point: dataSource.lastPoint),
              GPointAxisMarker.range(
                startPoint: dataSource.lastPoint - 60,
                endPoint: dataSource.lastPoint - 50,
              ),
            ],
          ),
        ],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            visible: true,
            valueViewPortId: "price",
            drawAsCandle: true,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
          ),
          GGraphLine(
            id: "line",
            valueViewPortId: "price",
            valueKey: keySMA,
            overlayMarkers: [
              GCalloutMarker(
                id: "c1",
                text:
                    "A GCalloutMarker. "
                    "\nIt pins to specified position of the view port.",
                anchorCoord: GPositionCoord.absolute(x: 0, y: 0),
                alignment: Alignment.bottomRight,
                theme: chartTheme.overlayMarkerTheme.copyWith(
                  labelStyle: chartTheme.overlayMarkerTheme.labelStyle!
                      .copyWith(
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                ),
              ),
              GRectMarker(
                startCoord: GPositionCoord.rational(x: 0, y: 0.1),
                endCoord: GPositionCoord.rational(x: 1, y: 0.2),
                theme: GOverlayMarkerTheme(
                  markerStyle: PaintStyle(
                    fillColor: Colors.yellow.withAlpha(100),
                    strokeColor: Colors.yellow,
                  ),
                  controlHandleThemes:
                      chartTheme.overlayMarkerTheme.controlHandleThemes,
                ),
              ),
              GArrowMarker(
                endCoord: GPositionCoord.rational(x: 0.5, y: 0.2),
                startCoord: GPositionCoord.rational(x: 0.5, y: 0.1),
              ),
              GLabelMarker(
                text:
                    "This area covers "
                    "\n0.1 * height ~ 0.2 * height "
                    "\nof the view port",
                anchorCoord: GPositionCoord.rational(x: 0.51, y: 0.15),
                alignment: Alignment.centerRight,
              ),
              if (dataSource.length > 0)
                GPolyLineMarker(
                  coordinates: [
                    GCustomCoord(
                      x: 0,
                      y:
                          dataSource.getSeriesValue(
                            point: dataSource.lastPoint,
                            key: keySMA,
                          )!,
                      coordinateConvertor: kCoordinateConvertorXPositionYValue,
                      coordinateConvertorReverse:
                          kCoordinateConvertorXPositionYValueReverse,
                    ),
                    GViewPortCoord(
                      point: dataSource.lastPoint.toDouble(),
                      value:
                          dataSource.getSeriesValue(
                            point: dataSource.lastPoint,
                            key: keySMA,
                          )!,
                    ),
                  ],
                  theme: GOverlayMarkerTheme(
                    markerStyle: PaintStyle(strokeColor: Colors.orange),
                    controlHandleThemes:
                        chartTheme.overlayMarkerTheme.controlHandleThemes,
                  ),
                ),
              GPolyLineMarker(
                coordinates: [
                  GCustomCoord(
                    x: dataSource.lastPoint.toDouble(),
                    y: 0,
                    coordinateConvertor: kCoordinateConvertorXPointYPosition,
                    coordinateConvertorReverse:
                        kCoordinateConvertorXPositionYValueReverse,
                  ),
                  GCustomCoord(
                    x: dataSource.lastPoint.toDouble(),
                    y: 1,
                    coordinateConvertor: kCoordinateConvertorXPointYPosition,
                    coordinateConvertorReverse:
                        kCoordinateConvertorXPositionYValueReverse,
                  ),
                ],
                theme: GOverlayMarkerTheme(
                  markerStyle: PaintStyle(strokeColor: Colors.orange),
                  controlHandleThemes:
                      chartTheme.overlayMarkerTheme.controlHandleThemes,
                ),
              ),
              GOvalMarker.anchorAndRadius(
                anchorCoord: GViewPortCoord(
                  point: dataSource.lastPoint.toDouble() + 5,
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint,
                        key: keySMA,
                      )!,
                ),
                pointRadiusSize: GSize.viewSize(10),
                valueRadiusSize: GSize.viewSize(10),
                alignment: Alignment.center,
                theme: GOverlayMarkerTheme(
                  markerStyle: PaintStyle(
                    fillColor: Colors.red.withAlpha(100),
                    strokeColor: Colors.red,
                  ),
                  controlHandleThemes:
                      chartTheme.overlayMarkerTheme.controlHandleThemes,
                ),
              ),
              GArcMarker.anchorAndRadius(
                centerOCoord: GViewPortCoord(
                  point: dataSource.lastPoint.toDouble(),
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint,
                        key: keySMA,
                      )!,
                ),
                radiusSize: GSize.viewSize(30),
                alignment: Alignment.center,
                startTheta: pi * 1 / 8,
                endTheta: pi * 15 / 8,
                closeType: GArcCloseType.center,
              ),
              GShapeMarker(
                anchorCoord: GViewPortCoord(
                  point: (dataSource.lastPoint - 10).toDouble(),
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint - 10,
                        key: keySMA,
                      )!,
                ),
                radiusSize: GSize.viewSize(20),
                pathGenerator: GShapes.heart,
              ),
              GShapeMarker(
                anchorCoord: GViewPortCoord(
                  point: (dataSource.lastPoint - 20).toDouble(),
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint - 20,
                        key: keySMA,
                      )!,
                ),
                radiusSize: GSize.viewSize(20),
                pathGenerator: (radius) => GShapes.circle(radius),
              ),
              GShapeMarker(
                anchorCoord: GViewPortCoord(
                  point: (dataSource.lastPoint - 30).toDouble(),
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint - 30,
                        key: keySMA,
                      )!,
                ),
                radiusSize: GSize.viewSize(20),
                pathGenerator:
                    (radius) => GShapes.polygon(radius, vertexCount: 6),
              ),
              GShapeMarker(
                anchorCoord: GViewPortCoord(
                  point: (dataSource.lastPoint - 40).toDouble(),
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint - 40,
                        key: keySMA,
                      )!,
                ),
                radiusSize: GSize.viewSize(20),
                pathGenerator: (radius) => GShapes.star(radius, vertexCount: 5),
                rotation: 15 * pi / 180,
              ),
              GCalloutMarker(
                text: "This\nmoves\nwhile\nthe\ngraph\nmoving",
                anchorCoord: GViewPortCoord(
                  point: dataSource.lastPoint.toDouble() + 7,
                  value:
                      dataSource.getSeriesValue(
                        point: dataSource.lastPoint,
                        key: keySMA,
                      )!,
                ),
                alignment: Alignment.centerRight,
              ),
              GRectMarker(
                startCoord: GCustomCoord(
                  x: dataSource.lastPoint.toDouble() - 50,
                  y: 0,
                  coordinateConvertor: kCoordinateConvertorXPointYPosition,
                  coordinateConvertorReverse:
                      kCoordinateConvertorXPointYPositionReverse,
                ),
                endCoord: GCustomCoord(
                  x: dataSource.lastPoint.toDouble() - 60,
                  y: 1,
                  coordinateConvertor: kCoordinateConvertorXPointYPosition,
                  coordinateConvertorReverse:
                      kCoordinateConvertorXPointYPositionReverse,
                ),
              ),
            ],
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.none,
          dataKeys: const [
            keyOpen,
            keyHigh,
            keyLow,
            keyClose,
            keyVolume,
            keySMA,
            keyIchimokuSpanA,
            keyIchimokuSpanB,
          ],
          followValueKey: keyClose,
          followValueViewPortId: "price",
          pointLineHighlightVisible: false,
          valueLineHighlightVisible: false,
        ),
      ),
    ];
    return GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(
        autoScaleStrategy: const GPointViewPortAutoScaleStrategyLatest(
          endSpacingPoints: 20,
        ),
      ),
      panels: panels,
      theme: chartTheme,
    );
  }

  @override
  Widget buildControlPanel(BuildContext context) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "GGraphLine.visible",
          description:
              "Show/hide the line graph. "
              "\nwhen the graph is hidden, the overlay markers on the graph will be hidden too.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("line")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("line")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "GGraphOhlc.visible",
          description: "Show/hide the OHLC graph. ",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              chart!.panels[0].findGraphById("ohlc")!.visible = selected;
              repaintChart();
            },
            selected: chart!.panels[0].findGraphById("ohlc")!.visible,
          ),
        ),
        AppLabelWidget(
          label: "GCalloutMarker.alignment",
          description: "Change the alignment of the callout marker.",
          child: AppPopupMenu<Alignment>(
            items: const [
              Alignment.topLeft,
              Alignment.topCenter,
              Alignment.topRight,
              Alignment.bottomLeft,
              Alignment.bottomCenter,
              Alignment.bottomRight,
              Alignment.centerLeft,
              Alignment.center,
              Alignment.centerRight,
            ],
            onSelected: (Alignment selected) {
              (chart!.panels[0].findGraphById("line")!.findMarker("c1")
                      as GCalloutMarker)
                  .alignment = Alignment(-selected.x, -selected.y);
              (chart!.panels[0].findGraphById("line")!.findMarker("c1")
                      as GCalloutMarker)
                  .keyCoordinates
                ..clear()
                ..add(
                  GPositionCoord.rational(
                    x: selected.x * 0.5 + 0.5,
                    y: selected.y * 0.5 + 0.5,
                  ),
                );
              repaintChart();
            },
            selected: Alignment(
              -(chart!.panels[0].findGraphById("line")!.findMarker("c1")
                      as GCalloutMarker)
                  .alignment
                  .x,
              -(chart!.panels[0].findGraphById("line")!.findMarker("c1")
                      as GCalloutMarker)
                  .alignment
                  .y,
            ),
          ),
        ),
        AppLabelWidget(
          label: "GOverlayMarker.visible",
          description:
              "Show/hide the overlay markers. "
              "\noverlay markers can be placed on graphs and also axes.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (final marker
                  in chart!.panels[0].findGraphById("line")!.overlayMarkers) {
                marker.visible = selected;
              }
              for (final marker
                  in chart!.panels[0].findGraphById("line")!.overlayMarkers) {
                marker.visible = selected;
              }
              for (final panel in chart!.panels) {
                for (final axis in panel.valueAxes) {
                  for (final marker in axis.overlayMarkers) {
                    marker.visible = selected;
                  }
                }
                for (final axis in panel.pointAxes) {
                  for (final marker in axis.overlayMarkers) {
                    marker.visible = selected;
                  }
                }
              }
              repaintChart();
            },
            selected:
                chart!.panels[0]
                    .findGraphById("line")!
                    .overlayMarkers[0]
                    .visible,
          ),
        ),
        AppLabelWidget(
          label: "GAxisMarker.visible",
          description: "Show/hide the axis markers.",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (final panel in chart!.panels) {
                for (final axis in panel.valueAxes) {
                  for (final marker in axis.axisMarkers) {
                    marker.visible = selected;
                  }
                }
                for (final axis in panel.pointAxes) {
                  for (final marker in axis.axisMarkers) {
                    marker.visible = selected;
                  }
                }
              }
              repaintChart();
            },
            selected: chart!.panels[0].valueAxes[0].axisMarkers[0].visible,
          ),
        ),
      ],
    );
  }
}
