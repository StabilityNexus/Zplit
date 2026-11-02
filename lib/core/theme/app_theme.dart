import 'package:flutter/material.dart';

abstract class AppTheme {
  static const Color _primary = Color(0xFF00C853);
  static const Color _primaryLight = Color(0xFFE6F9EE);
  static const Color _primaryDark = Color(0xFF00A343);
  static const Color _negative = Color(0xFFEF4444);

  static const Color _backgroundLight = Color(0xFFFFFFFF);
  static const Color _surfaceLight = Color(0xFFF9FAFB);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _dividerLight = Color(0xFFE5E7EB);
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _textHintLight = Color(0xFF9CA3AF);

  static const Color _backgroundDark = Color(0xFF0C0B10);
  static const Color _surfaceDark = Color(0xFF14131A);
  static const Color _cardDark = Color(0xFF1C1A24);
  static const Color _dividerDark = Color(0xFF25232F);
  static const Color _textPrimaryDark = Color(0xFFF9FAFB);
  static const Color _textSecondaryDark = Color(0xFFA0A0B0);
  static const Color _textHintDark = Color(0xFF6B6B80);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primary,
      primaryContainer: _primaryLight,
      secondary: _primaryDark,
      surface: _surfaceLight,
      error: _negative,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: _backgroundLight,
    cardColor: _cardLight,
    dividerColor: _dividerLight,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryLight,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryLight,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: _textPrimaryLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _textPrimaryLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondaryLight,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _textHintLight,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textPrimaryLight,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textSecondaryLight,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: _textHintLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primary,
      primaryContainer: _primaryDark,
      secondary: _primaryLight,
      surface: _surfaceDark,
      error: _negative,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: _backgroundDark,
    cardColor: _cardDark,
    dividerColor: _dividerDark,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimaryDark,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: _textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _textPrimaryDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _textSecondaryDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _textHintDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textPrimaryDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _textSecondaryDark,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: _textHintDark,
      ),
    ),
  );
}
