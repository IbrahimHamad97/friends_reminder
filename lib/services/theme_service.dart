import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Persists and exposes the user's theme preference.
///
/// Preference is either a concrete [AppThemePreset] id, or [systemId] to follow
/// the device light/dark setting (default light / default dark palettes).
///
/// Listeners are notified only after a theme is applied, so tapping previews in
/// Settings does not recolor the app before the user confirms.
class ThemeService extends ChangeNotifier {
  static const _prefsKey = 'app_theme_id';

  /// Stored preference meaning "follow device light/dark".
  static const systemId = 'system';

  String _preferenceId = systemId;
  AppThemePreset _current = AppTheme.defaultPreset;
  Brightness _platformBrightness = Brightness.light;

  /// Currently resolved palette (concrete colors for MaterialApp).
  AppThemePreset get current => _current;

  /// What is persisted: a preset id, or [systemId].
  String get preferenceId => _preferenceId;

  /// Whether the app follows the device light/dark setting.
  bool get followsSystem => _preferenceId == systemId;

  /// Display name for Settings tiles ("System" or the palette name).
  String get preferenceLabel =>
      followsSystem ? 'System' : _current.name;

  /// Loads the stored preference. Missing key → System (device brightness).
  ///
  /// Returns: a future that completes when preferences have been read.
  Future<void> load() async {
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(_prefsKey);
    if (storedId == null) {
      _preferenceId = systemId;
      await prefs.setString(_prefsKey, systemId);
    } else if (storedId == systemId) {
      _preferenceId = systemId;
    } else {
      _preferenceId = storedId;
    }
    _current = _resolve(_preferenceId, _platformBrightness);
    notifyListeners();
  }

  /// Call when the OS light/dark setting changes.
  ///
  /// Returns: nothing.
  void syncPlatformBrightness(Brightness brightness) {
    if (_platformBrightness == brightness) {
      return;
    }
    _platformBrightness = brightness;
    if (!followsSystem) {
      return;
    }
    final next = AppTheme.defaultForBrightness(brightness);
    if (next.id == _current.id) {
      return;
    }
    _current = next;
    notifyListeners();
  }

  /// Applies a concrete palette globally and writes it to disk.
  ///
  /// Returns: a future that completes after persistence.
  Future<void> applyTheme(AppThemePreset preset) async {
    if (_preferenceId == preset.id && _current.id == preset.id) {
      return;
    }
    _preferenceId = preset.id;
    _current = preset;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, preset.id);
  }

  /// Applies System mode (default light/dark follow the device).
  ///
  /// Returns: a future that completes after persistence.
  Future<void> applySystem() async {
    if (followsSystem) {
      final resolved =
          AppTheme.defaultForBrightness(_platformBrightness);
      if (_current.id == resolved.id) {
        return;
      }
    }
    _preferenceId = systemId;
    _current = AppTheme.defaultForBrightness(_platformBrightness);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, systemId);
  }

  AppThemePreset _resolve(String preferenceId, Brightness brightness) {
    if (preferenceId == systemId) {
      return AppTheme.defaultForBrightness(brightness);
    }
    return AppTheme.byId(preferenceId);
  }
}
