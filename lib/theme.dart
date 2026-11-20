import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color backgroundDark = Color(0xFF031627);
  static const Color backgroundMedium = Color(0xFF082746);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF9EACBA);

  // Status Colors
  static const Color statusGreen = Color(0xFF00FF7F);
  static const Color statusOrange = Color(0xFFFF9500);
  static const Color statusRed = Color(0xFFFF3B30);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: cyanAccent,
        surface: backgroundDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textWhite),
        bodyLarge: TextStyle(fontSize: 16, color: textWhite),
        bodyMedium: TextStyle(fontSize: 14, color: textGrey),
      ),
    );
  }
}
