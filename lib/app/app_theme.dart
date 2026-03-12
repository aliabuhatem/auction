import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// FIX: CardTheme → CardThemeData (required in Flutter 3.7+)
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor:   AppColors.primaryRed,
        primary:     AppColors.primaryRed,
        secondary:   AppColors.accentGold,
        surface:     AppColors.surfaceWhite,
        error:       AppColors.error,
        brightness:  Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Nunito',

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:  Colors.white,
        foregroundColor:  AppColors.textPrimary,
        elevation:        0,
        scrolledUnderElevation: 1,
        shadowColor:      AppColors.cardShadow,
        centerTitle:      false,
        titleTextStyle: TextStyle(
          fontFamily:  'Nunito',
          fontSize:    20,
          fontWeight:  FontWeight.w800,
          color:       AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      // FIX: was CardTheme(...) — must be CardThemeData(...)
      cardTheme: CardThemeData(
        elevation:    0,
        color:        AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── ElevatedButton ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation:       0,
          minimumSize:     const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Nunito',
            fontWeight:  FontWeight.w800,
            fontSize:    16,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize:   15,
          ),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize:   14,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primaryRed, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color:      AppColors.textSecondary,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color:      AppColors.textHint,
          fontFamily: 'Nunito',
        ),
        errorStyle: const TextStyle(
          color:      AppColors.error,
          fontFamily: 'Nunito',
          fontSize:   12,
        ),
      ),

      // ── BottomNavigationBar ──────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      Colors.white,
        selectedItemColor:    AppColors.primaryRed,
        unselectedItemColor:  AppColors.navUnselected,
        elevation:            12,
        type:                 BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize:   11,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize:   11,
        ),
      ),

      // ── TabBar ───────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor:          AppColors.primaryRed,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor:      AppColors.primaryRed,
        indicatorSize:       TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize:   14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize:   14,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior:        SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color:      Colors.white,
          fontFamily: 'Nunito',
          fontSize:   14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.backgroundGrey,
        selectedColor:    AppColors.primaryRed,
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize:   13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     AppColors.divider,
        thickness: 1,
        space:     1,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: AppColors.textSecondary,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize:   15,
          color:      AppColors.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize:   13,
          color:      AppColors.textSecondary,
        ),
      ),

      // ── Text ─────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 24, color: AppColors.textPrimary),
        headlineMedium:TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
        titleLarge:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
        titleMedium:   TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
        bodyLarge:     TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary),
        bodyMedium:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textPrimary),
        bodySmall:     TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w400, fontSize: 12, color: AppColors.textSecondary),
        labelLarge:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
        labelMedium:   TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary),
        labelSmall:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }

  // ── Dark theme ───────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor:  AppColors.primaryRed,
        primary:    AppColors.primaryRed,
        surface:    AppColors.darkSurface,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation:       0,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize:   20,
          fontWeight: FontWeight.w800,
          color:      Colors.white,
        ),
      ),
      // FIX applied here too
      cardTheme: CardThemeData(
        elevation: 0,
        color:     AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin:       EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
