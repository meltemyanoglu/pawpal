import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette
  static const Color primary = Color(0xFFFF8FAB);
  static const Color primaryDark = Color(0xFFFF6B9D);
  static const Color secondary = Color(0xFFA8D8EA);
  static const Color accent = Color(0xFFB5EAD7);
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3D3D3D);
  static const Color textMid = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFFAAAAAA);

  // Stat colours
  static const Color hungerColor = Color(0xFFFF8FAB);
  static const Color happinessColor = Color(0xFFFFD93D);
  static const Color cleanlinessColor = Color(0xFFA8D8EA);
  static const Color energyColor = Color(0xFFB5EAD7);

  // Card shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  // Glow shadow (tinted)
  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          surface: background,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.nunitoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: textDark,
                letterSpacing: -1),
            headlineMedium: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: textDark),
            titleLarge: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
            titleMedium: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
            bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textMid,
                height: 1.5),
            bodySmall: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w400, color: textLight),
          ),
        ),
      );
}
