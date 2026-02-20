import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/contract_analysis_screen.dart';
import 'screens/vin_report_screen.dart';
import 'screens/negotiation_chat_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'models/contract_analysis_response.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/analysis/:id',
      name: 'analysis',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ContractAnalysisScreen(contractId: id);
      },
    ),
    GoRoute(
      path: '/vin-report',
      name: 'vinReport',
      builder: (context, state) => const VinReportScreen(),
    ),
    GoRoute(
      path: '/negotiate/:id',
      name: 'negotiate',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final initialData = state.extra as ContractAnalysisResponse?;
        return NegotiationChatScreen(
          contractId: id,
          initialData: initialData,
        );
      },
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
