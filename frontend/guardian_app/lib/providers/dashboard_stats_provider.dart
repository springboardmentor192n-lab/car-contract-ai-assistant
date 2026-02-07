// lib/providers/dashboard_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the aggregated statistics for the dashboard.
class DashboardStats {
  final int totalContractsAnalyzed;
  final int highRiskContracts;
  final double averageSavingsIdentified;
  final int recentVinLookups;
  final int contractAnalysesCount; // NEW: Count of all contract analyses
  final int highRiskContractsCount; // NEW: Count of high-risk contracts

  DashboardStats({
    required this.totalContractsAnalyzed,
    required this.highRiskContracts,
    required this.averageSavingsIdentified,
    required this.recentVinLookups,
    required this.contractAnalysesCount,
    required this.highRiskContractsCount,
  });
}

/// A Riverpod provider that simulates fetching dashboard statistics.
/// In a real application, this would fetch data from a backend API.
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Return mock data
  return DashboardStats(
    totalContractsAnalyzed: 124,
    highRiskContracts: 18,
    averageSavingsIdentified: 452.30,
    recentVinLookups: 32,
    contractAnalysesCount: 55, // Mock data for new stat
    highRiskContractsCount: 12, // Mock data for new stat
  );
});