import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        primary: AppColors.coral,
        surface: Colors.grey[900]!,
        onSurface: Colors.white,
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.coral,
        labelStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelMedium: AppTypography.labelMedium,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[50],
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: Colors.black),
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.coral,
        surface: Colors.white,
        onSurface: Colors.black,
        secondary: Colors.grey[200]!,
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.coral,
        labelStyle: AppTypography.bodyMedium.copyWith(color: Colors.black),
        backgroundColor: Colors.grey[200],
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: Colors.black),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: Colors.black,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(color: Colors.black),
        titleMedium: AppTypography.titleMedium.copyWith(color: Colors.black),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.black),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.black),
        labelMedium: AppTypography.labelMedium.copyWith(color: Colors.black54),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}
