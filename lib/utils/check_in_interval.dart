import 'dart:math';

import '../data/database.dart';
import '../models/friend_level.dart';

/// Rolls a check-in interval from [baseDays] and [level] variance, or returns [baseDays] when fixed.
int rollCheckInIntervalDays({
  required int baseDays,
  required FriendLevel level,
  required bool randomEnabled,
  Random? random,
}) {
  if (!randomEnabled) {
    return baseDays.clamp(1, 365);
  }
  final rng = random ?? Random();
  final (minVar, maxVar) = level.randomVarianceDays;
  final magnitude = minVar + rng.nextInt(maxVar - minVar + 1);
  final signed = rng.nextBool() ? magnitude : -magnitude;
  return (baseDays + signed).clamp(1, 365);
}

/// Interval used for the current check-in cycle (rolled or fixed).
int effectiveCheckInIntervalDays(FriendRow friend) {
  if (!friend.useRandomCheckIn) {
    return friend.reminderIntervalDays;
  }
  return friend.activeCheckInIntervalDays.clamp(1, 365);
}

/// Calendar date when the next check-in is due (first cycle starts one interval after anchor).
DateTime nextCheckInDueDate(FriendRow friend) {
  final interval = effectiveCheckInIntervalDays(friend);
  final base = friend.lastContactedAt ?? friend.createdAt;
  final local = base.toLocal();
  return DateTime(local.year, local.month, local.day).add(Duration(days: interval));
}

/// Resolves [activeCheckInIntervalDays] when saving or after reaching out.
int resolveActiveCheckInIntervalDays({
  required int reminderIntervalDays,
  required FriendLevel level,
  required bool useRandomCheckIn,
  Random? random,
}) {
  return rollCheckInIntervalDays(
    baseDays: reminderIntervalDays,
    level: level,
    randomEnabled: useRandomCheckIn,
    random: random,
  );
}

/// Short cadence line for cards and detail (respects random timing when enabled).
String checkInCadenceLabel(FriendRow friend) {
  final base = friend.reminderIntervalDays;
  if (friend.useRandomCheckIn) {
    final current = effectiveCheckInIntervalDays(friend);
    if (base == 7) {
      return 'Check-in about weekly (~$current days this cycle)';
    }
    if (base == 14) {
      return 'Check-in about every 2 weeks (~$current days this cycle)';
    }
    return 'Check-in about every $base days (~$current days this cycle)';
  }
  if (base == 1) {
    return 'Daily check-in reminder';
  }
  if (base == 7) {
    return 'Weekly check-in reminder';
  }
  return 'Check-in every $base days';
}
