// ============================================================================
// APP TYPOGRAPHY
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Helper to avoid repetition ---
TextStyle _lora({
  required double fontSize,
  required FontWeight fontWeight,
}) {
  return GoogleFonts.lora(
    fontSize: fontSize,
    fontWeight: fontWeight,
    // --- Disable the system spell-checker underline ---
    decoration: TextDecoration.none,
    decorationColor: Colors.transparent,
  );
}

final TextTheme amorTextTheme = TextTheme(
  displayLarge: _lora(fontSize: 57, fontWeight: FontWeight.w400),
  displayMedium: _lora(fontSize: 45, fontWeight: FontWeight.w400),
  displaySmall: _lora(fontSize: 36, fontWeight: FontWeight.w400),

  headlineLarge: _lora(fontSize: 32, fontWeight: FontWeight.w400),
  headlineMedium: _lora(fontSize: 28, fontWeight: FontWeight.w400),
  headlineSmall: _lora(fontSize: 24, fontWeight: FontWeight.w400),

  titleLarge: _lora(fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: _lora(fontSize: 16, fontWeight: FontWeight.w500),
  titleSmall: _lora(fontSize: 14, fontWeight: FontWeight.w500),

  bodyLarge: _lora(fontSize: 16, fontWeight: FontWeight.w400),
  bodyMedium: _lora(fontSize: 14, fontWeight: FontWeight.w400),
  bodySmall: _lora(fontSize: 12, fontWeight: FontWeight.w400),

  labelLarge: _lora(fontSize: 14, fontWeight: FontWeight.w500),
  labelMedium: _lora(fontSize: 12, fontWeight: FontWeight.w500),
  labelSmall: _lora(fontSize: 11, fontWeight: FontWeight.w500),
);