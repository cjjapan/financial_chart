import 'dart:math';
import 'package:example/data/sample_data_loader.dart';

import 'models.dart';

/// A async indicator data input simulation async data loading.
class OHLCDataInputAsyncMock extends OHLCDataInputAsync {
  /// source data list to mock a async data loading
  final List<OHLCData> sourceDataList;

  /// currently loaded data list
  final List<OHLCData> dataListLoaded = [];

  /// set to positive value to mock a delay for async data loading
  final int asyncDelayMillis;

  OHLCDataInputAsyncMock({
    required this.sourceDataList,
    this.asyncDelayMillis = 200,
  }) {
    if (asyncDelayMillis <= 0) {
      dataListLoaded.addAll(sourceDataList); // load all data immediately
    }
  }

  @override
  Future<List<OHLCData>> loadInitial(int count, [int offsetFromEnd = 0]) async {
    assert(offsetFromEnd >= 0);
    await _delay();
    if (count <= 0) {
      return [];
    }
    final end = sourceDataList.length - offsetFromEnd;
    final start = max(end - count, 0);
    final loaded = sourceDataList.sublist(start, end);
    dataListLoaded.addAll(loaded);
    return loaded;
  }

  @override
  Future<List<OHLCData>> loadPrior(int count, int toTimeExclusive) async {
    await _delay();
    if (count <= 0) {
      return [];
    }
    int endIndex = sourceDataList.lastIndexWhere(
      (element) => element.time < toTimeExclusive,
    );
    if (endIndex < 0) {
      return [];
    }
    endIndex = endIndex + 1;
    final start = max(endIndex - count, 0);
    final loaded = sourceDataList.sublist(start, endIndex);
    dataListLoaded.insertAll(0, loaded);
    return loaded;
  }

  @override
  Future<List<OHLCData>> loadAfter(int count, int fromTimeExclusive) async {
    await _delay();
    if (count <= 0) {
      return [];
    }
    final startIndex = sourceDataList.indexWhere(
      (element) => element.time > fromTimeExclusive,
    );
    if (startIndex < 0) {
      return [];
    }
    final end = min(startIndex + count, sourceDataList.length);
    final loaded = sourceDataList.sublist(startIndex, end);
    dataListLoaded.addAll(loaded);
    return loaded;
  }

  Future<void> _delay() async {
    if (asyncDelayMillis > 0) {
      await Future.delayed(Duration(milliseconds: asyncDelayMillis));
    }
  }

  @override
  List<OHLCData> get entries => dataListLoaded;
}

Future<OHLCDataInputAsync> createAsyncDataInput(
  String ticker, {
  int asyncDelayMillis = 200,
}) async {
  final response = await loadYahooFinanceData(ticker);
  final ohlcList = response.candlesData.map((candle) {
    return OHLCData(
      time: candle.date.millisecondsSinceEpoch,
      open: candle.open,
      close: candle.close,
      high: candle.high,
      low: candle.low,
      volume: candle.volume.toDouble(),
    );
  }).toList();
  return OHLCDataInputAsyncMock(
    sourceDataList: ohlcList,
    asyncDelayMillis: asyncDelayMillis,
  );
}
