
class MarketRatesResponse {
  final double latestApr;
  final double changeFromPrevious;
  final String lastUpdated;
  final List<HistoricalRate> historicalData;

  MarketRatesResponse({
    required this.latestApr,
    required this.changeFromPrevious,
    required this.lastUpdated,
    required this.historicalData,
  });

  factory MarketRatesResponse.fromJson(Map<String, dynamic> json) {
    return MarketRatesResponse(
      latestApr: json['latest_apr'],
      changeFromPrevious: json['change_from_previous'],
      lastUpdated: json['last_updated'],
      historicalData: (json['historical_data'] as List)
          .map((item) => HistoricalRate.fromJson(item))
          .toList(),
    );
  }
}

class HistoricalRate {
  final String date;
  final double interestRate;

  HistoricalRate({
    required this.date,
    required this.interestRate,
  });

  factory HistoricalRate.fromJson(Map<String, dynamic> json) {
    return HistoricalRate(
      date: json['date'],
      interestRate: json['interest_rate'],
    );
  }
}
