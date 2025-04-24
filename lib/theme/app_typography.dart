import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Headings with DM Serif Text
  static final TextStyle displayLarge = GoogleFonts.dmSerifText(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
  );

  static final TextStyle displayMedium = GoogleFonts.dmSerifText(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle titleLarge = GoogleFonts.dmSerifText(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Content with clean sans-serif font
  static final TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.2,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    letterSpacing: -0.1,
  );

  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: -0.1,
  );

  // Filter chips text style
  static final TextStyle chipText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
  );
}
