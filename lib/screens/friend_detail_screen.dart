import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../models/friend_level.dart';
import '../models/friend_mood.dart';
import '../services/friend_service.dart';
import '../services/group_service.dart';
import '../services/notification_scheduler.dart';
import '../utils/check_in_flow.dart';
import '../utils/check_in_interval.dart';
import '../utils/date_utils.dart'
    show
        dateOnly,
        birthdayCountdownLabel,
        formatMonthDay,
        isReachOutRhythmDay,
        isSameMonthDay,
        lastContactedSummary;
import '../utils/friend_phone.dart';
import '../widgets/check_in_action_card.dart';
import '../widgets/friend_avatar.dart';

/// Read-focused view for one friend: closeness, mood, context, and actions before editing.
class FriendDetailScreen extends StatefulWidget {
  const FriendDetailScreen({
    super.key,
    required this.friendService,
    required this.groupService,
    required this.friendId,
  });

  final FriendService friendService;
  final GroupService groupService;
  final int friendId;

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late Future<List<GroupRow>> _groupsFuture;
  StreamSubscription<List<FriendGroupLinkRow>>? _linkSub;
  bool _loggingCheckIn = false;

  @override
  void initState() {
    super.initState();
    _groupsFuture = widget.groupService.getGroupsForFriend(widget.friendId);
    _linkSub = widget.groupService.watchFriendGroupLinks().listen((_) {
      if (mounted) {
        setState(() {
          _groupsFuture =
              widget.groupService.getGroupsForFriend(widget.friendId);
        });
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _logCheckIn(BuildContext context, FriendRow friend) async {
    if (_loggingCheckIn) {
      return;
    }
    setState(() => _loggingCheckIn = true);
    try {
      await runLogCheckInFlow(
        context,
        friendService: widget.friendService,
        friend: friend,
        reschedule: _reschedule,
      );
    } finally {
      if (mounted) {
        setState(() => _loggingCheckIn = false);
      }
    }
  }

  Future<void> _confirmUndoLastCheckIn(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Undo last check-in?'),
              content: const Text(
                'This removes the date you logged reaching out. '
                'Their next reminder will count from when you added them—not from your last check-in.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Keep check-in'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Undo check-in'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!ok || !context.mounted) {
      return;
    }
    await _clearLastContacted(context);
  }

  Future<void> _clearLastContacted(BuildContext context) async {
    await widget.friendService.setLastContactedAt(widget.friendId, null);
    await _reschedule();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Last check-in removed. Next reminder counts from when you added them.',
          ),
        ),
      );
    }
  }

  Future<void> _reschedule() async {
    try {
      await NotificationScheduler.instance.rescheduleAll(widget.friendService);
    } catch (_) {}
  }

  Future<void> _openCall(BuildContext context, String phone) async {
    final ok = await launchFriendPhoneCall(phone);
    if (!context.mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the phone app')),
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final ok = await launchFriendWhatsApp(phone);
    if (!context.mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open WhatsApp — is it installed?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: StreamBuilder<List<FriendRow>>(
        stream: widget.friendService.watchAllFriends(),
        builder: (context, snapshot) {
          final rows = snapshot.data;
          if (rows == null) {
            return const Center(child: CircularProgressIndicator());
          }
          FriendRow? friend;
          for (final r in rows) {
            if (r.id == widget.friendId) {
              friend = r;
              break;
            }
          }
          if (friend == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Friend not found',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final f = friend;
          final level = FriendLevel.fromStorage(f.closenessLevel);
          final mood = FriendMood.fromStorage(f.moodTag);
          final today = DateTime.now();
          final isBirthday = isSameMonthDay(dateOnly(today), f.birthday);
          final isReachOut = isReachOutRhythmDay(today, f);
          final chat = (f.lastChatSnippet ?? '').trim();
          final met = (f.howWeMet ?? '').trim();
          final notes = (f.notes ?? '').trim();
          final phone = (f.phoneNumber ?? '').trim();
          final lastAt = f.lastContactedAt;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(8, topInset + 8, 8, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: () => context.push('/friends/${f.id}/edit'),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FriendAvatar(
                        name: f.name,
                        photoPath: f.photoPath,
                        radius: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _DetailChip(
                                  icon: level.icon,
                                  label: level.label,
                                  foreground: level.chipForeground(scheme),
                                  background: level.chipBackground(scheme),
                                ),
                                if (mood != null)
                                  _DetailChip(
                                    icon: mood.icon,
                                    label: mood.label,
                                    foreground: mood.chipForeground(scheme),
                                    background: mood.chipBackground(scheme),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isBirthday)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: _OccasionBanner(
                      icon: Icons.cake_rounded,
                      label: 'Birthday today',
                      color: scheme.primaryContainer,
                      onText: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, isBirthday ? 4 : 0, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: CheckInActionCard(
                    friendName: f.name,
                    isDue: isReachOut,
                    isLoading: _loggingCheckIn,
                    onLogCheckIn: () => _logCheckIn(context, f),
                  ),
                ),
              ),
              if (phone.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionCard(
                      title: 'Contact',
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatFriendPhoneDisplay(phone),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: 'Call',
                            onPressed: () => _openCall(context, phone),
                            icon: const Icon(Icons.call_rounded),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'WhatsApp',
                            onPressed: () => _openWhatsApp(context, phone),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366)
                                  .withValues(alpha: 0.18),
                              foregroundColor: const Color(0xFF128C7E),
                            ),
                            icon: const Icon(Icons.chat_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatMonthDay(f.birthday)} · ${birthdayCountdownLabel(context, f.birthday, today)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          checkInCadenceLabel(f),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                        if (lastAt != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            lastContactedSummary(lastAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reminders are counting from that check-in.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _confirmUndoLastCheckIn(context),
                            icon: const Icon(Icons.undo_rounded, size: 20),
                            label: const Text('Undo last check-in'),
                            style: OutlinedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<GroupRow>>(
                  future: _groupsFuture,
                  builder: (context, snap) {
                    final groupRows = snap.data;
                    if (groupRows == null || groupRows.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _SectionCard(
                        title: 'Groups',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: groupRows.map((g) {
                            final c = Color(g.colorArgb);
                            return Chip(
                              avatar: CircleAvatar(
                                backgroundColor: c,
                                radius: 8,
                                child: const SizedBox.shrink(),
                              ),
                              label: Text(g.name),
                              side: BorderSide(
                                  color: scheme.outlineVariant
                                      .withValues(alpha: 0.5)),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (met.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionCard(
                      title: 'How you met',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.push_pin_outlined,
                              size: 18, color: scheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              met,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (chat.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionCard(
                      title: 'Last conversation',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 18, color: scheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              chat,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (notes.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionCard(
                      title: 'Notes',
                      child: Text(
                        notes,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.45),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccasionBanner extends StatelessWidget {
  const _OccasionBanner({
    required this.icon,
    required this.label,
    required this.color,
    required this.onText,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color onText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: onText),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: onText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
