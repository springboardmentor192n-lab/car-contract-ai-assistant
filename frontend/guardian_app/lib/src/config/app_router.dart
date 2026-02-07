import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:guardian_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:guardian_app/src/features/contract/presentation/screens/contract_analysis_screen.dart';
import 'package:guardian_app/src/features/vehicle/presentation/screens/market_rates_screen.dart';
import 'package:guardian_app/src/features/vehicle/presentation/screens/vin_lookup_screen.dart';
import 'package:guardian_app/src/features/dashboard/presentation/screens/dashboard_screen.dart'; // NEW: Import your dashboard

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard', // Changed initial location to the new dashboard
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard', // Redirect root to dashboard
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => const SignupScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard', // NEW: Dashboard route
        builder: (BuildContext context, GoRouterState state) => const DashboardScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/contract-analysis',
        builder: (BuildContext context, GoRouterState state) => const ContractAnalysisScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const ContractAnalysisScreen(),
        ),
      ),
      GoRoute(
        path: '/vin-lookup',
        builder: (BuildContext context, GoRouterState state) => const VinLookupScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const VinLookupScreen(),
        ),
      ),
      GoRoute(
        path: '/market-rates',
        builder: (BuildContext context, GoRouterState state) => const MarketRatesScreen(),
        pageBuilder: (context, state) => _buildPageWithTransition(
          context, state, const MarketRatesScreen(),
        ),
      ),
      // Add other routes as needed
    ],
  );

  // Custom page transition function
  static CustomTransitionPage _buildPageWithTransition<T> (
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Example: Fade transition
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutCubic).animate(animation),
          child: child,
        );
        // Example: Slide from right transition
        // return SlideTransition(
        //   position: Tween<Offset>(
        //     begin: const Offset(1.0, 0.0),
        //     end: Offset.zero,
        //   ).animate(animation),
        //   child: child,
        // );
      },
      transitionDuration: const Duration(milliseconds: 300), // Adjust duration
    );
  }
}
