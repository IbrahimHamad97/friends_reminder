import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A named, self-contained app palette.
///
/// Add another theme by appending one entry to [AppTheme.presets]. The Settings
/// picker and persistence layer read this catalog automatically.
class AppThemePreset {
  const AppThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.seedColor,
    required this.surfaceColor,
    required this.previewColor,
    required this.brightness,
  });

  /// Stable persistence key.
  final String id;

  /// Short label shown in Settings.
  final String name;

  /// One-line personality description.
  final String description;

  /// Material 3 source color (kept high-chroma).
  final Color seedColor;

  /// App background/surface foundation.
  final Color surfaceColor;

  /// Color shown in the circular picker (always the vivid brand swatch).
  final Color previewColor;

  /// Whether this preset uses light or dark surfaces.
  final Brightness brightness;
}

/// Global theme catalog and Material 3 theme builder.
class AppTheme {
  AppTheme._();

  /// Twelve selectable palettes: six light, then six dark.
  ///
  /// Inspired by high-chroma social UI (Slack accents, Discord blurple,
  /// Twitter blue) — each seed is intentionally different in hue.
  static const List<AppThemePreset> presets = [
    // —— Light ——
    AppThemePreset(
      id: 'sky',
      name: 'Sky',
      description: 'Twitter blue',
      seedColor: Color(0xFF1D9BF0),
      surfaceColor: Color(0xFFF0F8FF),
      previewColor: Color(0xFF1D9BF0),
      brightness: Brightness.light,
    ),
    AppThemePreset(
      id: 'blurple',
      name: 'Blurple',
      description: 'Discord energy',
      seedColor: Color(0xFF5865F2),
      surfaceColor: Color(0xFFF3F4FF),
      previewColor: Color(0xFF5865F2),
      brightness: Brightness.light,
    ),
    AppThemePreset(
      id: 'magenta',
      name: 'Magenta',
      description: 'Instagram pop',
      seedColor: Color(0xFFE1306C),
      surfaceColor: Color(0xFFFFF0F5),
      previewColor: Color(0xFFE1306C),
      brightness: Brightness.light,
    ),
    AppThemePreset(
      id: 'citrus',
      name: 'Citrus',
      description: 'Slack yellow',
      seedColor: Color(0xFFE8A317),
      surfaceColor: Color(0xFFFFF9E8),
      previewColor: Color(0xFFF5B820),
      brightness: Brightness.light,
    ),
    AppThemePreset(
      id: 'mint',
      name: 'Mint',
      description: 'Slack green',
      seedColor: Color(0xFF2EB67D),
      surfaceColor: Color(0xFFEEFBF5),
      previewColor: Color(0xFF2EB67D),
      brightness: Brightness.light,
    ),
    AppThemePreset(
      id: 'flame',
      name: 'Flame',
      description: 'Hot coral',
      seedColor: Color(0xFFE01E5A),
      surfaceColor: Color(0xFFFFF1F4),
      previewColor: Color(0xFFE01E5A),
      brightness: Brightness.light,
    ),
    // —— Dark ——
    AppThemePreset(
      id: 'aubergine',
      name: 'Aubergine',
      description: 'Slack night',
      seedColor: Color(0xFFE8A0FF),
      surfaceColor: Color(0xFF1A0B1E),
      previewColor: Color(0xFF9B59B6),
      brightness: Brightness.dark,
    ),
    AppThemePreset(
      id: 'navy',
      name: 'Navy',
      description: 'Deep sky',
      seedColor: Color(0xFF4DA3FF),
      surfaceColor: Color(0xFF0A1220),
      previewColor: Color(0xFF3B82F6),
      brightness: Brightness.dark,
    ),
    AppThemePreset(
      id: 'ember',
      name: 'Ember',
      description: 'Warm night',
      seedColor: Color(0xFFFF6B6B),
      surfaceColor: Color(0xFF180C0C),
      previewColor: Color(0xFFFF5252),
      brightness: Brightness.dark,
    ),
    AppThemePreset(
      id: 'jade',
      name: 'Jade',
      description: 'Neon forest',
      seedColor: Color(0xFF57F287),
      surfaceColor: Color(0xFF07140E),
      previewColor: Color(0xFF3DDC84),
      brightness: Brightness.dark,
    ),
    AppThemePreset(
      id: 'cosmic',
      name: 'Cosmic',
      description: 'Electric violet',
      seedColor: Color(0xFFB388FF),
      surfaceColor: Color(0xFF110A1C),
      previewColor: Color(0xFF9C6BFF),
      brightness: Brightness.dark,
    ),
    AppThemePreset(
      id: 'ink',
      name: 'Ink',
      description: 'Cyan on black',
      seedColor: Color(0xFF36C5F0),
      surfaceColor: Color(0xFF0A0C10),
      previewColor: Color(0xFF36C5F0),
      brightness: Brightness.dark,
    ),
  ];

  /// Light-mode presets (first half of the catalog).
  static List<AppThemePreset> get lightPresets =>
      presets.where((p) => p.brightness == Brightness.light).toList();

  /// Dark-mode presets (second half of the catalog).
  static List<AppThemePreset> get darkPresets =>
      presets.where((p) => p.brightness == Brightness.dark).toList();

  /// Default light palette (first light entry).
  static AppThemePreset get defaultLightPreset => lightPresets.first;

  /// Default dark palette (first dark entry).
  static AppThemePreset get defaultDarkPreset => darkPresets.first;

  /// Fallback when an id is unknown (light default).
  static AppThemePreset get defaultPreset => defaultLightPreset;

  /// Picks the default light or dark preset for [brightness].
  static AppThemePreset defaultForBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? defaultDarkPreset
        : defaultLightPreset;
  }

  /// Looks up a stable id, returning the default when unknown.
  static AppThemePreset byId(String? id) {
    for (final preset in presets) {
      if (preset.id == id) {
        return preset;
      }
    }
    return defaultPreset;
  }

  /// Builds the complete app theme for [preset].
  static ThemeData fromPreset(AppThemePreset preset) {
    final scheme = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: preset.brightness,
      surface: preset.surfaceColor,
      // Vibrant keeps primary loud so themes feel distinct (Slack/Discord vibe).
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    return _buildTheme(scheme);
  }

  /// Merges Material 3 setup with a readable Google Font for body text.
  static ThemeData _buildTheme(ColorScheme scheme) {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
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
