import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'presentations/bindings/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Contract AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.landing,
    );
  }
}
