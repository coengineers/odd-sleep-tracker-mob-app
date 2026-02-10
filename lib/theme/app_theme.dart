import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colour tokens
  static const _bgApp = Color(0xFF0E0F12);
  static const _bgSurface = Color(0xFF1A1B1F);
  static const _primary = Color(0xFFF7931A);
  static const _onPrimary = Color(0xFF000000);
  static const _textPrimary = Color(0xFFF5F5F5);

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: _onPrimary,
      secondary: Color(0xFF262626),
      onSecondary: Color(0xFFFAFAFA),
      error: Color(0xFFEF4444),
      onError: Color(0xFFFAFAFA),
      surface: _bgSurface,
      onSurface: _textPrimary,
      outline: Color(0xFF23283A),
      outlineVariant: Color(0xFF1C2030),
    ),
    scaffoldBackgroundColor: _bgApp,
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: _bgApp,
      foregroundColor: _textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 20,
        color: _textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _bgSurface,
      selectedItemColor: _primary,
      unselectedItemColor: Color(0xFF6E748A),
      selectedLabelStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primary,
      foregroundColor: _onPrimary,
      shape: CircleBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF23283A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF23283A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF6E748A),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFEF4444),
      ),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );

  static const _textTheme = TextTheme(
    // Headings — Satoshi
    headlineLarge: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 36,
      color: _textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 30,
      color: _textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02 * 24,
      color: _textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02 * 20,
      color: _textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02 * 18,
      color: _textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.02 * 16,
      color: _textPrimary,
    ),
    // Body — Nunito
    bodyLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFA2A8BD),
    ),
    // Labels — Nunito
    labelLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Color(0xFFA2A8BD),
    ),
    labelSmall: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF6E748A),
    ),
  );
}
