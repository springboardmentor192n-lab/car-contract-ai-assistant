// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'core/theme.dart';

void main() {
  runApp(
    // ProviderScope is needed for Riverpod to work
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the GoRouter instance from app_router.dart
    final router = appRouter;

    return MaterialApp.router(
      title: 'Autofinance Guardian',
      theme: appTheme, // Apply the custom Material 3 theme
      routerConfig: router, // Use go_router for navigation
      debugShowCheckedModeBanner: false,
    );
  }
}
