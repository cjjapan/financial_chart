import 'package:example/data/data_source_builder.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/material.dart';

import '../../data/indicator_providers.dart';

const kVpVolume = 'vp-volume';
const kVpPrice = 'vp-price';
const kVpMacd = 'vp-macd';

class WorkshopState extends ChangeNotifier {
  final ValueNotifier<ThemeMode> themeMode;
  final GlobalKey<State<StatefulWidget>> workshopViewKey =
      GlobalKey<State<StatefulWidget>>();
  WorkshopState({required this.themeMode});

  String ticker = 'AAPL';

  void toggleMode() {
    mode = (mode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode get mode => themeMode.value;

  set mode(ThemeMode mode) {
    themeMode.value = mode;
    chart?.theme = (mode == ThemeMode.light) ? GThemeLight() : GThemeDark();
    notifyListeners();
  }

  GChart? chart;

  @override
  void dispose() {
    chart?.dispose();
    super.dispose();
  }

  void notify() {
    if (super.hasListeners) {
      chart?.repaint();
      notifyListeners();
    }
  }

  void loadData([bool resetTheme = false]) async {
    createDataSource(ticker: ticker, asyncDelayMillis: 0).then((data) {
      buildChart(data);
      if (resetTheme) {
        mode = ThemeMode.dark;
      }
      notify();
    });
  }

  void changeData() {
    ticker = (ticker == 'AAPL') ? 'GOOGL' : 'AAPL';
    loadData();
  }

  void buildChart(GDataSource dataSource) {
    final chartTheme = (mode == ThemeMode.light) ? GThemeLight() : GThemeDark();
    List<GPanel> panels = [
      GPanel(
        heightWeight: 0.7,
        valueAxes: [
          GValueAxis(
            viewPortId: kVpVolume,
            position: GAxisPosition.start,
            scaleMode: GAxisScaleMode.none,
          ),
          GValueAxis(viewPortId: kVpPrice, position: GAxisPosition.end),
        ],
        pointAxes: [
          GPointAxis(position: GAxisPosition.start),
          GPointAxis(position: GAxisPosition.end),
        ],
        valueViewPorts: [
          GValueViewPort(
            id: kVpPrice,
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              marginStart: GSize.viewHeightRatio(0.3),
              dataKeys: [
                keyHigh,
                keyLow,
                keySMA,
                keyIchimokuBase,
                keyIchimokuConversion,
                keyIchimokuSpanA,
                keyIchimokuSpanB,
                keyIchimokuLagging,
              ],
            ),
          ),
          GValueViewPort(
            id: kVpVolume,
            valuePrecision: 0,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyVolume],
              marginStart: GSize.viewSize(0),
              marginEnd: GSize.viewHeightRatio(0.7),
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "g-grids", valueViewPortId: kVpPrice),
          GGraphLine(id: "g-line", valueViewPortId: kVpPrice, valueKey: keySMA),
          GGraphBar(
            id: "g-bar",
            valueViewPortId: kVpVolume,
            valueKey: keyVolume,
            baseValue: 0,
          ),
          GGraphStackedBar(
            id: "g-stacked-bar",
            visible: false,
            valueViewPortId: kVpPrice,
            valueKeys: const [keyHigh, keyOpen, keyLow],
          ),
          GGraphOhlc(
            id: "g-ohlc",
            visible: true,
            valueViewPortId: kVpPrice,
            ohlcValueKeys: const [keyOpen, keyHigh, keyLow, keyClose],
            crosshairHighlightValueKeys: [keyHigh, keyLow],
          ),
          GGraphGroup(
            id: "g-group",
            valueViewPortId: kVpPrice,
            graphs: [
              GGraphLine(
                id: "ichi-base",
                visible: false,
                valueViewPortId: kVpPrice,
                valueKey: keyIchimokuBase,
                theme:
                    (chartTheme.graphThemes[GGraphLine.typeName]!
                            as GGraphLineTheme)
                        .copyWith(
                          lineStyle: PaintStyle(
                            strokeColor: Colors.red,
                            strokeWidth: 1.0,
                          ),
                        ),
              ),
              GGraphLine(
                id: "ichi-conv",
                valueViewPortId: kVpPrice,
                valueKey: keyIchimokuConversion,
                theme:
                    (chartTheme.graphThemes[GGraphLine.typeName]!
                            as GGraphLineTheme)
                        .copyWith(
                          lineStyle: PaintStyle(
                            strokeColor: Colors.yellow,
                            strokeWidth: 1.0,
                          ),
                        ),
              ),
              GGraphLine(
                id: "ichi-lagging",
                valueViewPortId: kVpPrice,
                valueKey: keyIchimokuLagging,
                theme:
                    (chartTheme.graphThemes[GGraphLine.typeName]!
                            as GGraphLineTheme)
                        .copyWith(
                          lineStyle: PaintStyle(
                            strokeColor: Colors.purple,
                            strokeWidth: 1.0,
                          ),
                        ),
              ),
              GGraphArea(
                id: "ichi-ab",
                valueViewPortId: kVpPrice,
                valueKey: keyIchimokuSpanA,
                baseValueKey: keyIchimokuSpanB,
              ),
            ],
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.followPointer,
          dataKeys: const [
            keyOpen,
            keyHigh,
            keyLow,
            keyClose,
            keyVolume,
            keySMA,
            // keyIchimokuBase,
            // keyIchimokuConversion,
            // keyIchimokuSpanA,
            // keyIchimokuSpanB,
            // keyIchimokuLagging,
          ],
          followValueKey: keyClose,
          followValueViewPortId: kVpPrice,
        ),
      ),
      GPanel(
        heightWeight: 0.3,
        valueAxes: [
          GValueAxis(viewPortId: kVpMacd, position: GAxisPosition.start),
          GValueAxis(viewPortId: kVpMacd, position: GAxisPosition.end),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
        valueViewPorts: [
          GValueViewPort(
            id: kVpMacd,
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [keyMACD],
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "g-grids2", valueViewPortId: kVpMacd),
          GGraphLine(id: "g-macd", valueViewPortId: kVpMacd, valueKey: keyMACD),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.topLeft,
          dataKeys: const [keyMACD],
          followValueKey: keyMACD,
          followValueViewPortId: kVpMacd,
        ),
      ),
    ];
    chart = GChart(
      dataSource: dataSource,
      pointViewPort: GPointViewPort(),
      panels: panels,
      theme: chartTheme,
    );
  }

  void addPanel() {
    if (chart == null || chart!.panels.length >= 3) {
      return;
    }
    const valueViewPort = kVpPrice;
    const valueKey = keyRSI;
    final currentHeightWeight = chart!.panels.fold(
      0.0,
      (v, p) => (v + p.heightWeight),
    );
    final newPanelHeightWeight = currentHeightWeight / 2.0;
    chart!.addPanel(
      GPanel(
        heightWeight: newPanelHeightWeight,
        valueAxes: [
          GValueAxis(viewPortId: valueViewPort, position: GAxisPosition.start),
          GValueAxis(viewPortId: valueViewPort, position: GAxisPosition.end),
        ],
        pointAxes: [GPointAxis(position: GAxisPosition.end)],
        valueViewPorts: [
          GValueViewPort(
            id: valueViewPort,
            valuePrecision: 2,
            autoScaleStrategy: GValueViewPortAutoScaleStrategyMinMax(
              dataKeys: [valueKey],
            ),
          ),
        ],
        graphs: [
          GGraphGrids(id: "g-grids3", valueViewPortId: valueViewPort),
          GGraphLine(
            id: "g-rsi",
            valueViewPortId: valueViewPort,
            valueKey: valueKey,
          ),
        ],
        tooltip: GTooltip(
          position: GTooltipPosition.topLeft,
          dataKeys: const [valueKey],
          followValueKey: valueKey,
          followValueViewPortId: valueViewPort,
        ),
      ),
    );
  }

  void removePanel() {
    if (chart == null || chart!.panels.length <= 2) {
      return;
    }
    chart!.removePanel(chart!.panels.last);
  }
}
