import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// App-wide [ThemeData], built from [AppPalette] and Inter (400/500/600/700).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppPalette.whiteIce,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.terracotta,
        brightness: Brightness.light,
        primary: AppPalette.terracotta,
        secondary: AppPalette.pink,
        surface: AppPalette.whiteIceSurface,
        error: AppPalette.error,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: _interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppPalette.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.terracotta,
          foregroundColor: AppPalette.textOnBrand,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.whiteIceSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Maps Inter weights onto Material's [TextTheme] slots:
  /// 700 for large headlines, 600 for titles, 500 for labels/emphasis,
  /// 400 for body/regular text.
  static TextTheme _interTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 57, color: AppPalette.textPrimary),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 45, color: AppPalette.textPrimary),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 36, color: AppPalette.textPrimary),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 32, color: AppPalette.textPrimary),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 28, color: AppPalette.textPrimary),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 24, color: AppPalette.textPrimary),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 22, color: AppPalette.textPrimary),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: AppPalette.textPrimary),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: AppPalette.textPrimary),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: AppPalette.textPrimary),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: AppPalette.textPrimary),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: AppPalette.textSecondary),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: AppPalette.textPrimary),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12, color: AppPalette.textSecondary),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11, color: AppPalette.textSecondary),
    );
  }
}
