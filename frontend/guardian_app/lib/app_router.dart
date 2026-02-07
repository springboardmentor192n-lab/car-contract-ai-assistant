// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/main_layout.dart';
import 'screens/dashboard_screen.dart';
import 'screens/market_rates_screen.dart';
import 'screens/vin_lookup_screen.dart'; // VIN Lookup Screen
import 'screens/contract_analysis_screen.dart'; // NEW: Contract Analysis Screen
import 'screens/detail_screen_placeholder.dart'; // Add this import

/// Defines the application's routing configuration using go_router.
/// The router uses a shell route for the main application layout,
/// ensuring the app bar and sidebar are persistent across main screens.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        // The MainLayout will handle the AppBar and NavigationRail
        // and display the current screen as its child.
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/market_rates',
          name: 'market_rates',
          builder: (context, state) => const MarketRatesScreen(),
        ),
        GoRoute(
          path: '/vin-lookup',
          name: 'vin_lookup',
          builder: (context, state) => const VinLookupScreen(),
        ),
        GoRoute(
          path: '/contract_analysis', // NEW: Route for Document Contract Analysis
          name: 'contract_analysis',
          builder: (context, state) => const ContractAnalysisScreen(),
        ),
        GoRoute(
          path: '/activity_detail/:id',
          name: 'activity_detail',
          builder: (context, state) {
            final activityId = state.pathParameters['id']!;
            return DetailScreenPlaceholder(itemId: activityId, itemType: 'Activity');
          },
        ),
      ],
    ),
  ],
);