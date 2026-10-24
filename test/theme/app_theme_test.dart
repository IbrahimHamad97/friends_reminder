import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/theme/app_theme.dart';

void main() {
  test('catalog has twelve presets with unique ids', () {
    expect(AppTheme.presets.length, 12);
    final ids = AppTheme.presets.map((p) => p.id).toSet();
    expect(ids.length, 12);
  });

  test('byId returns default for unknown ids', () {
    expect(AppTheme.byId('nope').id, AppTheme.defaultPreset.id);
    expect(AppTheme.byId('sky').id, 'sky');
  });

  test('defaultForBrightness picks light and dark defaults', () {
    expect(
      AppTheme.defaultForBrightness(Brightness.light).brightness,
      Brightness.light,
    );
    expect(
      AppTheme.defaultForBrightness(Brightness.dark).brightness,
      Brightness.dark,
    );
  });
}
