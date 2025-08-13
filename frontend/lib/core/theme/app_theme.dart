import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D5F);
  static const Color secondaryColor = Color(0xFF4A9B8E);
  static const Color accentColor = Color(0xFF6BBAA7);
  static const Color backgroundColor = Color(0xFF5B00FF);
  static const Color surfaceColor = Colors.white;

  static const Color textPrimary = Colors.white;

  static ThemeData lightTheme = ThemeData(
    fontFamily: "Font",
    scaffoldBackgroundColor: backgroundColor,
    cardColor: surfaceColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:backgroundColor,
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
