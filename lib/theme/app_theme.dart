import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Brand
  static const primary    = Color(0xFF1D9E75);
  static const primaryBg  = Color(0xFFEAF3DE);

  // Semantic – light
  static const danger     = Color(0xFFE24B4A);
  static const dangerBg   = Color(0xFFFCEBEB);
  static const warning    = Color(0xFFBA7517);
  static const warningBg  = Color(0xFFFAEEDA);
  static const success    = Color(0xFF1D9E75);
  static const successBg  = Color(0xFFEAF3DE);

  // Semantic – dark (softer tints on dark surfaces)
  static const dangerDark    = Color(0xFFFF6B6A);
  static const dangerBgDark  = Color(0xFF3D1515);
  static const warningDark   = Color(0xFFFFB74D);
  static const warningBgDark = Color(0xFF3A2500);
  static const successDark   = Color(0xFF4DB88C);
  static const successBgDark = Color(0xFF0D2B1E);

  // Surface
  static const cardBorder   = Color(0xFFE0E0E0);
  static const subtitleGray = Color(0xFF757575);
  static const divider      = Color(0xFFF0F0F0);

  // Dark surfaces
  static const darkSurface     = Color(0xFF1C1C1E);
  static const darkBackground  = Color(0xFF121212);
  static const darkCard        = Color(0xFF1E1E1E);
  static const darkBorder      = Color(0xFF2C2C2C);
  static const darkSubtitle    = Color(0xFF8E8E93);
}

// ─── Theme builder ────────────────────────────────────────────────────────────

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary:              AppColors.primary,
      onPrimary:            Colors.white,
      primaryContainer:     isDark ? AppColors.successBgDark : AppColors.primaryBg,
      onPrimaryContainer:   isDark ? AppColors.successDark   : AppColors.primary,
      surface:              isDark ? AppColors.darkCard       : Colors.white,
      onSurface:            isDark ? Colors.white             : const Color(0xFF1A1A1A),
      surfaceContainerHighest: isDark ? AppColors.darkSurface : const Color(0xFFF6F6F6),
      outline:              isDark ? AppColors.darkBorder     : AppColors.cardBorder,
      outlineVariant:       isDark ? AppColors.darkBorder     : AppColors.cardBorder,
      onSurfaceVariant:     isDark ? AppColors.darkSubtitle   : AppColors.subtitleGray,
      error:                isDark ? AppColors.dangerDark     : AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),

      // ── Cards – flat, white, 0.5px border ────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkCard : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorder : AppColors.divider,
        space: 1,
        thickness: 0.5,
      ),

      // ── ListTile ───────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minLeadingWidth: 0,
      ),

      // ── Input fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),

      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.cardBorder,
          width: 0.5,
        ),
      ),

      // ── NavigationBar – styled via custom widget, suppress defaults ───────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

// ─── Semantic color helpers accessible anywhere ───────────────────────────────

extension SemanticColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get dangerColor  => isDark ? AppColors.dangerDark    : AppColors.danger;
  Color get dangerBgColor => isDark ? AppColors.dangerBgDark : AppColors.dangerBg;
  Color get warningColor  => isDark ? AppColors.warningDark   : AppColors.warning;
  Color get warningBgColor => isDark ? AppColors.warningBgDark : AppColors.warningBg;
  Color get successColor  => isDark ? AppColors.successDark   : AppColors.success;
  Color get successBgColor => isDark ? AppColors.successBgDark : AppColors.successBg;
  Color get cardBorderColor => isDark ? AppColors.darkBorder  : AppColors.cardBorder;
  Color get subtitleColor   => isDark ? AppColors.darkSubtitle : AppColors.subtitleGray;
}
