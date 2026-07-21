import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── 3. TYPOGRAPHIE ──────────────────────────────────────────────────────────

abstract class AppType {
  static TextTheme buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      // ── Display ─────────────────────────────────────────────────────────
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: primary,
        height: 1.15,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: primary,
        height: 1.2,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: primary,
        height: 1.25,
      ),
      // ── Headline ────────────────────────────────────────────────────────
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      // ── Title ───────────────────────────────────────────────────────────
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: tertiary,
      ),
      // ── Body ────────────────────────────────────────────────────────────
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.65,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.6,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      // ── Label ───────────────────────────────────────────────────────────
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: tertiary,
        letterSpacing: 0.2,
      ),
    );
  }
}

class AppFontSize {
  static const double micro = 9;
  static const double tiny = 10;
  // Half steps are used in a few legacy screens; keep them centralized so UI
  // stays consistent and we can phase them out progressively.
  static const double tinyHalf = 10.5;
  static const double xs = 11;
  static const double xsHalf = 11.5;
  static const double sm = 12;
  static const double smHalf = 12.5;
  static const double md = 13;
  static const double mdHalf = 13.5;
  static const double base = 14;
  static const double baseHalf = 14.5;
  static const double body = 15;
  static const double lgHalf = 15.5;
  static const double lg = 16;
  static const double title = 17;
  static const double xl = 18;
  static const double h3 = 20;
  static const double h2Lg = 22;
  static const double h2 = 24;
  static const double h1Lg = 26;
  static const double h1 = 28;
  static const double d1 = 30;
  static const double d2 = 32;
  static const double d3 = 34;
  static const double d4 = 36;
  static const double d5 = 42;
}
