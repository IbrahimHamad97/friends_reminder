import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:friends_reminder/services/theme_service.dart';
import 'package:friends_reminder/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load defaults to system preference', () async {
    final service = ThemeService();
    await service.load();
    expect(service.followsSystem, isTrue);
    expect(service.preferenceId, ThemeService.systemId);
    expect(service.preferenceLabel, 'System');
  });

  test('applyTheme persists a concrete palette', () async {
    final service = ThemeService();
    await service.load();
    final preset = AppTheme.presets.firstWhere((p) => p.id == 'blurple');

    var notified = 0;
    service.addListener(() => notified++);
    await service.applyTheme(preset);

    expect(service.followsSystem, isFalse);
    expect(service.current.id, 'blurple');
    expect(service.preferenceLabel, preset.name);
    expect(notified, greaterThan(0));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_id'), 'blurple');
  });

  test('applySystem restores device-following mode', () async {
    final service = ThemeService();
    await service.load();
    await service.applyTheme(AppTheme.presets.first);
    await service.applySystem();
    expect(service.followsSystem, isTrue);
    expect(service.preferenceId, ThemeService.systemId);
  });

  test('syncPlatformBrightness updates only while following system', () async {
    final service = ThemeService();
    await service.load();

    final lightDefault = AppTheme.defaultForBrightness(Brightness.light);
    final darkDefault = AppTheme.defaultForBrightness(Brightness.dark);

    service.syncPlatformBrightness(Brightness.light);
    expect(service.current.id, lightDefault.id);

    service.syncPlatformBrightness(Brightness.dark);
    expect(service.current.id, darkDefault.id);

    await service.applyTheme(
      AppTheme.presets.firstWhere((p) => p.brightness == Brightness.light),
    );
    final lockedId = service.current.id;
    service.syncPlatformBrightness(Brightness.dark);
    expect(service.current.id, lockedId);
  });
}
