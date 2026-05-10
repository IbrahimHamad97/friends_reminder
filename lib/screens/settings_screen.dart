import 'package:flutter/material.dart';

import '../services/friend_service.dart';
import '../services/friends_backup_export.dart';
import '../services/notification_schedule_prefs.dart';
import '../services/notification_scheduler.dart';
import '../services/theme_service.dart';

/// Theme, reminder time, and privacy notes.
class SettingsScreen extends StatefulWidget {
  /// Creates settings bound to services.
  ///
  /// Parameters:
  /// - [themeService]: persisted brightness preference.
  /// - [friendService]: used to reschedule notifications after time changes.
  const SettingsScreen({
    super.key,
    required this.themeService,
    required this.friendService,
  });

  /// Theme persistence and notifier.
  final ThemeService themeService;

  /// Friend data for rebuilding notification schedules.
  final FriendService friendService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _loadedClock = false;

  @override
  void initState() {
    super.initState();
    _loadReminderClock();
  }

  /// Loads saved reminder hour/minute into [_reminderTime].
  ///
  /// Returns: future completing when prefs are read.
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

  /// Opens the platform time picker and persists + reschedules OS alarms.
  ///
  /// Returns: future completing after save or cancel.
  bool _exporting = false;

  /// Shares a JSON snapshot of all friends (no photos).
  Future<void> _exportBackup() async {
    if (_exporting) {
      return;
    }
    setState(() => _exporting = true);
    try {
      await FriendsBackupExport.shareJson(widget.friendService);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) {
      return;
    }
    await NotificationSchedulePrefs.instance.saveReminderClock(picked.hour, picked.minute);
    setState(() => _reminderTime = picked);
    await NotificationScheduler.instance.rescheduleAll(widget.friendService);
  }

  /// Builds theme controls, reminder time row, and cards.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: scrollable settings layout.
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;
    final timeLabel = _loadedClock
        ? MaterialLocalizations.of(context).formatTimeOfDay(
              _reminderTime,
              alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
            )
        : '…';

    return AnimatedBuilder(
      animation: widget.themeService,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto_rounded),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Day'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Night'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                        ],
                        selected: {widget.themeService.mode},
                        onSelectionChanged: (selection) {
                          widget.themeService.setMode(selection.first);
                        },
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Reminders',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.schedule_rounded, color: scheme.primary),
                          title: const Text('Reminder time'),
                          subtitle: Text(
                            'Birthdays and check-ins both use this clock — '
                            'default was 9:00 AM, not midnight or noon.',
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
                          onTap: () => _pickReminderTime(context),
                        ),
                      ),
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
                                    Icons.notifications_active_outlined,
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
                                'Everything runs on-device (no FCM). Allow notifications and, on '
                                'Android 14+, allow Alarms & reminders so fire times stay accurate. '
                                'Battery-saving modes can still delay alerts on some phones.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.upload_file_rounded, color: scheme.primary),
                          title: const Text('Export backup'),
                          subtitle: Text(
                            'JSON file with names, dates, notes, and cadence (photos stay on device).',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          trailing: _exporting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.share_rounded),
                          onTap: _exporting ? null : _exportBackup,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: const Text('On-device storage'),
                          subtitle: const Text(
                            'Friends live in a local SQLite database via Drift—nothing leaves your phone in this build.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
