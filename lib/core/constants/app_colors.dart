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
  static const Color gold        = Color(0xFFC9A84C); // antique gold — primary accent
  static const Color goldBright  = Color(0xFFE3C76A); // hover / highlight gold
  static const Color goldDim     = Color(0xFF8A7434); // pressed / muted gold
  static const Color purple      = Color(0xFF8B6FBF); // deep purple — secondary accent
  static const Color purpleBright = Color(0xFFA98FD6);
  static const Color purpleGlow  = Color(0x338B6FBF); // 20% purple — hover glow

  static const Color nearBlack   = Color(0xFF0A0A0F); // deep background
  static const Color nearBlack2  = Color(0xFF101019); // raised background
  static const Color glassFill   = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color glassFillStrong = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const Color goldBorder  = Color(0x33C9A84C); // rgba(201,168,76,0.20)

  // ── Brand (legacy names → gold) ──────────────────────────────────────────────
  static const Color primaryRed     = gold;       // primary accent / CTA / price
  static const Color primaryVibrant  = goldBright;
  static const Color primaryDark     = goldDim;
  static const Color accentGold      = gold;
  static const Color accentAmber     = goldBright;

  // ── Gradient stops ───────────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFFD4B35A); // light gold
  static const Color gradientEnd   = Color(0xFFB8923C); // deep gold
  static const Color goldStart     = Color(0xFFE3C76A);
  static const Color goldEnd       = Color(0xFFB8923C);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF4CAF82);
  static const Color successLight  = Color(0x1A4CAF82); // 10% success
  static const Color warning       = Color(0xFFD9A441);
  static const Color warningLight  = Color(0x1AD9A441);
  static const Color error         = Color(0xFFCF4C4C);
  static const Color errorLight    = Color(0x1ACF4C4C);
  static const Color info          = purple;
  static const Color infoLight     = purpleGlow;

  // ── Backgrounds (dark-first) ─────────────────────────────────────────────────
  static const Color backgroundLight = nearBlack;   // app background (now deep black)
  static const Color backgroundGrey  = nearBlack2;  // subtly raised background
  static const Color surfaceWhite    = glassFill;   // glass surface
  static const Color surfaceCard     = glassFill;
  static const Color surfaceTinted   = glassFillStrong;

  // ── Dark mode surfaces (the hero theme) ──────────────────────────────────────
  static const Color darkBackground = nearBlack;
  static const Color darkSurface    = Color(0xFF12121A); // navbar / sheet base
  static const Color darkCard       = Color(0xFF15151F); // solid card fallback
  static const Color darkBorder     = glassBorder;
  static const Color darkDivider    = Color(0x0DFFFFFF);

  // ── Light-luxury surfaces (ivory fallback theme) ─────────────────────────────
  static const Color ivoryBackground = Color(0xFFF7F4ED);
  static const Color ivorySurface    = Color(0xFFFFFFFF);
  static const Color ivoryCard       = Color(0xFFFFFFFF);
  static const Color ivoryBorder     = Color(0x1A0A0A0F);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF5F5F5); // off-white
  static const Color textSecondary = Color(0xFFA0A0B0); // muted lavender-grey
  static const Color textHint      = Color(0xFF6B6B7B);
  static const Color textOnDark    = Color(0xFFF5F5F5);
  static const Color textOnRed     = Color(0xFF0A0A0F); // dark text on gold buttons
  static const Color textOnGold    = Color(0xFF0A0A0F);

  // Light-luxury text
  static const Color textPrimaryLight   = Color(0xFF1A1A22);
  static const Color textSecondaryLight = Color(0xFF6B6B7B);

  // ── Borders / Dividers ───────────────────────────────────────────────────────
  static const Color border         = glassBorder;
  static const Color divider        = darkDivider;
  static const Color borderFocused  = gold;

  // ── Shadows ──────────────────────────────────────────────────────────────────
  static const Color cardShadow       = Color(0x66000000); // deep glass shadow
  static const Color cardShadowMedium = Color(0x40000000);
  static const Color primaryShadow    = Color(0x4DC9A84C); // gold glow
  static const Color deepShadow       = Color(0x99000000);

  // ── Timer / Countdown ────────────────────────────────────────────────────────
  static const Color timerNormal  = success;
  static const Color timerWarning = warning;
  static const Color timerUrgent  = error;

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  static const Color navSelected   = gold;
  static const Color navUnselected = Color(0xFF6B6B7B);

  // ── Gradients ────────────────────────────────────────────────────────────────
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
  static const double glassBlur   = 12.0;
  static const double glassRadius = 16.0;

  static List<BoxShadow> get glassShadow => const [
        BoxShadow(color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 8)),
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
