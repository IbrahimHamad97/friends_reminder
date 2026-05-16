import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/friend_level.dart';
import '../utils/date_utils.dart';
import 'friend_avatar.dart';

/// Lightweight list row: avatar, name, birthday + cadence, optional group dots and occasion chips.
///
/// Closeness shows only as a slim **left accent** strip; mood, last chat, how you met, and
/// full notes live on [FriendDetailScreen] (`/friends/:id`).
class FriendCard extends StatelessWidget {
  /// Creates a tappable card for [friend].
  ///
  /// Parameters:
  /// - [friend]: row to render.
  /// - [onTap]: called when the card is pressed (open detail).
  /// - [referenceDate]: "today" anchor for countdown copy.
  /// - [groupAccentColors]: optional group color dots (usually `null` when shown under a group header).
  const FriendCard({
    super.key,
    required this.friend,
    required this.onTap,
    required this.referenceDate,
    this.groupAccentColors,
  });

  /// Underlying friend row.
  final FriendRow friend;

  /// Tap handler (navigate to detail).
  final VoidCallback onTap;

  /// Date used for "in N days" labels.
  final DateTime referenceDate;

  /// Optional group accent colors (small dots under the name; omit under group headers).
  final List<Color>? groupAccentColors;

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

  /// Builds the compact card: accent strip, avatar, name, optional dots, occasions, date + cadence.
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: ink surface with a left accent bar and a single content column.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = dateOnly(referenceDate);
    final isBirthday = isSameMonthDay(today, friend.birthday);
    final isReachOutDay = isReachOutRhythmDay(referenceDate, friend);
    final countdown =
        birthdayCountdownLabel(context, friend.birthday, referenceDate);
    final md = formatMonthDay(friend.birthday);
    final level = FriendLevel.fromStorage(friend.closenessLevel);
    final levelAccent = level.accentColor(scheme);

    Color cardSurface = scheme.surfaceContainerLow;
    if (isBirthday && isReachOutDay) {
      cardSurface =
          Color.lerp(scheme.primaryContainer, scheme.secondaryContainer, 0.45)!
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: levelAccent.withValues(
                    alpha: level == FriendLevel.regular ? 0.35 : 0.9,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                              ),
                              if (groupAccentColors != null &&
                                  groupAccentColors!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _GroupColorDots(colors: groupAccentColors!),
                              ],
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.25,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cadenceLine(friend.reminderIntervalDays),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant
                                          .withValues(alpha: 0.85),
                                    ),
                              ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small animated circles showing which groups a friend belongs to (used on ungrouped cards).
class _GroupColorDots extends StatelessWidget {
  /// Creates a row of up to six dots plus a `+N` overflow label.
  ///
  /// Parameters:
  /// - [colors]: group accent colors (typically from [GroupService] data).
  const _GroupColorDots({required this.colors});

  /// Group colors in display order.
  final List<Color> colors;

  /// Builds the dot row with staggered opacity/scale tweens.
  ///
  /// Parameters:
  /// - [context]: build context for theme colors.
  ///
  /// Returns: a [Row] of decorative indicators.
  @override
  Widget build(BuildContext context) {
    const maxDots = 6;
    final show =
        colors.length > maxDots ? colors.take(maxDots).toList() : colors;
    final extra = colors.length - show.length;
    return Row(
      children: [
        for (var i = 0; i < show.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 280 + i * 40),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                return Opacity(
                  opacity: t,
                  child: Transform.scale(scale: 0.3 + 0.7 * t, child: child),
                );
              },
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: show[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: show[i].withValues(alpha: 0.45),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (extra > 0)
          Text(
            '+$extra',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }
}

/// Pill-shaped label for birthday or check-in emphasis on [FriendCard].
class _OccasionChip extends StatelessWidget {
  /// Creates a chip with an icon and short label.
  ///
  /// Parameters:
  /// - [icon]: leading glyph.
  /// - [label]: short text (e.g. “Birthday”).
  /// - [foreground]: text/icon color on the pill.
  /// - [background]: pill fill color.
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

  /// Builds the rounded pill with icon + label.
  ///
  /// Parameters:
  /// - [context]: build context for [TextTheme].
  ///
  /// Returns: padded decorated row.
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
