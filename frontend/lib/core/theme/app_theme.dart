import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFDD259);
  static const Color secondaryColor = Color(0xFF4A9B8E);
  static const Color accentColor = Color(0xFF6BBAA7);
  static const Color backgroundColor = Color(0xFF5B00FF);
  static const Color surfaceColor = Colors.white;

  static const Color textPrimary = Colors.white;

  static ThemeData lightTheme = ThemeData(
    fontFamily: "Zatiyan",
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
  );
}
