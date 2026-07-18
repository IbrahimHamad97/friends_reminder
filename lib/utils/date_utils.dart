import 'package:flutter/material.dart';

import '../data/database.dart';
import 'check_in_interval.dart';

// Birthday and calendar helpers used by list, calendar, and detail views.

/// Strips the time component and normalizes to local midnight.
///
/// Parameters:
/// - [date]: input instant.
///
/// Returns: date-only value suitable for calendar comparisons.
DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// The next calendar date that matches [birthday]'s month and day, on or after [from].
///
/// Parameters:
/// - [birthday]: stored birthday; its year is ignored for recurrence.
/// - [from]: anchor date (typically today).
///
/// Returns: the upcoming birthday occurrence as a date-only [DateTime].
DateTime nextBirthdayOccurrence(DateTime birthday, DateTime from) {
  final base = dateOnly(from);
  var candidate = DateTime(base.year, birthday.month, birthday.day);
  if (candidate.isBefore(base)) {
    candidate = DateTime(base.year + 1, birthday.month, birthday.day);
  }
  return candidate;
}

/// Formats a friendly countdown label like "in 3 days" or "today".
///
/// Parameters:
/// - [context]: used for localized relative date strings when available.
/// - [birthday]: stored birthday.
/// - [from]: reference date (typically today).
///
/// Returns: short human-readable string for UI subtitles.
String birthdayCountdownLabel(BuildContext context, DateTime birthday, DateTime from) {
  final next = nextBirthdayOccurrence(birthday, from);
  final days = next.difference(dateOnly(from)).inDays;
  if (days == 0) {
    return 'Birthday today';
  }
  if (days == 1) {
    return 'Tomorrow';
  }
  return 'In $days days';
}

/// Month and day label, e.g. "May 10".
///
/// Parameters:
/// - [birthday]: date containing the desired month and day.
///
/// Returns: formatted MD string.
String formatMonthDay(DateTime birthday) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[birthday.month - 1]} ${birthday.day}';
}

/// Whether [day] matches the month and day of [birthday].
///
/// Parameters:
/// - [day]: calendar day under inspection.
/// - [birthday]: stored birthday.
///
/// Returns: `true` when month/day equal.
bool isSameMonthDay(DateTime day, DateTime birthday) {
  return day.month == birthday.month && day.day == birthday.day;
}

/// First calendar day of this friend's check-in rhythm (always one interval after
/// [FriendRow.createdAt] or [FriendRow.lastContactedAt] when set).
///
/// Adding a friend today does **not** make today a check-in day; the first one is
/// `interval` days later.
DateTime firstCheckInRhythmDay(FriendRow friend) {
  return nextCheckInDueDate(friend);
}

/// Whether [referenceDate] is on or after this friend's next check-in due date.
bool isReachOutRhythmDay(DateTime referenceDate, FriendRow friend) {
  if (friend.reminderIntervalDays <= 0) {
    return false;
  }
  final ref = dateOnly(referenceDate);
  final due = nextCheckInDueDate(friend);
  return !ref.isBefore(due);
}

/// Short label for when check-in was last logged (for edit screen).
String lastContactedSummary(DateTime contactInstant) {
  final d = dateOnly(contactInstant.toLocal());
  final today = dateOnly(DateTime.now());
  if (d == today) {
    return 'Logged today';
  }
  final yesterday = today.subtract(const Duration(days: 1));
  if (d == yesterday) {
    return 'Logged yesterday';
  }
  return 'Logged ${formatMonthDay(d)}, ${d.year}';
}
