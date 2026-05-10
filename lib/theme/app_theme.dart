import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds light and dark [ThemeData] for the app.
class AppTheme {
  AppTheme._();

  /// Light color scheme: warm background, coral accent.
  static const _lightSeed = Color(0xFFE26A5A);

  /// Dark color scheme: deep slate with soft coral accent.
  static const _darkSeed = Color(0xFFFF8A7A);

  /// Application theme for bright environments.
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
      surface: const Color(0xFFFFF8F5),
    );
    return _buildTheme(scheme);
  }

  /// Application theme for low-light environments.
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
      surface: const Color(0xFF12161F),
    );
    return _buildTheme(scheme);
  }

  /// Merges Material 3 setup with a readable Google Font for body text.
  ///
  /// Parameters:
  /// - [scheme]: resolved light or dark [ColorScheme].
  ///
  /// Returns: fully configured [ThemeData].
  static ThemeData _buildTheme(ColorScheme scheme) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: baseText.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardTheme(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
