import 'package:flutter/material.dart';

/// Central theme configuration for SustainaBit CommUnity.
/// Design principles:
///  - Body text always renders as near-black (Color(0xFF1A1A1A)) on white surfaces
///  - Secondary / supporting text uses Color(0xFF444444) — dark grey, still legible
///  - Meta / timestamp text uses Color(0xFF666666) — mid-grey for de-emphasis only
///  - Primary blue (#4A90E2) used for the app bar; green (#2E7D32) for branding accents
class AppTheme {
  // ── Brand colours ────────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF4A90E2); // AppBar, buttons
  static const Color brandGreen = Color(0xFF2E7D32); // Sustainability accent
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color errorColor = Color(0xFFD32F2F);

  // ── Text colours (use these in inline TextStyle() if needed) ─────────────────
  static const Color textPrimary = Color(0xFF1A1A1A); // headlines, titles, body
  static const Color textSecondary =
      Color(0xFF444444); // descriptions, subtitles
  static const Color textMeta = Color(0xFF666666); // timestamps, captions
  static const Color textHint = Color(0xFF888888); // placeholder / hint

  // ── Surface colours ───────────────────────────────────────────────────────────
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceCard = Color(0xFFF8F9FA);

  // ── Light Theme ───────────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryBlue,
      onPrimary: Colors.white,
      secondary: brandGreen,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceWhite,
      onSurface: textPrimary, // ← all default text is near-black
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    fontFamily: 'Roboto',

    // ── Typography: every style dark by default ───────────────────────────────
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium:
          TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: textSecondary),
      labelSmall: TextStyle(color: textMeta),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      hintStyle: const TextStyle(color: textHint),
      labelStyle: const TextStyle(color: textSecondary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      textColor: textPrimary,
      subtitleTextStyle: TextStyle(color: textSecondary),
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF82B1FF),
      onPrimary: const Color(0xFF1A1A2E),
      secondary: accentGreen,
      onSecondary: Colors.black,
      error: errorColor,
      onError: Colors.white,
      surface: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFEEEEEE),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2A2A),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
