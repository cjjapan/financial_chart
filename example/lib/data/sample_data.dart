import 'dart:math';

import 'package:deriv_technical_analysis/deriv_technical_analysis.dart';
import 'package:financial_chart/financial_chart.dart';
import 'package:flutter/foundation.dart';
import 'sample_data_loader.dart';

const String keyOpen = "open";
const String keyHigh = "high";
const String keyLow = "low";
const String keyClose = "close";
const String keyVolume = "volume";
const String keySMA = "sma";
const String keyEMA = "ema";
const String keyMACD = "macd";
const String keyMACDHist = "macdHist";
const String keyIchimokuBase = "ichimokuBase";
const String keyIchimokuConversion = "ichimokuConversion";
const String keyIchimokuSpanA = "ichimokuSpanA";
const String keyIchimokuSpanB = "ichimokuSpanB";
const String keyIchimokuLagging = "ichimokuLagging";
const String keyFastStoch = "fastStoch";
const String keySmoothedFastStoch = "smoothedFastStoch";
const String keySlowStoch = "slowStoch";
const String keySmoothedSlowStoch = "smoothedSlowStoch";
const String keyBBL = "bbl";
const String keyBBU = "bbu";
const String keyRSI = "rsi";
const String keyADX = "adx";

Future<GDataSource> loadSampleData({
  int simulateLatencyMillis = 0,
  bool simulateEmpty = false,
}) async {
  // const String ticker = '^GSPC';
  // const String ticker = 'GOOGL';
  const String ticker = 'AAPL';
  const pricePrecision = 2;
  final response = await loadYahooFinanceData(ticker);

  final indicatorInput = IndicatorInputImpl(
    response.candlesData.map((e) {
      return IndicatorOHLCImpl(e.open, e.close, e.high, e.low);
    }).toList(),
  );

  final smaIndicator = SMAIndicator<IndicatorResultImpl>(
    CloseValueIndicator(indicatorInput),
    14,
  );
  final emaIndicator = EMAIndicator<IndicatorResultImpl>(
    CloseValueIndicator(indicatorInput),
    14,
  );
  final macdIndicator = MACDIndicator<IndicatorResultImpl>(indicatorInput);
  final macdHistogramIndicator =
      MACDHistogramIndicator<IndicatorResultImpl>.fromIndicator(
        macdIndicator,
        SignalMACDIndicator<IndicatorResultImpl>.fromIndicator(
          MACDIndicator<IndicatorResultImpl>(indicatorInput),
        ),
      );
  final ichimokuBase = IchimokuBaseLineIndicator<IndicatorResultImpl>(
    indicatorInput,
  );
  final ichimokuConversion =
      IchimokuConversionLineIndicator<IndicatorResultImpl>(indicatorInput);
  final ichimokuSpanA = IchimokuSpanAIndicator<IndicatorResultImpl>(
    indicatorInput,
  );
  final ichimokuSpanB = IchimokuSpanBIndicator<IndicatorResultImpl>(
    indicatorInput,
  );
  final ichimokuLagging = IchimokuLaggingSpanIndicator<IndicatorResultImpl>(
    indicatorInput,
  );
  final fastStoch = FastStochasticIndicator(indicatorInput);
  final smoothedFastStoch = SmoothedFastStochasticIndicator(fastStoch);
  final slowStoch = SlowStochasticIndicator(indicatorInput);
  final smoothedSlowStoch = SmoothedSlowStochasticIndicator(slowStoch);
  final bbl = BollingerBandsLowerIndicator(
    smaIndicator,
    StandardDeviationIndicator(CloseValueIndicator(indicatorInput), 14),
  );
  final bbu = BollingerBandsUpperIndicator(
    smaIndicator,
    StandardDeviationIndicator(CloseValueIndicator(indicatorInput), 14),
  );
  final rsi = RSIIndicator.fromIndicator(
    CloseValueIndicator(indicatorInput),
    14,
  );
  final adx = ADXIndicator(indicatorInput);

  final sma = smaIndicator.calculateValues();
  final ema = emaIndicator.calculateValues();
  final macd = macdIndicator.calculateValues();
  final macdHistogram = macdHistogramIndicator.calculateValues();
  final ichimokuBaseValues = ichimokuBase.calculateValues();
  final ichimokuConversionValues = ichimokuConversion.calculateValues();
  final ichimokuSpanAValues = ichimokuSpanA.calculateValues();
  final ichimokuSpanBValues = ichimokuSpanB.calculateValues();
  final ichimokuLaggingValues = ichimokuLagging.calculateValues();
  final fastStochValues = fastStoch.calculateValues();
  final smoothedFastStochValues = smoothedFastStoch.calculateValues();
  final slowStochValues = slowStoch.calculateValues();
  final smoothedSlowStochValues = smoothedSlowStoch.calculateValues();
  final bblValues = bbl.calculateValues();
  final bbuValues = bbu.calculateValues();
  final rsiValues = rsi.calculateValues();
  final adxValues = adx.calculateValues();

  const seriesProperties = [
    GDataSeriesProperty(key: keyOpen, label: 'Open', precision: pricePrecision),
    GDataSeriesProperty(key: keyHigh, label: 'High', precision: pricePrecision),
    GDataSeriesProperty(key: keyLow, label: 'Low', precision: pricePrecision),
    GDataSeriesProperty(
      key: keyClose,
      label: 'Close',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(key: keyVolume, label: 'Volume', precision: 0),
    GDataSeriesProperty(key: keySMA, label: 'SMA', precision: pricePrecision),
    GDataSeriesProperty(key: keyEMA, label: 'EMA', precision: pricePrecision),
    GDataSeriesProperty(key: keyMACD, label: 'MACD', precision: pricePrecision),
    GDataSeriesProperty(
      key: keyMACDHist,
      label: 'MACD Histogram',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyIchimokuBase,
      label: 'Ichimoku Base',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyIchimokuConversion,
      label: 'Ichimoku Conversion',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyIchimokuSpanA,
      label: 'Ichimoku Span A',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyIchimokuSpanB,
      label: 'Ichimoku Span B',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyIchimokuLagging,
      label: 'Ichimoku Lagging',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyFastStoch,
      label: 'Fast Stochastic',
      precision: 2,
    ),
    GDataSeriesProperty(
      key: keySmoothedFastStoch,
      label: 'Smoothed Fast Stochastic',
      precision: 2,
    ),
    GDataSeriesProperty(
      key: keySlowStoch,
      label: 'Slow Stochastic',
      precision: 2,
    ),
    GDataSeriesProperty(
      key: keySmoothedSlowStoch,
      label: 'Smoothed Slow Stochastic',
      precision: 2,
    ),
    GDataSeriesProperty(
      key: keyBBL,
      label: 'Bollinger Bands Lower',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(
      key: keyBBU,
      label: 'Bollinger Bands Upper',
      precision: pricePrecision,
    ),
    GDataSeriesProperty(key: keyRSI, label: 'RSI', precision: 2),
    GDataSeriesProperty(key: keyADX, label: 'ADX', precision: 2),
  ];

  int index = 0;
  final dataList =
      response.candlesData.map((candle) {
        index++;
        return GData<int>(
          pointValue: candle.date.millisecondsSinceEpoch,
          seriesValues: [
            candle.open,
            candle.high,
            candle.low,
            candle.close,
            candle.volume.toDouble(),
            sma[index - 1].quote,
            ema[index - 1].quote,
            macd[index - 1].quote,
            macdHistogram[index - 1].quote,
            ichimokuBaseValues[index - 1].quote,
            ichimokuConversionValues[index - 1].quote,
            ichimokuSpanAValues[index - 1].quote,
            ichimokuSpanBValues[index - 1].quote,
            ichimokuLaggingValues[index - 1].quote,
            fastStochValues[index - 1].quote,
            smoothedFastStochValues[index - 1].quote,
            slowStochValues[index - 1].quote,
            smoothedSlowStochValues[index - 1].quote,
            bblValues[index - 1].quote,
            bbuValues[index - 1].quote,
            rsiValues[index - 1].quote,
            adxValues[index - 1].quote,
          ],
        );
      }).toList();

  if (simulateLatencyMillis <= 0) {
    return GDataSource<int, GData<int>>(
      dataList: simulateEmpty ? [] : dataList,
      seriesProperties: seriesProperties,
    );
  }

  final latencyDuration = Duration(milliseconds: simulateLatencyMillis);
  final dataSource = GDataSource<int, GData<int>>(
    dataList: simulateLatencyMillis > 0 ? [] : dataList,
    seriesProperties: seriesProperties,
    initialDataLoader: ({required int pointCount}) async {
      if (kDebugMode) {
        print('initialDataLoader: $pointCount');
      }
      return Future.delayed(latencyDuration, () {
        if (simulateEmpty) {
          return [];
        }
        return dataList.sublist(dataList.length - pointCount, dataList.length);
      });
    },
    priorDataLoader: ({
      required int toPointExclusive,
      required int toPointValueExclusive,
      required int pointCount,
    }) async {
      if (kDebugMode) {
        print('priorDataLoader: $toPointValueExclusive, $pointCount');
      }
      return Future.delayed(latencyDuration, () {
        final index = dataList.indexWhere(
          (element) => element.pointValue >= toPointValueExclusive,
        );
        if (index <= 0) {
          return [];
        }
        return dataList.sublist(max(index - pointCount, 0), index);
      });
    },
    afterDataLoader: ({
      required int fromPointExclusive,
      required int fromPointValueExclusive,
      required int pointCount,
    }) async {
      if (kDebugMode) {
        print('afterDataLoader: $fromPointValueExclusive, $pointCount');
      }
      return Future.delayed(latencyDuration, () {
        final index = dataList.indexWhere(
          (element) => element.pointValue > fromPointValueExclusive,
        );
        if (index < 0) {
          return [];
        }
        return dataList.sublist(
          index,
          min(index + pointCount, dataList.length),
        );
      });
    },
  );
  return dataSource;
}

class IndicatorResultImpl implements IndicatorResult {
  IndicatorResultImpl(this.quote);
  @override
  final double quote;
}

class IndicatorInputImpl implements IndicatorDataInput {
  IndicatorInputImpl(this.entries);
  @override
  final List<IndicatorOHLC> entries;
  @override
  IndicatorResult createResult(int index, double value) =>
      IndicatorResultImpl(value);
}

class IndicatorOHLCImpl implements IndicatorOHLC {
  const IndicatorOHLCImpl(this.open, this.close, this.high, this.low);
  @override
  final double close;
  @override
  final double high;
  @override
  final double low;
  @override
  final double open;
}
