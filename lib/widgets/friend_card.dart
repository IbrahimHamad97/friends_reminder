import 'package:flutter/material.dart';

import '../data/database.dart';
import '../utils/date_utils.dart';
import 'friend_avatar.dart';

/// Compact row-style card for one [FriendRow]—minimal chrome, easy to scan.
class FriendCard extends StatelessWidget {
  /// Creates a tappable card for [friend].
  ///
  /// Parameters:
  /// - [friend]: row to render.
  /// - [onTap]: called when the card is pressed.
  /// - [referenceDate]: "today" anchor for countdown copy.
  const FriendCard({
    super.key,
    required this.friend,
    required this.onTap,
    required this.referenceDate,
  });

  /// Underlying friend row.
  final FriendRow friend;

  /// Tap handler (navigate to detail/edit).
  final VoidCallback onTap;

  /// Date used for "in N days" labels.
  final DateTime referenceDate;

  /// One short line for the remind cadence.
  ///
  /// Parameters:
  /// - [days]: [FriendRow.reminderIntervalDays].
  ///
  /// Returns: human-readable cadence.
  String _cadenceLine(int days) {
    if (days == 1) {
      return 'Daily check-in reminder';
    }
    if (days == 7) {
      return 'Weekly check-in reminder';
    }
    return 'Check-in every $days days';
  }

  /// Builds a flat card: avatar, name, date line, cadence, optional notes.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: ink surface with a single visual column of text.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = dateOnly(referenceDate);
    final isBirthday = isSameMonthDay(today, friend.birthday);
    final isReachOutDay = isReachOutRhythmDay(referenceDate, friend);
    final countdown = birthdayCountdownLabel(context, friend.birthday, referenceDate);
    final md = formatMonthDay(friend.birthday);
    final notesPreview = (friend.notes ?? '').trim();

    Color cardSurface = scheme.surfaceContainerLow;
    if (isBirthday && isReachOutDay) {
      cardSurface = Color.lerp(scheme.primaryContainer, scheme.secondaryContainer, 0.45)!
          .withValues(alpha: 0.55);
    } else if (isBirthday) {
      cardSurface = scheme.primaryContainer.withValues(alpha: 0.42);
    } else if (isReachOutDay) {
      cardSurface = scheme.secondaryContainer.withValues(alpha: 0.38);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cardSurface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FriendAvatar(
                  name: friend.name,
                  photoPath: friend.photoPath,
                  radius: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                      ),
                      if (isBirthday || isReachOutDay) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (isBirthday)
                              _OccasionChip(
                                icon: Icons.cake_rounded,
                                label: 'Birthday',
                                foreground: scheme.onPrimaryContainer,
                                background: scheme.primaryContainer,
                              ),
                            if (isReachOutDay)
                              _OccasionChip(
                                icon: Icons.mark_chat_unread_rounded,
                                label: 'Check-in day',
                                foreground: scheme.onTertiaryContainer,
                                background: scheme.tertiaryContainer,
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '$md · $countdown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cadenceLine(friend.reminderIntervalDays),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                            ),
                      ),
                      if (notesPreview.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          notesPreview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                height: 1.35,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.outline,
                    size: 22,
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

class _OccasionChip extends StatelessWidget {
  const _OccasionChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
