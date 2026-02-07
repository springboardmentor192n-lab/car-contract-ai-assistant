// lib/providers/market_data_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/market_data.dart';
import 'dart:math';

/// A Riverpod provider that simulates fetching market data.
/// In a real application, this would fetch data from an ApiService.
final marketDataProvider = FutureProvider<List<MarketDataPoint>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 2));

  // Generate some dummy market data
  final List<MarketDataPoint> data = [];
  final now = DateTime.now();
  Random random = Random();

  // Generate data for the last 30 days
  for (int i = 29; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final value = 100 + random.nextDouble() * 50 * (random.nextBool() ? 1 : -1); // Value between 50 and 150
    data.add(MarketDataPoint(date: date, value: value));
  }

  // Example for error state:
  // if (random.nextBool()) {
  //   throw Exception('Failed to load market data.');
  // }

  return data;
});