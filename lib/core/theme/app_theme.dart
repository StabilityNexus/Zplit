import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final background = isLight
        ? AppColors.lightbackground
        : AppColors.darkBackground;
    final surface = isLight ? AppColors.surface : AppColors.darkSurface;
    final textPrimary = isLight
        ? AppColors.textPrimarylight
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.textSecondary
        : AppColors.darkTextSecondary;
    final toggleBackground = isLight
        ? AppColors.toggleBackground
        : AppColors.darkToggleBackground;
    final borderColor = isLight ? AppColors.borderLight : AppColors.borderDark;
    final colorScheme = isLight
        ? ColorScheme.light(
            primary: AppColors.primary,
            surface: surface,
            onSurface: textPrimary,
            onSurfaceVariant: textSecondary,
            surfaceContainerHighest: toggleBackground,
            outlineVariant: borderColor,
            error: AppColors.error,
            onError: Colors.white,
          )
        : ColorScheme.dark(
            primary: AppColors.primary,
            surface: surface,
            onSurface: textPrimary,
            onSurfaceVariant: textSecondary,
            surfaceContainerHighest: toggleBackground,
            outlineVariant: borderColor,
            error: AppColors.error,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        modalBackgroundColor: background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withAlpha(40),
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        filled: false,
        hintStyle: TextStyle(color: textSecondary),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textPrimary;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
