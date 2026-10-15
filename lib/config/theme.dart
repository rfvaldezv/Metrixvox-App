import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño central de MetrixVox.
/// Colores, tipografía y estilos reutilizables en toda la app.
class MetrixTheme {
  // ============================================================
  // COLORES DE MARCA
  // ============================================================
  static const Color indigo = Color(0xFF4F46E5);
  static const Color purple = Color(0xFF7C3AED);
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);

  // Neutros
  static const Color dark = Color(0xFF0F172A);
  static const Color gray = Color(0xFF64748B);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color white = Colors.white;

  // ============================================================
  // GRADIENTES
  // ============================================================
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, purple],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  // ============================================================
  // TEMA GLOBAL
  // ============================================================
  static ThemeData light() {
    final baseText = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: white,
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.poppins(
          textStyle: baseText.displayLarge,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
        displayMedium: GoogleFonts.poppins(
          textStyle: baseText.displayMedium,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
        headlineLarge: GoogleFonts.poppins(
          textStyle: baseText.headlineLarge,
          fontWeight: FontWeight.w700,
          color: dark,
        ),
        headlineMedium: GoogleFonts.poppins(
          textStyle: baseText.headlineMedium,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
        titleLarge: GoogleFonts.poppins(
          textStyle: baseText.titleLarge,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
        bodyLarge: GoogleFonts.inter(
          textStyle: baseText.bodyLarge,
          fontSize: 18,
          color: dark,
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: baseText.bodyMedium,
          fontSize: 16,
          color: gray,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          elevation: 4,
          shadowColor: indigo.withOpacity(0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: indigo,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: indigo, width: 2),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: indigo.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
