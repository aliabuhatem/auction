import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFE63946);
  static const Color primaryVibrant = Color(0xFFFF4757);
  static const Color primaryDark = Color(0xFFC1121F);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentAmber = Color(0xFFFF8C00);

  // ── Gradient stops ───────────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFFFF3B5C);
  static const Color gradientEnd = Color(0xFFFF6A35);
  static const Color goldStart = Color(0xFFFFD060);
  static const Color goldEnd = Color(0xFFFF8C00);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE6F9EE);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF1744);
  static const Color errorLight = Color(0xFFFFECEE);
  static const Color info = Color(0xFF2979FF);
  static const Color infoLight = Color(0xFFE8F0FF);

  // ── Light mode backgrounds ───────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color backgroundGrey = Color(0xFFF0F1F7);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceTinted = Color(0xFFFAFAFF);

  // ── Dark mode surfaces ───────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF090D1B);
  static const Color darkSurface = Color(0xFF101624);
  static const Color darkCard = Color(0xFF172033);
  static const Color darkBorder = Color(0x12FFFFFF);
  static const Color darkDivider = Color(0x08FFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color textOnDark = Color(0xFFF8FAFF);
  static const Color textOnRed = Color(0xFFFFFFFF);

  // ── Borders / Dividers ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFE8EAF6);
  static const Color divider = Color(0xFFEEF0F8);
  static const Color borderFocused = primaryRed;

  // ── Shadows ──────────────────────────────────────────────────────────────────
  static const Color cardShadow = Color(0x0A1A1D2E);
  static const Color cardShadowMedium = Color(0x141A1D2E);
  static const Color primaryShadow = Color(0x33FF3B5C);
  static const Color deepShadow = Color(0x20000000);

  // ── Timer / Countdown ────────────────────────────────────────────────────────
  static const Color timerNormal = Color(0xFF00C853);
  static const Color timerWarning = Color(0xFFFFB300);
  static const Color timerUrgent = Color(0xFFFF4757);

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  static const Color navSelected = primaryRed;
  static const Color navUnselected = Color(0xFFB0B7C3);

  // ── Convenience gradients ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldStart, goldEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1D2E), Color(0xFF2D3561)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
// ________________________________________________________________________________
