import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:friends_reminder/services/group_section_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to expanded', () async {
    expect(await GroupSectionPrefs.instance.isExpanded(42), isTrue);
  });

  test('persists collapse and forget restores default', () async {
    await GroupSectionPrefs.instance.setExpanded(7, false);
    expect(await GroupSectionPrefs.instance.isExpanded(7), isFalse);

    await GroupSectionPrefs.instance.forget(7);
    expect(await GroupSectionPrefs.instance.isExpanded(7), isTrue);
  });
}
