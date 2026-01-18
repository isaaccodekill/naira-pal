import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? const Color(0xFF2D2A26)
        : const Color(0xFFFAF8F5);

    return TextTheme(
      displayLarge: GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }
}
