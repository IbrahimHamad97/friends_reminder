import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/friend_service.dart';
import '../services/theme_service.dart';
import '../widgets/notification_permission_banner.dart';

/// Settings hub: a short list of destinations for appearance, reminders, and data.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeService,
    required this.friendService,
  });

  final ThemeService themeService;
  final FriendService friendService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver, NotificationPermissionBannerHost {
  @override
  FriendService get notificationBannerFriendService => widget.friendService;

  @override
  void initState() {
    super.initState();
    initNotificationPermissionBanner();
  }

  @override
  void dispose() {
    disposeNotificationPermissionBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: widget.themeService,
      builder: (context, _) {
        final themeLabel = widget.themeService.preferenceLabel;
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Settings',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _SettingsTile(
                              icon: Icons.palette_outlined,
                              title: 'Appearance',
                              subtitle: 'Theme · $themeLabel',
                              onTap: () =>
                                  context.push('/settings/appearance'),
                            ),
                            const SizedBox(height: 10),
                            _SettingsTile(
                              icon: Icons.notifications_active_outlined,
                              title: 'Reminders',
                              subtitle: 'Time of day & notification help',
                              onTap: () =>
                                  context.push('/settings/reminders'),
                            ),
                            const SizedBox(height: 10),
                            _SettingsTile(
                              icon: Icons.folder_outlined,
                              title: 'Data & privacy',
                              subtitle: 'Export backup · on-device storage',
                              onTap: () => context.push('/settings/data'),
                            ),
                            if (notificationBannerVisible) ...[
                              const SizedBox(height: 20),
                              NotificationPermissionBanner.detailed(
                                busy: notificationBannerBusy,
                                onEnable: onNotificationBannerEnable,
                                title: 'Notifications are off',
                                body:
                                    'To get a nudge when it is time to text a friend, '
                                    'or on their birthday, allow notifications for this app. '
                                    'Tap below to open the system permission prompt.',
                              ),
                            ] else if (exactAlarmBannerVisible) ...[
                              const SizedBox(height: 20),
                              ExactAlarmPermissionBanner.detailed(
                                busy: exactAlarmBannerBusy,
                                onEnable: onExactAlarmBannerEnable,
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text(
                              'Friends Reminder keeps everything on this device.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: scheme.primary),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: scheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
