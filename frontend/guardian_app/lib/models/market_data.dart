// lib/models/market_data.dart

class MarketDataPoint {
  final DateTime date;
  final double value;

  MarketDataPoint({required this.date, required this.value});

  factory MarketDataPoint.fromJson(Map<String, dynamic> json) {
    return MarketDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
    };
  }
}