import 'package:flutter/material.dart';

import '../services/friend_service.dart';
import '../services/notification_scheduler.dart';

/// Soft opt-in for OS notification permission (no auto-prompt on launch).
///
/// Use [NotificationPermissionBanner.compact] on Home and
/// [NotificationPermissionBanner.detailed] on Settings / Reminders.
class NotificationPermissionBanner extends StatelessWidget {
  /// Slim bottom strip: short copy + Enable.
  const NotificationPermissionBanner.compact({
    super.key,
    required this.onEnable,
    this.busy = false,
  })  : detailed = false,
        title = 'Enable notifications',
        body = 'Enable notifications to make full use of the app.';

  /// Larger card with explanation and primary CTA.
  const NotificationPermissionBanner.detailed({
    super.key,
    required this.onEnable,
    this.busy = false,
    this.title = 'Turn on notifications',
    this.body =
        'When you add a friend, Friends Reminder schedules check-in and birthday alerts. '
        'To get those reminders, notifications need to be allowed for this app.',
  }) : detailed = true;

  /// Whether this is the expanded Settings-style card.
  final bool detailed;

  /// Headline (detailed) or unused for compact layout title chip.
  final String title;

  /// Supporting copy.
  final String body;

  /// Invoked when the user taps Enable / Allow.
  final VoidCallback onEnable;

  /// Disables the button while a permission request is in flight.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return detailed ? _buildDetailed(context) : _buildCompact(context);
  }

  Widget _buildCompact(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.92),
      elevation: 1,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: busy ? null : onEnable,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enable'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailed(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : onEnable,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.notifications_rounded, size: 20),
                label: Text(busy ? 'Opening…' : 'Enable notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft opt-in for Android exact alarms (reliable reminder fire times).
///
/// Shown only when notifications are already allowed but exact alarms are not.
class ExactAlarmPermissionBanner extends StatelessWidget {
  /// Slim Home strip.
  const ExactAlarmPermissionBanner.compact({
    super.key,
    required this.onEnable,
    this.busy = false,
  })  : detailed = false,
        title = 'Allow exact alarms',
        body = 'Allow Alarms & reminders for on-time check-ins.';

  /// Larger Settings / Reminders card.
  const ExactAlarmPermissionBanner.detailed({
    super.key,
    required this.onEnable,
    this.busy = false,
    this.title = 'Allow exact alarms',
    this.body =
        'Notifications are on, but Android still needs Alarms & reminders '
        'access so birthday and check-in alerts fire at the time you chose. '
        'Without it, reminders may arrive late or batch with other apps.',
  }) : detailed = true;

  final bool detailed;
  final String title;
  final String body;
  final VoidCallback onEnable;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return detailed ? _buildDetailed(context) : _buildCompact(context);
  }

  Widget _buildCompact(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer.withValues(alpha: 0.92),
      elevation: 1,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              Icon(
                Icons.alarm_outlined,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: busy ? null : onEnable,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Allow'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailed(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm_on_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : onEnable,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.alarm_rounded, size: 20),
                label: Text(busy ? 'Opening…' : 'Open Alarms & reminders'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared banner visibility + Enable tap for notification and exact-alarm prompts.
///
/// Mix in after [WidgetsBindingObserver], e.g.
/// `with WidgetsBindingObserver, NotificationPermissionBannerHost`.
///
/// Notification banner takes priority over the exact-alarm banner.
mixin NotificationPermissionBannerHost<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  bool notificationBannerVisible = false;
  bool exactAlarmBannerVisible = false;
  bool notificationBannerBusy = false;
  bool exactAlarmBannerBusy = false;

  /// Retrieves the friend service for rescheduling after permission changes.
  FriendService get notificationBannerFriendService;

  /// Starts observing lifecycle and loads current OS permission state.
  void initNotificationPermissionBanner() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshNotificationPermissionBanner();
    });
  }

  /// Stops observing lifecycle (call from [State.dispose]).
  void disposeNotificationPermissionBanner() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshNotificationPermissionBanner();
    }
  }

  /// Updates notification + exact-alarm banner visibility from OS state.
  Future<void> refreshNotificationPermissionBanner() async {
    final scheduler = NotificationScheduler.instance;

    var showNotification = false;
    if (scheduler.supportsOsNotificationPermissionPrompt) {
      final enabled = await scheduler.areOsNotificationsEnabled();
      showNotification = !enabled;
    }

    var showExact = false;
    if (!showNotification) {
      showExact = await scheduler.needsExactAlarmOptIn();
    }

    if (!mounted) {
      return;
    }
    setState(() {
      notificationBannerVisible = showNotification;
      exactAlarmBannerVisible = showExact;
    });
  }

  /// Banner Enable: OS notification dialog, or app settings if permanently denied.
  Future<void> onNotificationBannerEnable() async {
    if (notificationBannerBusy) {
      return;
    }
    setState(() => notificationBannerBusy = true);
    try {
      await NotificationScheduler.instance
          .enableOsNotificationsFromUserGesture();
      await NotificationScheduler.instance
          .rescheduleAll(notificationBannerFriendService);
      await refreshNotificationPermissionBanner();
    } finally {
      if (mounted) {
        setState(() => notificationBannerBusy = false);
      }
    }
  }

  /// Exact-alarm banner: opens Android Alarms & reminders access.
  Future<void> onExactAlarmBannerEnable() async {
    if (exactAlarmBannerBusy) {
      return;
    }
    setState(() => exactAlarmBannerBusy = true);
    try {
      await NotificationScheduler.instance.enableExactAlarmsFromUserGesture();
      await NotificationScheduler.instance
          .rescheduleAll(notificationBannerFriendService);
      await refreshNotificationPermissionBanner();
    } finally {
      if (mounted) {
        setState(() => exactAlarmBannerBusy = false);
      }
    }
  }
}
