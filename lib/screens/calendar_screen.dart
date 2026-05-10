import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/database.dart';
import '../models/upcoming_birthday.dart';
import '../services/friend_service.dart';
import '../utils/date_utils.dart';
import '../utils/upcoming_birthdays.dart';
import '../widgets/friend_avatar.dart';

/// Month calendar with birthday highlights, selected-day list, and next-30-days list.
class CalendarScreen extends StatefulWidget {
  /// Creates a calendar bound to [friendService].
  ///
  /// Parameters:
  /// - [friendService]: provides live friend rows for markers and lists.
  const CalendarScreen({super.key, required this.friendService});

  /// Data access for friends.
  final FriendService friendService;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// Maps a calendar day to friends whose birthday falls on that month/day.
  ///
  /// Parameters:
  /// - [friends]: full friend list.
  /// - [day]: calendar day (time-of-day ignored by [isSameMonthDay]).
  ///
  /// Returns: matching friends (may be empty).
  List<FriendRow> _friendsForDay(List<FriendRow> friends, DateTime day) {
    return friends.where((f) => isSameMonthDay(day, f.birthday)).toList();
  }

  /// Label for how soon an upcoming birthday is.
  ///
  /// Parameters:
  /// - [daysUntil]: zero for today, otherwise positive.
  ///
  /// Returns: short English phrase.
  String _horizonLabel(int daysUntil) {
    if (daysUntil == 0) {
      return 'Today';
    }
    if (daysUntil == 1) {
      return 'Tomorrow';
    }
    return 'In $daysUntil days';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final today = DateTime.now();

    return Scaffold(
      body: StreamBuilder<List<FriendRow>>(
        stream: widget.friendService.watchAllFriends(),
        builder: (context, snapshot) {
          final friends = snapshot.data ?? <FriendRow>[];
          final selectedFriends =
              friends.where((f) => isSameMonthDay(_selectedDay, f.birthday)).toList();
          final upcoming = upcomingBirthdaysWithinHorizon(
            friends,
            from: today,
            withinDays: 30,
          );

          return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Birthday calendar',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  sliver: SliverToBoxAdapter(
                    child: _UpcomingSection(
                      entries: upcoming,
                      onOpenFriend: (id) => context.push('/friends/$id/edit'),
                      labelForDays: _horizonLabel,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TableCalendar<FriendRow>(
                          firstDay: DateTime.utc(1900, 1, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selectedDay = selected;
                              _focusedDay = focused;
                            });
                          },
                          onPageChanged: (focused) {
                            _focusedDay = focused;
                          },
                          eventLoader: (day) => _friendsForDay(friends, day),
                          calendarStyle: CalendarStyle(
                            markersMaxCount: 0,
                            todayDecoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(color: scheme.onPrimary),
                            outsideDaysVisible: false,
                          ),
                          calendarBuilders: CalendarBuilders(
                            selectedBuilder: (context, day, focusedDay) {
                              final hasBirthday =
                                  _friendsForDay(friends, day).isNotEmpty;
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                  border: hasBirthday
                                      ? Border.all(color: scheme.tertiary, width: 2.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                            todayBuilder: (context, day, focusedDay) {
                              if (isSameDay(day, _selectedDay)) {
                                return null;
                              }
                              final hasBirthday =
                                  _friendsForDay(friends, day).isNotEmpty;
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                  border: hasBirthday
                                      ? Border.all(color: scheme.tertiary, width: 2.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (context, day, focusedDay) {
                              if (isSameDay(day, _selectedDay) ||
                                  isSameDay(day, today)) {
                                return null;
                              }
                              if (_friendsForDay(friends, day).isEmpty) {
                                return null;
                              }
                              return Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: scheme.tertiary, width: 2),
                                  color: scheme.tertiaryContainer.withValues(alpha: 0.35),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(color: scheme.onSurface),
                                ),
                              );
                            },
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle:
                                Theme.of(context).textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Birthdays on ${MaterialLocalizations.of(context).formatFullDate(_selectedDay)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                if (selectedFriends.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      child: Text(
                        'No birthdays on this day. Tap a highlighted date or add a friend.',
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
                          final friend = selectedFriends[index];
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            leading: FriendAvatar(
                              name: friend.name,
                              photoPath: friend.photoPath,
                              radius: 22,
                            ),
                            title: Text(
                              friend.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(formatMonthDay(friend.birthday)),
                            trailing: const Icon(Icons.edit_outlined),
                            onTap: () => context.push('/friends/${friend.id}/edit'),
                          );
                        },
                        childCount: selectedFriends.length,
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

/// Scrollable row of chips for the next 30 days of birthdays.
class _UpcomingSection extends StatelessWidget {
  /// Builds the upcoming birthday horizontal list or an empty hint.
  ///
  /// Parameters:
  /// - [entries]: precomputed horizon rows.
  /// - [onOpenFriend]: navigates to edit for the given friend id.
  /// - [labelForDays]: maps `daysUntil` to a short label.
  const _UpcomingSection({
    required this.entries,
    required this.onOpenFriend,
    required this.labelForDays,
  });

  /// Upcoming birthday rows (may be empty).
  final List<UpcomingBirthdayEntry> entries;

  /// Opens the edit route for a friend id.
  final void Function(int id) onOpenFriend;

  /// Maps day distance to UI copy.
  final String Function(int daysUntil) labelForDays;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 30 days',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          Text(
            'No birthdays in the next 30 days.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          )
        else
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final e = entries[index];
                return Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onOpenFriend(e.friend.id),
                    child: SizedBox(
                      width: 168,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            FriendAvatar(
                              name: e.friend.name,
                              photoPath: e.friend.photoPath,
                              radius: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.friend.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    labelForDays(e.daysUntil),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    formatMonthDay(e.nextOccurrence),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
