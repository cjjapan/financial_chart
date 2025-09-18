import 'package:financial_chart/financial_chart.dart';

import 'indicator_providers.dart';
import 'models.dart';
import 'data_input.dart';

Future<GDataSource<int, GData<int>>> createDataSource({
  String ticker = 'AAPL',
  int asyncDelayMillis = 200,
}) async {
  final OHLCDataInputAsync ohlcDataInput = await createAsyncDataInput(
    ticker,
    asyncDelayMillis: asyncDelayMillis,
  );

  const priceScale = 3;

  final seriesList = [
    (
      const GDataSeriesProperty(
        key: keyOpen,
        label: 'Open',
        precision: priceScale,
      ),
      IndicatorDataProviders.open(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyHigh,
        label: 'High',
        precision: priceScale,
      ),
      IndicatorDataProviders.high(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyLow,
        label: 'Low',
        precision: priceScale,
      ),
      IndicatorDataProviders.low(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyClose,
        label: 'Close',
        precision: priceScale,
      ),
      IndicatorDataProviders.close(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(key: keyVolume, label: 'Volume', precision: 0),
      IndicatorDataProviders.volume(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyRSI,
        label: 'RSI',
        precision: priceScale,
      ),
      IndicatorDataProviders.rsi(ohlcDataInput, 14),
    ),
    (
      const GDataSeriesProperty(
        key: keySMA,
        label: 'SMA',
        precision: priceScale,
      ),
      IndicatorDataProviders.sma(ohlcDataInput, 25),
    ),
    (
      const GDataSeriesProperty(
        key: keyBBL,
        label: 'BBL',
        precision: priceScale,
      ),
      IndicatorDataProviders.bbl(ohlcDataInput, period: 25, k: 2),
    ),
    (
      const GDataSeriesProperty(
        key: keyBBU,
        label: 'BBU',
        precision: priceScale,
      ),
      IndicatorDataProviders.bbu(ohlcDataInput, period: 25, k: 2),
    ),
    (
      const GDataSeriesProperty(
        key: keyCCI,
        label: 'CCI',
        precision: priceScale,
      ),
      IndicatorDataProviders.cci(ohlcDataInput, period: 14),
    ),
    (
      const GDataSeriesProperty(
        key: keyMACD,
        label: 'MACD',
        precision: priceScale,
      ),
      IndicatorDataProviders.macd(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keySlowStoch,
        label: 'Slow Stoch',
        precision: priceScale,
      ),
      IndicatorDataProviders.slowStochastic(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keySmoothedSlowStoch,
        label: 'Smoothed Slow Stoch',
        precision: priceScale,
      ),
      IndicatorDataProviders.smoothedSlowStochastic(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyFastStoch,
        label: 'Fast Stoch',
        precision: priceScale,
      ),
      IndicatorDataProviders.fastStochastic(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keySmoothedFastStoch,
        label: 'Smoothed Fast Stoch',
        precision: priceScale,
      ),
      IndicatorDataProviders.smoothedFastStochastic(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyIchimokuBase,
        label: 'Ichimoku Base',
        precision: priceScale,
      ),
      IndicatorDataProviders.ichimokuBase(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyIchimokuConversion,
        label: 'Ichimoku Conversion',
        precision: priceScale,
      ),
      IndicatorDataProviders.ichimokuConversion(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyIchimokuSpanA,
        label: 'Ichimoku Span A',
        precision: priceScale,
      ),
      IndicatorDataProviders.ichimokuSpanA(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyIchimokuSpanB,
        label: 'Ichimoku Span B',
        precision: priceScale,
      ),
      IndicatorDataProviders.ichimokuSpanB(ohlcDataInput),
    ),
    (
      const GDataSeriesProperty(
        key: keyIchimokuLagging,
        label: 'Ichimoku Lagging',
        precision: priceScale,
      ),
      IndicatorDataProviders.ichimokuLagging(ohlcDataInput),
    ),
  ];

  // synchronous data loading
  if (asyncDelayMillis <= 0) {
    final dataList = ohlcDataInput.entries
        .map(
          (e) => GData<int>(
            pointValue: e.time,
            seriesValues: [
              e.open,
              e.high,
              e.low,
              e.close,
              e.volume,
              ...List<double>.filled(seriesList.length - 5, double.infinity),
            ],
          ),
        )
        .toList();
    for (int s = 5; s < seriesList.length; s++) {
      seriesList[s].$2.rebuild();
      for (int i = 0; i < dataList.length; i++) {
        final value = seriesList[s].$2.sourceIndicator.getValue(i);
        dataList[i].seriesValues[s] = value.quote;
      }
    }
    return GDataSource(
      dataList: dataList,
      seriesProperties: seriesList.map((s) => s.$1).toList(),
    );
  }

  // async data loading
  final dataSource = GDataSource<int, GData<int>>(
    dataList: [],
    seriesProperties: seriesList.map((s) => s.$1).toList(),
    initialDataLoader: ({required int pointCount}) async {
      final loaded = await ohlcDataInput.loadPrior(
        pointCount,
        DateTime.now().millisecondsSinceEpoch,
      );
      if (loaded.isEmpty) {
        return [];
      }
      return loaded.map((e) {
        return GData<int>(
          pointValue: e.time,
          seriesValues: [
            e.open,
            e.high,
            e.low,
            e.close,
            e.volume,
            ...List<double>.filled(seriesList.length - 5, double.infinity),
          ],
        );
      }).toList();
    },
    priorDataLoader:
        ({
          required int toPointExclusive,
          required int toPointValueExclusive,
          required int pointCount,
        }) async {
          final loaded = await ohlcDataInput.loadPrior(
            pointCount,
            toPointValueExclusive,
          );
          if (loaded.isEmpty) {
            return [];
          }
          return loaded.map((e) {
            return GData<int>(
              pointValue: e.time,
              seriesValues: [
                e.open,
                e.high,
                e.low,
                e.close,
                e.volume,
                ...List<double>.filled(seriesList.length - 5, double.infinity),
              ],
            );
          }).toList();
        },
    afterDataLoader:
        ({
          required int fromPointExclusive,
          required int fromPointValueExclusive,
          required int pointCount,
        }) async {
          final loaded = await ohlcDataInput.loadAfter(
            pointCount,
            fromPointValueExclusive,
          );
          if (loaded.isEmpty) {
            return [];
          }
          return loaded.map((e) {
            return GData<int>(
              pointValue: e.time,
              seriesValues: [
                e.open,
                e.high,
                e.low,
                e.close,
                e.volume,
                ...List<double>.filled(seriesList.length, double.infinity),
              ],
            );
          }).toList();
        },
    // this is called when the data source is updated with new data
    dataLoaded: (dataSource) async {
      // update indicator values.
      // this could be optimized to copy only the updated values.
      for (int s = 5; s < seriesList.length; s++) {
        seriesList[s].$2.rebuild();
        for (int i = 0; i < dataSource.dataList.length; i++) {
          final value = seriesList[s].$2.sourceIndicator.getValue(i);
          dataSource.dataList[i].seriesValues[s] = value.quote;
        }
      }
    },
  );
  return dataSource;
}
