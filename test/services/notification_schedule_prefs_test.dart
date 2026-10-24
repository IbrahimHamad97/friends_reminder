import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:friends_reminder/services/notification_schedule_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('reminder clock defaults to 09:00', () async {
    final (hour, minute) =
        await NotificationSchedulePrefs.instance.loadReminderClock();
    expect(hour, 9);
    expect(minute, 0);
  });

  test('saveReminderClock persists and clamps values', () async {
    await NotificationSchedulePrefs.instance.saveReminderClock(14, 30);
    var clock = await NotificationSchedulePrefs.instance.loadReminderClock();
    expect(clock, (14, 30));

    await NotificationSchedulePrefs.instance.saveReminderClock(99, -5);
    clock = await NotificationSchedulePrefs.instance.loadReminderClock();
    expect(clock.$1, 23);
    expect(clock.$2, 0);
  });
}
