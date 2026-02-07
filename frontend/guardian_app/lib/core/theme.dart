// lib/core/theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark, // Assuming a dark theme for a fintech dashboard
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.dark,
    primary: Colors.blueAccent,
    onPrimary: Colors.white,
    secondary: Colors.cyanAccent,
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey[900]!,
    onSurface: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: Colors.grey[850],
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  navigationRailTheme: NavigationRailThemeData(
    backgroundColor: Colors.grey[900],
    selectedIconTheme: const IconThemeData(color: Colors.blueAccent),
    selectedLabelTextStyle: TextStyle(color: Colors.blueAccent),
    unselectedIconTheme: const IconThemeData(color: Colors.grey),
    unselectedLabelTextStyle: TextStyle(color: Colors.grey),
  ),
  // Add more theming as needed
);