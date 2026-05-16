import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../services/friend_service.dart';
import '../services/notification_schedule_prefs.dart';
import '../services/notification_scheduler.dart';
import '../utils/date_utils.dart';
import '../utils/home_dashboard_logic.dart';
import '../widgets/friend_avatar.dart';

/// Dashboard tab: upcoming birthdays through year-end and the next check-in reminders.
///
/// Uses [FriendService.watchAllFriends] so it stays in sync with edits elsewhere.
/// Shows a **one-time** notification-permission dialog on supported platforms.
class HomeScreen extends StatefulWidget {
  /// Creates the home dashboard.
  ///
  /// Parameters:
  /// - [friendService]: source of friend rows.
  const HomeScreen({super.key, required this.friendService});

  /// Friend persistence and watch API.
  final FriendService friendService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptForNotifications();
    });
  }

  /// One-time OS permission prompt; completed flag is set for either choice.
  Future<void> _maybePromptForNotifications() async {
    if (!mounted) {
      return;
    }
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    if (await NotificationSchedulePrefs.instance.wasHomeNotificationPromptCompleted()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enable reminders?'),
          content: const Text(
            'Friends Reminder uses on-device notifications for birthdays and check-ins. '
            'You can pick the time of day in Settings after allowing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );

    await NotificationSchedulePrefs.instance.markHomeNotificationPromptCompleted();
    if (!mounted) {
      return;
    }

    if (allowed == true) {
      await NotificationScheduler.instance.requestOsNotificationPermissions();
      await NotificationScheduler.instance.rescheduleAll(widget.friendService);
      if (!mounted) {
        return;
      }
      context.go('/settings');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You can turn notifications on later: open the Settings tab and read '
            '“Local notifications” for steps (including Android exact-alarm access).',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final topInset = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<List<FriendRow>>(
        stream: widget.friendService.watchAllFriends(),
        builder: (context, snapshot) {
          final friends = snapshot.data ?? [];
          final busy = snapshot.connectionState == ConnectionState.waiting &&
              friends.isEmpty;

          if (busy) {
            return const Center(child: CircularProgressIndicator());
          }

          if (friends.isEmpty) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Home',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Add friends from the Friends tab to see birthdays and check-in reminders here.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final birthdays = upcomingBirthdaysThroughYearEnd(friends, today);
          final checkIns = nextCheckInReminders(friends, today, limit: 10);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Home',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Next check-ins',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 8),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 128,
                    child: checkIns.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'No check-in reminders scheduled—add intervals on each friend or adjust settings.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            itemCount: checkIns.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = checkIns[index];
                              final label =
                                  checkInReminderLabel(today, item.nextCheckIn);
                              return _HorizontalReminderCard(
                                friend: item.friend,
                                subtitle: label,
                                onTap: () => context
                                    .push('/friends/${item.friend.id}'),
                              );
                            },
                          ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Birthdays through December',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Upcoming birthdays for the rest of ${today.year}.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              if (birthdays.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Text(
                      'No more birthdays left this calendar year—see you in January!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final b = birthdays[index];
                        final when = formatMonthDay(b.nextBirthday);
                        final countdown = birthdayCountdownLabel(
                            context, b.friend.birthday, today);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  context.push('/friends/${b.friend.id}'),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    FriendAvatar(
                                      name: b.friend.name,
                                      photoPath: b.friend.photoPath,
                                      radius: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.friend.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$when · $countdown',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.cake_outlined,
                                        color: scheme.primary, size: 22),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: birthdays.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact horizontal card for the next check-in strip.
class _HorizontalReminderCard extends StatelessWidget {
  const _HorizontalReminderCard({
    required this.friend,
    required this.subtitle,
    required this.onTap,
  });

  final FriendRow friend;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 168,
      child: Material(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FriendAvatar(
                  name: friend.name,
                  photoPath: friend.photoPath,
                  radius: 20,
                ),
                const SizedBox(height: 10),
                Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
