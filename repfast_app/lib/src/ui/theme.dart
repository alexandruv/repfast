import 'package:flutter/material.dart';

class RepFastColors {
  const RepFastColors._();

  static const background = Color(0xFF050708);
  static const surface = Color(0xFF0C141A);
  static const surfaceRaised = Color(0xFF111C23);
  static const border = Color(0xFF243640);
  static const text = Color(0xFFF2FBFB);
  static const muted = Color(0xFF9AADB4);
  static const cyan = Color(0xFF24E6D0);
  static const green = Color(0xFF37EE8A);
  static const amber = Color(0xFFF5B84B);
  static const red = Color(0xFFFF6B6B);
}

ThemeData repFastTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RepFastColors.background,
    colorScheme: const ColorScheme.dark(
      primary: RepFastColors.cyan,
      secondary: RepFastColors.green,
      error: RepFastColors.red,
      surface: RepFastColors.surface,
      onSurface: RepFastColors.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: RepFastColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: RepFastColors.text,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: RepFastColors.muted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: RepFastColors.text,
      ),
    ),
  );
}
