import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────
  static const Color primaryRed    = Color(0xFFE63946);
  static const Color primaryDark   = Color(0xFFc1121f);
  static const Color accentGold    = Color(0xFFFFD700);
  static const Color accentOrange  = Color(0xFFFF7F50);

  // ── Status ─────────────────────────────────────────────
  static const Color success       = Color(0xFF2ECC71);
  static const Color successLight  = Color(0xFFD5F5E3);
  static const Color warning       = Color(0xFFF39C12);
  static const Color warningLight  = Color(0xFFFEF9E7);
  static const Color error         = Color(0xFFE74C3C);
  static const Color errorLight    = Color(0xFFFDEDEC);
  static const Color info          = Color(0xFF3498DB);

  // ── Background ─────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundGrey  = Color(0xFFF0F0F0);
  static const Color surfaceWhite    = Color(0xFFFFFFFF);
  static const Color surfaceCard     = Color(0xFFFFFFFF);

  // ── Text ───────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint      = Color(0xFFB2BEC3);
  static const Color textOnRed     = Color(0xFFFFFFFF);

  // ── Border / Divider ───────────────────────────────────
  static const Color divider       = Color(0xFFDFE6E9);
  static const Color border        = Color(0xFFE0E0E0);
  static const Color borderFocused = primaryRed;

  // ── Shadow ─────────────────────────────────────────────
  static const Color cardShadow    = Color(0x12000000);
  static const Color deepShadow    = Color(0x20000000);

  // ── Countdown ──────────────────────────────────────────
  static const Color timerNormal   = Color(0xFF27AE60);
  static const Color timerUrgent   = Color(0xFFE63946);
  static const Color timerWarning  = Color(0xFFF39C12);

  // ── Bottom Nav ─────────────────────────────────────────
  static const Color navSelected   = primaryRed;
  static const Color navUnselected = Color(0xFF9E9E9E);

  // ── Dark theme surfaces ────────────────────────────────
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface    = Color(0xFF16213E);
  static const Color darkCard       = Color(0xFF0F3460);
}
