import 'package:flutter/material.dart';

import 'app_brand.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppBrand.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppBrand.primary,
        primary: AppBrand.primary,
        secondary: AppBrand.primaryDark,
        surface: AppBrand.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: AppBrand.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppBrand.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppBrand.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppBrand.textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 17, color: AppBrand.textPrimary),
        bodyMedium: TextStyle(fontSize: 15, color: AppBrand.textPrimary),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: AppBrand.primary,
          foregroundColor: AppBrand.white,
          disabledBackgroundColor: AppBrand.primary.withValues(alpha: 0.45),
          disabledForegroundColor: AppBrand.white.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          foregroundColor: AppBrand.primary,
          side: const BorderSide(color: AppBrand.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppBrand.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 15),
        hintStyle: const TextStyle(color: Colors.black45),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppBrand.white,
        foregroundColor: AppBrand.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppBrand.primary,
      ),
    );
  }
}
