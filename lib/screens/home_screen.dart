import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../services/friend_service.dart';
import '../utils/date_utils.dart';
import '../utils/home_dashboard_logic.dart';
import '../widgets/friend_avatar.dart';
import '../widgets/notification_permission_banner.dart';

/// Dashboard tab: upcoming birthdays through year-end and the next check-in reminders.
///
/// Uses [FriendService.watchAllFriends] so it stays in sync with edits elsewhere.
/// Soft notification opt-in via a bottom banner (no auto dialog on open).
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

class _HomeScreenState extends State<HomeScreen>
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
    final today = DateTime.now();
    final topInset = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<FriendRow>>(
              stream: widget.friendService.watchAllFriends(),
              builder: (context, snapshot) {
                final allFriends = snapshot.data ?? [];
                final friends =
                    allFriends.where((f) => !f.isFrozen).toList(growable: false);
                final busy = snapshot.connectionState ==
                        ConnectionState.waiting &&
                    allFriends.isEmpty;

                if (busy) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (friends.isEmpty) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding:
                            EdgeInsets.fromLTRB(20, topInset + 24, 20, 8),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Home',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
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
                              allFriends.isEmpty
                                  ? 'Add friends from the Friends tab to see birthdays and check-in reminders here.'
                                  : 'All friends are frozen. Unfreeze someone from their profile to see reminders here again.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final birthdays =
                    upcomingBirthdaysThroughYearEnd(friends, today);
                final checkIns =
                    nextCheckInReminders(friends, today, limit: 10);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(20, topInset + 24, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Home',
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Next check-ins',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  itemCount: checkIns.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final item = checkIns[index];
                                    final label = checkInReminderLabel(
                                      today,
                                      item.nextCheckIn,
                                    );
                                    return _HorizontalReminderCard(
                                      friend: item.friend,
                                      subtitle: label,
                                      onTap: () => context.push(
                                        '/friends/${item.friend.id}',
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Birthdays this year',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    if (birthdays.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          child: Text(
                            'No more birthdays left this calendar year—see you in January!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                                    onTap: () => context
                                        .push('/friends/${b.friend.id}'),
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
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '$when · $countdown',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
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
          ),
          if (notificationBannerVisible)
            NotificationPermissionBanner.compact(
              busy: notificationBannerBusy,
              onEnable: onNotificationBannerEnable,
            )
          else if (exactAlarmBannerVisible)
            ExactAlarmPermissionBanner.compact(
              busy: exactAlarmBannerBusy,
              onEnable: onExactAlarmBannerEnable,
            ),
        ],
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
