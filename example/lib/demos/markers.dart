import 'dart:math';

import 'package:example/data/sample_data.dart';
import 'package:example/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:financial_chart/financial_chart.dart';

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
            viewPortId: 'price',
            position: GAxisPosition.end,
            scaleMode: GAxisScaleMode.zoom,
          ),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
        graphs: [
          GGraphGrids(id: "grids", valueViewPortId: 'price'),
          GGraphOhlc(
            id: "ohlc",
            visible: false,
            valueViewPortId: "price",
            drawAsCandle: true,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
          ),
          GGraphLine(
            id: "line",
            valueViewPortId: "price",
            valueKey: keySMA,
            graphMarkers: [
              GCalloutMarker(
                id: "c1",
                text: "This pins to \nfixed position of \nthe view port",
                anchorCoord: GPositionCoord.absolute(x: 0, y: 0),
                alignment: Alignment.bottomRight,
                theme: chartTheme.graphMarkerTheme.copyWith(
                  labelStyle: chartTheme.graphMarkerTheme.labelStyle!.copyWith(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              GRectMarker(
                startCoord: GPositionCoord.rational(x: 0, y: 0.1),
                endCoord: GPositionCoord.rational(x: 1, y: 0.2),
                theme: GGraphMarkerTheme(
                  markerStyle: PaintStyle(
                    fillColor: Colors.yellow.withAlpha(100),
                    strokeColor: Colors.yellow,
                  ),
                ),
              ),
              GArrowMarker(
                endCoord: GPositionCoord.rational(x: 0.5, y: 0.2),
                startCoord: GPositionCoord.rational(x: 0.5, y: 0.1),
              ),
              GLabelMarker(
                text:
                    "This area covers \n0.1 * height ~ 0.2 * height \nof the view port",
                anchorCoord: GPositionCoord.rational(x: 0.51, y: 0.15),
                alignment: Alignment.centerRight,
              ),
              if (dataSource.length > 0)
                GLineMarker(
                  coordinates: [
                    GCustomCoord(
                      x: 0,
                      y:
                          dataSource.getSeriesValue(
                            point: dataSource.lastPoint,
                            key: keySMA,
                          )!,
                      coordinateConvertor: kCoordinateConvertorXPositionYValue,
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
                  theme: GGraphMarkerTheme(
                    markerStyle: PaintStyle(strokeColor: Colors.orange),
                  ),
                ),
              GLineMarker(
                coordinates: [
                  GCustomCoord(
                    x: dataSource.lastPoint.toDouble(),
                    y: 0,
                    coordinateConvertor: kCoordinateConvertorXPointYPosition,
                  ),
                  GCustomCoord(
                    x: dataSource.lastPoint.toDouble(),
                    y: 1,
                    coordinateConvertor: kCoordinateConvertorXPointYPosition,
                  ),
                ],
                theme: GGraphMarkerTheme(
                  markerStyle: PaintStyle(strokeColor: Colors.orange),
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
                theme: GGraphMarkerTheme(
                  markerStyle: PaintStyle(
                    fillColor: Colors.red.withAlpha(100),
                    strokeColor: Colors.red,
                  ),
                ),
              ),
              GArcMarker.anchorAndRadius(
                anchorCoord: GViewPortCoord(
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
                close: true,
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
                ),
                endCoord: GCustomCoord(
                  x: dataSource.lastPoint.toDouble() - 60,
                  y: 1,
                  coordinateConvertor: kCoordinateConvertorXPointYPosition,
                ),
              ),
            ],
            axisMarkers: [
              GAxisMarker(
                points: [dataSource.lastPoint],
                pointRanges: [
                  GRange.range(
                    dataSource.lastPoint - 60,
                    dataSource.lastPoint - 50,
                  ),
                ],
                values: [
                  dataSource.getSeriesValue(
                    point: dataSource.lastPoint,
                    key: keySMA,
                  )!,
                ],
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildThemeSelectWidget(context),
        AppLabelWidget(
          label: "OHLC visible",
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
          label: "Callout position",
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
              (chart!.panels[0].findGraphById("line")!.findGraphMarker("c1")
                      as GCalloutMarker)
                  .alignment = Alignment(-selected.x, -selected.y);
              (chart!.panels[0].findGraphById("line")!.findGraphMarker("c1")
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
              -(chart!.panels[0].findGraphById("line")!.findGraphMarker("c1")
                      as GCalloutMarker)
                  .alignment
                  .x,
              -(chart!.panels[0].findGraphById("line")!.findGraphMarker("c1")
                      as GCalloutMarker)
                  .alignment
                  .y,
            ),
          ),
        ),
        AppLabelWidget(
          label: "Line graph visible",
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
          label: "Markers visible",
          child: AppPopupMenu<bool>(
            items: const [true, false],
            onSelected: (bool selected) {
              for (var marker
                  in chart!.panels[0].findGraphById("line")!.graphMarkers) {
                marker.visible = selected;
              }
              for (var marker
                  in chart!.panels[0].findGraphById("line")!.axisMarkers) {
                marker.visible = selected;
              }
              repaintChart();
            },
            selected:
                chart!.panels[0].findGraphById("line")!.graphMarkers[0].visible,
          ),
        ),
      ],
    );
  }
}
