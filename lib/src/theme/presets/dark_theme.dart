import 'package:flutter/material.dart';

import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import '../theme.dart';

import '../../style/label_style.dart';
import '../../style/paint_style.dart';

import '../../graphs/bar/bar.dart';
import '../../graphs/bar/bar_theme.dart';
import '../../graphs/grids/grids.dart';
import '../../graphs/grids/grids_theme.dart';
import '../../graphs/line/line.dart';
import '../../graphs/line/line_theme.dart';
import '../../graphs/ohlc/ohlc.dart';
import '../../graphs/ohlc/ohlc_theme.dart';
import '../../graphs/area/area.dart';
import '../../graphs/area/area_theme.dart';

import '../../components/panel/panel_theme.dart';
import '../../components/axis/axis_theme.dart';
import '../../components/crosshair/crosshair_theme.dart';
import '../../components/splitter/splitter_theme.dart';
import '../../components/tooltip/tooltip_theme.dart';
import '../../components/background/background_theme.dart';
import '../../components/marker/marker_theme.dart';

/// Preset dark theme.
class GThemeDark extends GTheme {
  static const String themeName = 'dark';
  GThemeDark()
    : super(
        name: themeName,
        backgroundTheme: backgroundThemeDefault,
        panelTheme: panelThemeDefault,
        pointAxisTheme: pointAxisThemeDefault,
        valueAxisTheme: valueAxisThemeDefault,
        crosshairTheme: crosshairThemeDefault,
        tooltipTheme: tooltipThemeDefault,
        splitterTheme: splitterThemeDefault,
        graphThemes: {
          GGraph.typeName: GGraphTheme(
            axisMarkerTheme: axisMarkerThemeDefault,
            graphMarkerTheme: graphMarkerThemeDefault,
          ),
          GGraphGrids.typeName: gridsGraphTheme,
          GGraphOhlc.typeName: ohlcGraphTheme,
          GGraphLine.typeName: lineGraphTheme,
          GGraphBar.typeName: barGraphTheme,
          GGraphArea.typeName: areaGraphTheme,
        },
        axisMarkerTheme: axisMarkerThemeDefault,
        graphMarkerTheme: graphMarkerThemeDefault,
      );

  static final GBackgroundTheme backgroundThemeDefault = GBackgroundTheme(
    style: PaintStyle(),
  );

  static final GPanelTheme panelThemeDefault = GPanelTheme(
    style: PaintStyle(
      fillColor: const Color(0xFF0F0F0F),
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 0.5,
    ),
  );

  static final GAxisTheme pointAxisThemeDefault = GAxisTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFCCCCCC),
      strokeWidth: 1.0,
    ),
    tickerLength: 5.0,
    tickerStyle: PaintStyle(
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 1.0,
    ),
    selectionStyle: PaintStyle(
      fillColor: const Color(0x88BBBBFF),
      strokeColor: const Color(0xAABBBBFF),
      strokeWidth: 1.0,
    ),
    labelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10.0),
        backgroundStyle: PaintStyle(),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GAxisTheme valueAxisThemeDefault = GAxisTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFCCCCCC),
      strokeWidth: 1.0,
    ),
    tickerLength: 5.0,
    tickerStyle: PaintStyle(
      strokeColor: const Color(0xFFDDDDDD),
      strokeWidth: 1.0,
    ),
    selectionStyle: PaintStyle(
      fillColor: const Color(0x88BBBBFF),
      strokeColor: const Color(0xAABBBBFF),
    ),
    labelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10.0),
        backgroundStyle: PaintStyle(),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GCrosshairTheme crosshairThemeDefault = GCrosshairTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFFA0A0A0),
      strokeWidth: 1,
      dash: const [5, 5],
    ),
    pointLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFF222222), fontSize: 10.0),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFFDDDDDD)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
    valueLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFF222222), fontSize: 10.0),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFFDDDDDD)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
  );

  static final GTooltipTheme tooltipThemeDefault = GTooltipTheme(
    frameStyle: PaintStyle(
      fillColor: Colors.white.withAlpha(180),
      strokeColor: Colors.grey,
      strokeWidth: 1,
    ),
    labelStyle: LabelStyle(
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    valueStyle: LabelStyle(
      textStyle: const TextStyle(color: Colors.black, fontSize: 12.0),
    ),
    pointHighlightStyle: PaintStyle(fillColor: Colors.blue.withAlpha(120)),
    valueHighlightStyle: PaintStyle(strokeColor: Colors.blue, strokeWidth: 1),
  );

  static final GSplitterTheme splitterThemeDefault = GSplitterTheme(
    lineStyle: PaintStyle(
      strokeColor: Colors.grey.withAlpha(100),
      strokeWidth: 4,
    ),
    handleStyle: PaintStyle(fillColor: Colors.white, strokeColor: Colors.grey),
    handleLineStyle: PaintStyle(strokeColor: Colors.black, strokeWidth: 0.5),
    handleWidth: 80,
    handleBorderRadius: 4,
  );

  static final GGraphOhlcTheme ohlcGraphTheme = GGraphOhlcTheme(
    lineStylePlus: PaintStyle(strokeColor: Colors.redAccent, strokeWidth: 1),
    barStylePlus: PaintStyle(fillColor: Colors.redAccent),
    lineStyleMinus: PaintStyle(strokeColor: Colors.teal, strokeWidth: 1),
    barStyleMinus: PaintStyle(fillColor: Colors.teal),
    axisMarkerTheme: axisMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphLineTheme lineGraphTheme = GGraphLineTheme(
    lineStyle: PaintStyle(strokeColor: Colors.blue, strokeWidth: 1),
    pointStyle: PaintStyle(fillColor: Colors.blue),
    axisMarkerTheme: axisMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphGridsTheme gridsGraphTheme = GGraphGridsTheme(
    lineStyle: PaintStyle(
      strokeColor: const Color(0xFF333333),
      strokeWidth: 0.5,
    ),
    axisMarkerTheme: axisMarkerThemeDefault,
    graphMarkerTheme: graphMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphBarTheme barGraphTheme = GGraphBarTheme(
    barStyleAboveBase: PaintStyle(fillColor: Colors.teal.withAlpha(150)),
    barStyleBelowBase: PaintStyle(fillColor: Colors.red.withAlpha(150)),
    axisMarkerTheme: axisMarkerThemeDefault,
    graphMarkerTheme: graphMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GGraphAreaTheme areaGraphTheme = GGraphAreaTheme(
    styleValueAboveLine: PaintStyle(strokeColor: Colors.blue, strokeWidth: 1),
    styleValueBelowLine: PaintStyle(strokeColor: Colors.red, strokeWidth: 1),
    styleBaseLine: PaintStyle(strokeColor: Colors.blue, strokeWidth: 1),
    styleAboveArea: PaintStyle(
      fillGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.withAlpha(200), Colors.blue.withAlpha(100)],
      ),
      gradientBounds: const Rect.fromLTRB(0, 0, 1000, 1000),
    ),
    styleBelowArea: PaintStyle(
      fillGradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.red.withAlpha(200), Colors.red.withAlpha(100)],
      ),
      gradientBounds: const Rect.fromLTRB(0, 0, 1000, 1000),
    ),
    axisMarkerTheme: axisMarkerThemeDefault,
    graphMarkerTheme: graphMarkerThemeDefault,
    highlightMarkerTheme: graphHighlightMarkThemeDefault,
  );

  static final GAxisMarkerTheme axisMarkerThemeDefault = GAxisMarkerTheme(
    valueAxisLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFEEEEEE), fontSize: 10.0),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFF0000EE)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
    pointAxisLabelTheme: GAxisLabelTheme(
      labelStyle: LabelStyle(
        textStyle: const TextStyle(color: Color(0xFFEEEEEE), fontSize: 10.0),
        backgroundStyle: PaintStyle(fillColor: const Color(0xFF0000EE)),
        backgroundPadding: const EdgeInsets.all(2),
        backgroundCornerRadius: 2,
      ),
    ),
    valueRangeStyle: PaintStyle(fillColor: Colors.blue.withAlpha(150)),
    pointRangeStyle: PaintStyle(fillColor: Colors.blue.withAlpha(150)),
  );

  static final GGraphMarkerTheme graphMarkerThemeDefault = GGraphMarkerTheme(
    markerStyle: PaintStyle(
      fillColor: Colors.blueAccent.withAlpha(120),
      strokeColor: Colors.blue,
      strokeWidth: 2,
    ),
    controlPointsStyle: PaintStyle(
      fillColor: Colors.white,
      strokeColor: Colors.blueAccent,
      strokeWidth: 2,
    ),
    labelStyle: LabelStyle(
      textStyle: const TextStyle(color: Colors.black, fontSize: 10.0),
      backgroundStyle: PaintStyle(
        fillColor: Colors.white,
        strokeColor: Colors.black,
        strokeWidth: 1,
      ),
      backgroundPadding: const EdgeInsets.all(5),
      backgroundCornerRadius: 5,
    ),
  );

  static final GGraphHighlightMarkerTheme graphHighlightMarkThemeDefault =
      GGraphHighlightMarkerTheme(
        style: PaintStyle(
          strokeColor: Colors.black54,
          strokeWidth: 1,
          fillColor: Colors.white,
        ),
        size: 4.0,
        interval: 100.0,
        crosshairHighlightSize: 4.0,
      );
}
