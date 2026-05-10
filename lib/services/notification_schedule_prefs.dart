import 'package:shared_preferences/shared_preferences.dart';

/// Keys for stored local-notification clock (birthday + check-in).
const String _kNotifHourKey = 'notification_reminder_hour';

/// Minute component (0–59).
const String _kNotifMinuteKey = 'notification_reminder_minute';

/// Reads/writes the wall-clock time used by [NotificationScheduler].
///
/// Defaults to **09:00** if unset—notifications never fired at midnight unless you choose it.
class NotificationSchedulePrefs {
  NotificationSchedulePrefs._();

  /// Shared singleton for loading/saving.
  static final NotificationSchedulePrefs instance = NotificationSchedulePrefs._();

  /// Loads hour and minute from [SharedPreferences].
  ///
  /// Returns: `(hour, minute)` in local-notification semantics (same as [TimeOfDay]).
  Future<(int hour, int minute)> loadReminderClock() async {
    final p = await SharedPreferences.getInstance();
    final hour = (p.getInt(_kNotifHourKey) ?? 9).clamp(0, 23);
    final minute = (p.getInt(_kNotifMinuteKey) ?? 0).clamp(0, 59);
    return (hour, minute);
  }

  /// Persists the chosen reminder time (birthdays and check-ins use the same clock).
  ///
  /// Parameters:
  /// - [hour]: 0–23.
  /// - [minute]: 0–59.
  ///
  /// Returns: future completing after disk write.
  Future<void> saveReminderClock(int hour, int minute) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kNotifHourKey, hour.clamp(0, 23));
    await p.setInt(_kNotifMinuteKey, minute.clamp(0, 59));
  }
}
