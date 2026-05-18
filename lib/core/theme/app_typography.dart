import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color text, Color mute) {
    final base = GoogleFonts.nunitoTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: text,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: text,
      ),
      headlineLarge: GoogleFonts.nunito(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: text,
        letterSpacing: -0.4,
        height: 1.1,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: text,
        letterSpacing: -0.2,
        height: 1.15,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: text,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: mute,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: mute,
        height: 1.35,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: mute,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: mute,
        letterSpacing: 1.2,
      ),
    );
  }

  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
