import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the user's preferred [ThemeMode].
///
/// Listeners are notified when the mode changes so [MaterialApp] can rebuild.
class ThemeService extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;

  /// Current theme mode applied by the app.
  ThemeMode get mode => _mode;

  /// Loads the stored theme mode (or keeps system default if unset).
  ///
  /// Returns: a future that completes when preferences have been read.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _mode = _decodeMode(raw) ?? ThemeMode.system;
    notifyListeners();
  }

  /// Updates the theme mode and writes it to disk.
  ///
  /// Parameters:
  /// - [mode]: desired [ThemeMode].
  ///
  /// Returns: a future that completes after persistence.
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encodeMode(mode));
  }

  /// Converts a stored string into [ThemeMode], or `null` if unknown.
  ///
  /// Parameters:
  /// - [raw]: serialized value from preferences.
  ///
  /// Returns: matching mode, or `null` when [raw] is missing/invalid.
  ThemeMode? _decodeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  /// Serializes [ThemeMode] for SharedPreferences.
  ///
  /// Parameters:
  /// - [mode]: mode to encode.
  ///
  /// Returns: stable string token.
  String _encodeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
