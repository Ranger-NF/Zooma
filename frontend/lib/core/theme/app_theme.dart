import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D5F);
  static const Color secondaryColor = Color(0xFF4A9B8E);
  static const Color accentColor = Color(0xFF6BBAA7);
  static const Color backgroundColor = Color(0xFFF5F8F7);
  static const Color surfaceColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF2E7D5F, {
      50: const Color(0xFFE8F5F0),
      100: const Color(0xFFC6E7DA),
      200: const Color(0xFFA0D7C2),
      300: const Color(0xFF7AC7AA),
      400: const Color(0xFF5EBB98),
      500: primaryColor,
      600: const Color(0xFF297157),
      700: const Color(0xFF23634D),
      800: const Color(0xFF1D5543),
      900: const Color(0xFF133B2F),
    }),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: surfaceColor,
    ),
  );
}
