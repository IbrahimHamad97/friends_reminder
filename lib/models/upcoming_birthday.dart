import '../data/database.dart';

/// One row in an “upcoming birthdays” list with precomputed dates.
class UpcomingBirthdayEntry {
  /// Wraps a friend with their next occurrence and distance from the anchor day.
  ///
  /// Parameters:
  /// - [friend]: persisted row.
  /// - [nextOccurrence]: calendar date of the next birthday (date-only semantics).
  /// - [daysUntil]: whole days from the anchor date to [nextOccurrence].
  const UpcomingBirthdayEntry({
    required this.friend,
    required this.nextOccurrence,
    required this.daysUntil,
  });

  /// Friend shown in the list.
  final FriendRow friend;

  /// Next birthday on or after the comparison date.
  final DateTime nextOccurrence;

  /// Non-negative day distance used for sorting and labels.
  final int daysUntil;
}
