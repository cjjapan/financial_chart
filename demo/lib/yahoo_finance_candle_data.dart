/// Representation of a single candle
class YahooFinanceCandleData {
  /// Date of the candle
  final DateTime date;

  /// Open price
  final double open;

  /// High price
  final double high;

  /// Low price
  final double low;

  /// Close price
  final double close;

  /// Volume
  final int volume;

  /// Adjusted close price, by splits and dividends
  final double adjClose;

  /// Map to receive indicators associated with this candle
  Map<String, double> indicators = {};

  /// Constructor
  YahooFinanceCandleData({
    required this.date,
    this.open = -1,
    this.high = -1,
    this.low = -1,
    this.close = -1,
    this.adjClose = -1,
    this.volume = 0,
  });

  factory YahooFinanceCandleData.fromJson(
      Map<String, dynamic> json, {
        bool adjust = false,
      }) {
    double adjClose = double.parse(json['adjClose'].toString());
    double close = double.parse(json['close'].toString());
    double open = double.parse(json['open'].toString());
    double low = double.parse(json['low'].toString());
    double high = double.parse(json['high'].toString());

    if (adjust) {
      final double proportion = adjClose / close;
      close = close * proportion;
      open = open * proportion;
      low = low * proportion;
      high = high * proportion;
    }

    return YahooFinanceCandleData(
      date: DateTime.fromMillisecondsSinceEpoch((json['date'] as int) * 1000),
      open: open,
      high: high,
      low: low,
      close: close,
      adjClose: adjClose,
      volume: int.parse(json['volume'].toString()),
    );
  }

  /// Create a list of YahooFinanceCandleData based in a json array
  static List<YahooFinanceCandleData> fromJsonList(
      List<Map<String, dynamic>> jsonList,
      ) {
    final List<YahooFinanceCandleData> result = [];

    for (final Map<String, dynamic> jsonObject in jsonList) {
      result.add(YahooFinanceCandleData.fromJson(jsonObject));
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
    'date': date.millisecondsSinceEpoch ~/ 1000,
    'adjClose': adjClose,
    'open': open,
    'close': close,
    'high': high,
    'low': low,
    'volume': volume,
  };

  @override
  String toString() =>
      'YahooFinanceCandleData{date: $date, adjClose: $adjClose, open: $open, '
          'close: $close, high: $high, low: $low, volume: $volume}';

  YahooFinanceCandleData copyWith({
    DateTime? date,
    double? open,
    double? close,
    double? adjClose,
    double? high,
    double? low,
    int? volume,
  }) => YahooFinanceCandleData(
    date: date ?? this.date,
    open: open ?? this.open,
    close: close ?? this.close,
    adjClose: adjClose ?? this.adjClose,
    high: high ?? this.high,
    low: low ?? this.low,
    volume: volume ?? this.volume,
  );
}


class YahooFinanceResponse {
  YahooFinanceResponse({this.candlesData = const []});

  /// List with all the candles
  List<YahooFinanceCandleData> candlesData = [];

  factory YahooFinanceResponse.fromJson(
      Map<String, dynamic> json, {
        bool adjust = false,
      }) {
    final List<YahooFinanceCandleData> data = [];

    final List<dynamic> timestamps = json['timestamp'] as List;

    final Map<String, dynamic> indicators =
    json['indicators'] as Map<String, dynamic>;
    final List<dynamic> quotes = indicators['quote'] as List<dynamic>;
    final Map<String, dynamic> firstQuote =
    quotes.first as Map<String, dynamic>;

    final List<dynamic> opens = firstQuote['open'] as List;
    final List<dynamic> closes = firstQuote['close'] as List;
    final List<dynamic> lows = firstQuote['low'] as List;
    final List<dynamic> highs = firstQuote['high'] as List;
    final List<dynamic> volumes = firstQuote['volume'] as List;

    final List<dynamic> adjClosesList = indicators['adjclose'] as List<dynamic>;
    final Map<String, dynamic> adjClosesList2 =
    adjClosesList.first as Map<String, dynamic>;

    final List<dynamic> adjCloses = adjClosesList2['adjclose'] as List<dynamic>;

    for (int i = 0; i < timestamps.length; i++) {
      final int timestamp = timestamps[i] as int;
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000,
      );

      // Ignore null values
      if (closes[i] == null ||
          opens[i] == null ||
          lows[i] == null ||
          highs[i] == null ||
          volumes[i] == null ||
          adjCloses[i] == null) {
        continue;
      }

      double close = closes[i] as double;
      double open = opens[i] as double;
      double low = lows[i] as double;
      double high = highs[i] as double;
      final int volume = volumes[i] as int;
      final double adjClose = adjCloses[i] as double;

      if (adjust) {
        final double proportion = adjClose / close;
        close = close * proportion;
        open = open * proportion;
        low = low * proportion;
        high = high * proportion;
      }

      // Add candle to the list
      final YahooFinanceCandleData candle = YahooFinanceCandleData(
        date: date,
        close: close,
        open: open,
        low: low,
        high: high,
        volume: volume,
        adjClose: adjClose,
      );
      data.add(candle);
    }

    return YahooFinanceResponse(candlesData: data);
  }

  Map<String, dynamic> toJson() => {'candlesData': toCandlesJson()};

  List<dynamic> toCandlesJson() => candlesData.map((e) => e.toJson()).toList();
}

