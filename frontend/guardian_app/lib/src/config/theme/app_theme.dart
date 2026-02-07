
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightPrimaryColor = Colors.blueGrey;
  static const Color _lightPrimaryVariantColor = Colors.white;
  static const Color _lightSecondaryColor = Colors.green;
  static const Color _lightOnPrimaryColor = Colors.black;

  static const Color _darkPrimaryColor = Colors.white;
  static const Color _darkPrimaryVariantColor = Colors.black;
  static const Color _darkSecondaryColor = Colors.white;
  static const Color _darkOnPrimaryColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: _lightPrimaryVariantColor,
    appBarTheme: const AppBarTheme(
      color: _lightPrimaryVariantColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
    ),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
      primaryContainer: _lightPrimaryVariantColor,
    ),
    textTheme: _lightTextTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: _darkPrimaryVariantColor,
    appBarTheme: const AppBarTheme(
      color: _darkPrimaryVariantColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkSecondaryColor,
      onPrimary: _darkOnPrimaryColor,
      primaryContainer: _darkPrimaryVariantColor,
    ),
    textTheme: _darkTextTheme,
  );

  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(
        fontSize: 82.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    displayMedium: GoogleFonts.oswald(
        fontSize: 57.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    displaySmall: GoogleFonts.oswald(
        fontSize: 45.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    headlineLarge: GoogleFonts.oswald(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    headlineMedium: GoogleFonts.oswald(
        fontSize: 28.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    headlineSmall: GoogleFonts.oswald(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    titleLarge: GoogleFonts.oswald(
        fontSize: 22.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    titleMedium: GoogleFonts.oswald(
        fontSize: 16.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    titleSmall: GoogleFonts.oswald(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    bodyLarge: GoogleFonts.roboto(
        fontSize: 16.0, fontWeight: FontWeight.normal, color: _lightOnPrimaryColor),
    bodyMedium: GoogleFonts.roboto(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: _lightOnPrimaryColor),
    bodySmall: GoogleFonts.roboto(
        fontSize: 12.0, fontWeight: FontWeight.normal, color: _lightOnPrimaryColor),
    labelLarge: GoogleFonts.roboto(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    labelMedium: GoogleFonts.roboto(
        fontSize: 12.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
    labelSmall: GoogleFonts.roboto(
        fontSize: 10.0, fontWeight: FontWeight.bold, color: _lightOnPrimaryColor),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(
        fontSize: 82.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    displayMedium: GoogleFonts.oswald(
        fontSize: 57.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    displaySmall: GoogleFonts.oswald(
        fontSize: 45.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    headlineLarge: GoogleFonts.oswald(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    headlineMedium: GoogleFonts.oswald(
        fontSize: 28.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    headlineSmall: GoogleFonts.oswald(
        fontSize: 24.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    titleLarge: GoogleFonts.oswald(
        fontSize: 22.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    titleMedium: GoogleFonts.oswald(
        fontSize: 16.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    titleSmall: GoogleFonts.oswald(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    bodyLarge: GoogleFonts.roboto(
        fontSize: 16.0, fontWeight: FontWeight.normal, color: _darkOnPrimaryColor),
    bodyMedium: GoogleFonts.roboto(
        fontSize: 14.0, fontWeight: FontWeight.normal, color: _darkOnPrimaryColor),
    bodySmall: GoogleFonts.roboto(
        fontSize: 12.0, fontWeight: FontWeight.normal, color: _darkOnPrimaryColor),
    labelLarge: GoogleFonts.roboto(
        fontSize: 14.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    labelMedium: GoogleFonts.roboto(
        fontSize: 12.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
    labelSmall: GoogleFonts.roboto(
        fontSize: 10.0, fontWeight: FontWeight.bold, color: _darkOnPrimaryColor),
  );
}
