import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../utils/date_utils.dart';
import 'friend_service.dart';
import 'notification_schedule_prefs.dart';

/// Maximum chained check-in notifications per friend (Android / desktop).
///
/// iOS keeps only [64](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649508-add) pending requests; we use fewer slots per friend there.
const int _checkInSlotsAndroid = 8;

/// Pending check-in notifications per friend on iOS to stay under the system limit.
const int _checkInSlotsIos = 1;

/// Schedules on-device birthday and check-in reminders (no FCM).
///
/// Uses [flutter_local_notifications] with [timezone] for wall-clock scheduling.
/// Call [initialize] once at startup, then [rescheduleAll] whenever friend data changes
/// or when the app returns to foreground so the queue stays filled.
class NotificationScheduler {
  NotificationScheduler._();

  /// Singleton used from [main] and after friend saves.
  static final NotificationScheduler instance = NotificationScheduler._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Skips duplicate full rebuilds when nothing changed (saves work on rapid saves).
  String? _lastRescheduleFingerprint;

  DateTime? _lastRescheduleAt;

  /// Prepares timezone data, notification channels, and requests OS permissions.
  ///
  /// Safe to call multiple times; subsequent calls no-op after the first success.
  /// On web and Linux, scheduling is unsupported—this returns without error.
  ///
  /// Returns: future that completes when initialization finishes.
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    if (Platform.isLinux) {
      return;
    }
    if (_initialized) {
      return;
    }

    await _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();

      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _birthdayChannelId,
          'Birthdays',
          description: 'Reminders on each friend\'s birthday',
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _checkInChannelId,
          'Check-ins',
          description: 'Periodic reminders to reach out',
          importance: Importance.defaultImportance,
        ),
      );
    }

    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    if (Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    _initialized = true;
  }

  /// Loads IANA tzdata and aligns [tz.local] with the device timezone.
  ///
  /// Returns: future that completes after timezone setup (no-op if unsupported).
  Future<void> _configureLocalTimeZone() async {
    try {
      tz_data.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e, st) {
      debugPrint('Timezone setup failed, using UTC fallback: $e\n$st');
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Cancels every pending notification and rebuilds from [FriendService.getAllFriends].
  ///
  /// Parameters:
  /// - [friends]: service used to load friends.
  ///
  /// Returns: future that completes when scheduling finishes (or no-op on unsupported platforms).
  Future<void> rescheduleAll(FriendService friends) async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) {
      return;
    }

    try {
      final fingerprint = await _scheduleFingerprint(friends);
      final now = DateTime.now();
      if (_lastRescheduleFingerprint == fingerprint &&
          _lastRescheduleAt != null &&
          now.difference(_lastRescheduleAt!) < const Duration(seconds: 2)) {
        return;
      }

      await _plugin.cancelAll();
      final (hour, minute) = await NotificationSchedulePrefs.instance.loadReminderClock();
      final rows = await friends.getAllFriends();
      for (final friend in rows) {
        await _scheduleFriendNotifications(friend, hour, minute);
      }
      _lastRescheduleFingerprint = fingerprint;
      _lastRescheduleAt = now;
    } catch (e, st) {
      debugPrint('rescheduleAll failed: $e\n$st');
    }
  }

  /// Stable digest of schedule-driving friend fields + reminder clock.
  Future<String> _scheduleFingerprint(FriendService friends) async {
    final rows = await friends.getAllFriends();
    final (h, m) = await NotificationSchedulePrefs.instance.loadReminderClock();
    final buf = StringBuffer('$h:$m');
    for (final f in rows) {
      buf.write(
        '|${f.id}|${f.birthday.toIso8601String()}|${f.reminderIntervalDays}|${f.lastContactedAt?.toIso8601String() ?? '-'}',
      );
    }
    return buf.toString();
  }

  /// Unique stable id for the next birthday notification for [friendId].
  ///
  /// Parameters:
  /// - [friendId]: primary key.
  ///
  /// Returns: notification id in `100000–199999` range.
  static int birthdayNotificationId(int friendId) => 100000 + friendId;

  /// Stable id for the [slot]-th upcoming check-in notification for [friendId].
  ///
  /// Parameters:
  /// - [friendId]: primary key.
  /// - [slot]: zero-based index in the pre-scheduled lookahead chain.
  ///
  /// Returns: notification id outside birthday range.
  static int checkInNotificationId(int friendId, int slot) =>
      500000 + friendId * 32 + slot;

  /// Schedules birthday + lookahead check-ins for one row.
  ///
  /// Parameters:
  /// - [friend]: persisted friend.
  ///
  /// Returns: future completing after OS scheduling calls.
  Future<void> _scheduleFriendNotifications(
    FriendRow friend,
    int reminderHour,
    int reminderMinute,
  ) async {
    final local = tz.local;
    final nowTz = tz.TZDateTime.now(local);

    await _scheduleNextBirthday(friend, nowTz, local, reminderHour, reminderMinute);

    final slots = defaultTargetPlatform == TargetPlatform.iOS
        ? _checkInSlotsIos
        : _checkInSlotsAndroid;
    await _scheduleCheckIns(friend, nowTz, local, slots, reminderHour, reminderMinute);
  }

  /// Schedules the next birthday at [reminderHour]:[reminderMinute] local, rolling forward years if needed.
  ///
  /// Returns: future completing after [zonedSchedule] or skip on invalid state.
  Future<void> _scheduleNextBirthday(
    FriendRow friend,
    tz.TZDateTime nowTz,
    tz.Location location,
    int reminderHour,
    int reminderMinute,
  ) async {
    final nextCal = nextBirthdayOccurrence(friend.birthday, nowTz);
    var scheduled = tz.TZDateTime(
      location,
      nextCal.year,
      nextCal.month,
      nextCal.day,
      reminderHour,
      reminderMinute,
    );
    while (!scheduled.isAfter(nowTz)) {
      scheduled = tz.TZDateTime(
        location,
        scheduled.year + 1,
        friend.birthday.month,
        friend.birthday.day,
        reminderHour,
        reminderMinute,
      );
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _birthdayChannelId,
        'Birthdays',
        channelDescription: 'Friend birthday reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      birthdayNotificationId(friend.id),
      '🎂 ${friend.name}\'s birthday',
      'Wish them a great day!',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'birthday:${friend.id}',
    );
  }

  /// Schedules up to [slots] future check-ins from [FriendRow.createdAt], or from
  /// [FriendRow.lastContactedAt] when set (first fire is one interval after contact).
  ///
  /// Returns: future completing after batched scheduling.
  Future<void> _scheduleCheckIns(
    FriendRow friend,
    tz.TZDateTime nowTz,
    tz.Location location,
    int slots,
    int reminderHour,
    int reminderMinute,
  ) async {
    final intervalDays = friend.reminderIntervalDays;
    final base = friend.lastContactedAt ?? friend.createdAt;
    var anchor = tz.TZDateTime(
      location,
      base.year,
      base.month,
      base.day,
      reminderHour,
      reminderMinute,
    );
    if (friend.lastContactedAt != null) {
      anchor = anchor.add(Duration(days: intervalDays));
    }
    while (!anchor.isAfter(nowTz)) {
      anchor = anchor.add(Duration(days: intervalDays));
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _checkInChannelId,
        'Check-ins',
        channelDescription: 'Reach-out reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    var candidate = anchor;
    for (var slot = 0; slot < slots; slot++) {
      await _plugin.zonedSchedule(
        checkInNotificationId(friend.id, slot),
        'Say hi to ${friend.name}',
        'Time for a quick check-in ($intervalDays-day rhythm)',
        candidate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'checkin:${friend.id}',
      );
      candidate = candidate.add(Duration(days: intervalDays));
    }
  }
}

const String _birthdayChannelId = 'friends_reminder_birthdays';
const String _checkInChannelId = 'friends_reminder_checkins';
