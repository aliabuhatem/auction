import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// LUXURY AUCTION-HOUSE THEME
/// Dark-first glassmorphism. Poppins headings, Inter body, antique-gold accents.
/// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Typography builders ──────────────────────────────────────────────────────
  // Headings → Poppins. Body / labels → Inter. Built once per theme.

  static TextTheme _textTheme(Color primary, Color secondary) {
    const heading = GoogleFonts.poppins;
    const body    = GoogleFonts.inter;
    return TextTheme(
      // Display & headlines → Poppins (bold/semibold) for auction titles & H1-H3
      displayLarge:  heading(fontSize: 34, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displayMedium: heading(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      displaySmall:  heading(fontSize: 24, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.2),
      headlineLarge:  heading(fontSize: 24, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      headlineMedium: heading(fontSize: 20, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.2),
      headlineSmall:  heading(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleLarge:  heading(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: heading(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      titleSmall:  heading(fontSize: 13, fontWeight: FontWeight.w500, color: secondary),
      // Body & labels → Inter
      bodyLarge:  body(fontSize: 15, fontWeight: FontWeight.w400, color: primary,   height: 1.6),
      bodyMedium: body(fontSize: 14, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
      bodySmall:  body(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
      labelLarge:  body(fontSize: 14, fontWeight: FontWeight.w600, color: primary,   letterSpacing: 0.2),
      labelMedium: body(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall:  body(fontSize: 10, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.3),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DARK — the hero luxury theme
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final text = _textTheme(AppColors.textPrimary, AppColors.textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.nearBlack,
      canvasColor: AppColors.nearBlack,
      splashColor: AppColors.purpleGlow,
      highlightColor: AppColors.purpleGlow,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.gold,
        onPrimary: AppColors.textOnGold,
        primaryContainer: Color(0xFF2A2410),
        onPrimaryContainer: AppColors.goldBright,
        secondary: AppColors.purple,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF221B33),
        onSecondaryContainer: AppColors.purpleBright,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.darkCard,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.glassBorder,
        outlineVariant: AppColors.darkDivider,
        shadow: AppColors.cardShadow,
        scrim: Color(0xCC000000),
      ),

      textTheme: text,

      // ── AppBar — transparent glass ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // ── Cards — glass ───────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.glassFill,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Elevated (primary gold) button ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textOnGold,
          disabledBackgroundColor: AppColors.glassFillStrong,
          disabledForegroundColor: AppColors.textHint,
          elevation: 0,
          shadowColor: AppColors.primaryShadow,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.2),
        ),
      ),

      // ── Outlined (ghost, gold border) button ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.goldBorder, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      // ── Text button ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── Inputs — dark glass with gold focus ring ────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint),
        errorStyle: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.navUnselected,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Tabs ────────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.gold,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),

      // ── SnackBar — glass ────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        elevation: 8,
      ),

      // ── Dialogs / sheets — glass ────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),

      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassFill,
        selectedColor: AppColors.gold,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.glassBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),

      // ── Divider — almost invisible (separate by space, not lines) ───────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ── ListTile ────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: AppColors.gold,
        titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
        subtitleTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.gold),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.gold : AppColors.textHint),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.goldDim : AppColors.glassFillStrong),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LIGHT — ivory-luxury fallback (warm cream + gold)
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final text = _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivoryBackground,
      splashColor: AppColors.purpleGlow,
      highlightColor: AppColors.purpleGlow,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.goldDim,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFF3EAD0),
        onPrimaryContainer: AppColors.goldDim,
        secondary: AppColors.purple,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFEDE7F6),
        onSecondaryContainer: Color(0xFF4A3B6B),
        surface: AppColors.ivorySurface,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: Color(0xFFF0ECE2),
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.ivoryBorder,
        outlineVariant: Color(0x140A0A0F),
        shadow: Color(0x1A0A0A0F),
        scrim: Color(0x66000000),
      ),

      textTheme: text,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivorySurface,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight, letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.ivorySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.ivoryBorder),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldDim,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldDim,
          side: const BorderSide(color: AppColors.goldDim, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.goldDim,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0ECE2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.ivoryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.ivoryBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.goldDim, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.ivorySurface,
        selectedItemColor: AppColors.goldDim,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(color: Color(0x140A0A0F), thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.goldDim),
    );
  }
}
