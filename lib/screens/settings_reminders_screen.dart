import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/friend_service.dart';
import '../services/notification_schedule_prefs.dart';
import '../services/notification_scheduler.dart';
import '../widgets/notification_permission_banner.dart';

/// Reminder clock and how to turn notifications on.
class SettingsRemindersScreen extends StatefulWidget {
  const SettingsRemindersScreen({
    super.key,
    required this.friendService,
  });

  final FriendService friendService;

  @override
  State<SettingsRemindersScreen> createState() =>
      _SettingsRemindersScreenState();
}

class _SettingsRemindersScreenState extends State<SettingsRemindersScreen>
    with WidgetsBindingObserver, NotificationPermissionBannerHost {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _loadedClock = false;

  @override
  FriendService get notificationBannerFriendService => widget.friendService;

  @override
  void initState() {
    super.initState();
    initNotificationPermissionBanner();
    _loadReminderClock();
  }

  @override
  void dispose() {
    disposeNotificationPermissionBanner();
    super.dispose();
  }

  Future<void> _loadReminderClock() async {
    final (h, m) = await NotificationSchedulePrefs.instance.loadReminderClock();
    if (!mounted) {
      return;
    }
    setState(() {
      _reminderTime = TimeOfDay(hour: h, minute: m);
      _loadedClock = true;
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) {
      return;
    }
    await NotificationSchedulePrefs.instance
        .saveReminderClock(picked.hour, picked.minute);
    setState(() => _reminderTime = picked);
    await NotificationScheduler.instance.rescheduleAll(widget.friendService);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeLabel = _loadedClock
        ? MaterialLocalizations.of(context).formatTimeOfDay(
            _reminderTime,
            alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
          )
        : '…';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reminders'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.schedule_rounded, color: scheme.primary),
              title: const Text('Reminder time'),
              subtitle: Text(
                'Birthdays and check-ins both use this clock.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              trailing: Text(
                timeLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
              ),
              onTap: _pickReminderTime,
            ),
          ),
          if (notificationBannerVisible) ...[
            const SizedBox(height: 12),
            NotificationPermissionBanner.detailed(
              busy: notificationBannerBusy,
              onEnable: onNotificationBannerEnable,
              title: 'Enable notifications',
              body:
                  'When you create a friend and want a reminder for when to reach out—'
                  'or on their birthday—this app uses on-device notifications. '
                  'Tap Enable to show the system permission prompt. '
                  'If notifications were permanently denied, you will be taken to system settings instead.',
            ),
          ] else if (exactAlarmBannerVisible) ...[
            const SizedBox(height: 12),
            ExactAlarmPermissionBanner.detailed(
              busy: exactAlarmBannerBusy,
              onEnable: onExactAlarmBannerEnable,
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Local notifications',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reminders stay on this device (no cloud push).\n\n'
                    'Android — Settings → Apps → Friends Reminder → Notifications. '
                    'On Android 12+, also allow Alarms & reminders for on-time delivery '
                    '(use the banner above when that access is off).\n\n'
                    'iOS — Settings → Notifications → Friends Reminder.\n\n'
                    'Battery savers can still delay delivery.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
