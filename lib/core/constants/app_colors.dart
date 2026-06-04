import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// LUXURY AUCTION-HOUSE DESIGN TOKENS
/// Dark-first, glassmorphism, antique gold + deep purple accents.
///
/// Legacy semantic names (primaryRed, backgroundLight, etc.) are preserved and
/// re-pointed to the new palette so existing widgets pick up the redesign
/// automatically. New code should prefer the luxury tokens (gold, purple, glass…).
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Luxury palette (primary tokens) ──────────────────────────────────────────
  static const Color gold =
      Color.fromARGB(255, 4, 54, 70); // antique gold — primary accent
  static const Color goldBright =
      Color.fromARGB(255, 10, 67, 143); // hover / highlight gold
  static const Color goldDim =
      Color.fromARGB(255, 15, 69, 105); // pressed / muted gold
  // Luminous companion accent — used for prices / values that must POP on the
  // dark background (the base accent above is intentionally deep for fills).
  static const Color accentBright = Color(0xFF4FB8E0); // bright sky-teal
  static const Color purple =
      Color(0xFF8B6FBF); // deep purple — secondary accent
  static const Color purpleBright = Color(0xFFA98FD6);
  static const Color purpleGlow = Color(0x338B6FBF); // 20% purple — hover glow

  static const Color nearBlack = Color(0xFF0A0A0F); // deep background
  static const Color nearBlack2 = Color(0xFF101019); // raised background
  static const Color glassFill = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color glassFillStrong =
      Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color goldBorder = Color(0x33C9A84C); // rgba(201,168,76,0.20)

  // ── Brand (legacy names → gold) ──────────────────────────────────────────────
  static const Color primaryRed = gold; // primary accent / CTA / price
  static const Color primaryVibrant = goldBright;
  static const Color primaryDark = goldDim;
  static const Color accentGold = gold;
  static const Color accentAmber = goldBright;

  // ── Gradient stops (follow the accent automatically) ─────────────────────────
  static const Color gradientStart = goldBright; // brighter accent
  static const Color gradientEnd   = gold;       // base accent
  static const Color goldStart     = goldBright;
  static const Color goldEnd       = goldDim;

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF82);
  static const Color successLight = Color(0x1A4CAF82); // 10% success
  static const Color warning = Color(0xFFD9A441);
  static const Color warningLight = Color(0x1AD9A441);
  static const Color error = Color(0xFFCF4C4C);
  static const Color errorLight = Color(0x1ACF4C4C);
  static const Color info = purple;
  static const Color infoLight = purpleGlow;

  // ── Light-theme backgrounds ──────────────────────────────────────────────────
  // These feed the `: lightBranch` side of `isDark ? darkX : lightX` ternaries,
  // so they MUST stay light. The dark experience uses the dark* tokens below.
  static const Color backgroundLight =
      Color(0xFFF7F4ED); // ivory app background
  static const Color backgroundGrey =
      Color(0xFFEFEBE1); // recessed ivory surface
  static const Color surfaceWhite = Color(0xFFFFFFFF); // card surface
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceTinted = Color(0xFFFAF8F3);

  // ── Dark mode surfaces (the hero theme) ──────────────────────────────────────
  static const Color darkBackground = nearBlack;
  static const Color darkSurface = Color(0xFF12121A); // navbar / sheet base
  static const Color darkCard = Color(0xFF15151F); // solid card fallback
  static const Color darkBorder = glassBorder;
  static const Color darkDivider = Color(0x0DFFFFFF);

  // ── Light-luxury surfaces (ivory fallback theme) ─────────────────────────────
  static const Color ivoryBackground = Color(0xFFF7F4ED);
  static const Color ivorySurface = Color(0xFFFFFFFF);
  static const Color ivoryCard = Color(0xFFFFFFFF);
  static const Color ivoryBorder = Color(0x1A0A0A0F);

  // ── Text ─────────────────────────────────────────────────────────────────────
  // textPrimary is the DARK ink for text on light/white surfaces (voucher cards,
  // QR codes, ivory light theme). Dark-mode UI text comes from textOnDark /
  // the theme's onSurface instead.
  static const Color textPrimary = Color(0xFF1A1A22); // dark ink
  static const Color textSecondary =
      Color(0xFFA0A0B0); // muted grey — legible on both
  static const Color textHint = Color(0xFF7A7A88); // mid grey — legible on both
  static const Color textOnDark = Color(0xFFF5F5F5); // off-white for dark UI
  // Accent is dark, so text/icons sitting on it must be light.
  static const Color textOnRed = Color(0xFFF5F5F5);
  static const Color textOnGold = Color(0xFFF5F5F5);

  // Light-luxury text
  static const Color textPrimaryLight = Color(0xFF1A1A22);
  static const Color textSecondaryLight = Color(0xFF6B6B7B);

  // ── Borders / Dividers ───────────────────────────────────────────────────────
  static const Color border = glassBorder;
  static const Color divider = darkDivider;
  static const Color borderFocused = gold;

  // ── Shadows ──────────────────────────────────────────────────────────────────
  static const Color cardShadow = Color(0x66000000); // deep glass shadow
  static const Color cardShadowMedium = Color(0x40000000);
  static const Color primaryShadow = Color(0x4DC9A84C); // gold glow
  static const Color deepShadow = Color(0x99000000);

  // ── Timer / Countdown ────────────────────────────────────────────────────────
  static const Color timerNormal = success;
  static const Color timerWarning = warning;
  static const Color timerUrgent = error;

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  static const Color navSelected = gold;
  static const Color navUnselected = Color(0xFF6B6B7B);

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 72, 119, 163),
      Color.fromARGB(255, 34, 89, 134)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 74, 121, 148),
      Color.fromARGB(255, 30, 87, 121)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold → purple luxury gradient for hero accents.
  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [gold, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF12121A), Color(0xFF1B1B2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bottom-up vignette for placing text over auction imagery.
  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xE60A0A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Glass effect helper values ───────────────────────────────────────────────
  static const double glassBlur = 12.0;
  static const double glassRadius = 16.0;

  static List<BoxShadow> get glassShadow => const [
        BoxShadow(
            color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 8)),
      ];

  /// Soft gold glow used on active CTAs / prices.
  static List<BoxShadow> goldGlow({double opacity = 0.35}) => [
        BoxShadow(
          color: gold.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ];
}
