import '../data/database.dart';
import 'check_in_interval.dart';
import 'date_utils.dart';

/// Next calendar day on or after [from] when this friend's check-in rhythm fires
/// (same rules as [isReachOutRhythmDay] / [firstCheckInRhythmDay]).
///
/// Parameters:
/// - [from]: anchor date (typically local "today").
/// - [friend]: persisted friend row.
///
/// Returns: date-only next rhythm day, or `null` if [reminderIntervalDays] is invalid.
DateTime? nextCheckInRhythmDayOnOrAfter(DateTime from, FriendRow friend) {
  if (friend.reminderIntervalDays <= 0) {
    return null;
  }
  final ref = dateOnly(from);
  final due = nextCheckInDueDate(friend);
  if (!ref.isAfter(due)) {
    return due;
  }
  return ref;
}

/// Days from [from] until [target] (both date-only); non-negative when [target] is on/after [from].
int daysBetween(DateTime from, DateTime target) {
  return dateOnly(target).difference(dateOnly(from)).inDays;
}

/// Friend plus their next birthday on or after [from], only if that day falls in the same calendar year as [from].
///
/// Used for the home "birthdays this year" list.
List<({FriendRow friend, DateTime nextBirthday})> upcomingBirthdaysThroughYearEnd(
  List<FriendRow> friends,
  DateTime from,
) {
  final yearEnd = DateTime(from.year, 12, 31);
  final out = <({FriendRow friend, DateTime nextBirthday})>[];
  for (final f in friends) {
    final next = nextBirthdayOccurrence(f.birthday, from);
    if (!next.isAfter(yearEnd)) {
      out.add((friend: f, nextBirthday: next));
    }
  }
  out.sort((a, b) => a.nextBirthday.compareTo(b.nextBirthday));
  return out;
}

/// Friends with the soonest next check-in rhythm days, limited to [limit].
///
/// Parameters:
/// - [friends]: all friends to score.
/// - [from]: anchor date (today).
/// - [limit]: max entries (e.g. 10).
///
/// Returns: list of `(friend, nextCheckInDay)` sorted by day ascending.
List<({FriendRow friend, DateTime nextCheckIn})> nextCheckInReminders(
  List<FriendRow> friends,
  DateTime from, {
  int limit = 10,
}) {
  final pairs = <({FriendRow friend, DateTime nextCheckIn})>[];
  for (final f in friends) {
    final next = nextCheckInRhythmDayOnOrAfter(from, f);
    if (next != null) {
      pairs.add((friend: f, nextCheckIn: next));
    }
  }
  pairs.sort((a, b) {
    final c = a.nextCheckIn.compareTo(b.nextCheckIn);
    if (c != 0) {
      return c;
    }
    return a.friend.name.compareTo(b.friend.name);
  });
  if (pairs.length <= limit) {
    return pairs;
  }
  return pairs.sublist(0, limit);
}

/// Short label for the horizontal check-in cards ("Today", "Tomorrow", "In 5 days").
String checkInReminderLabel(DateTime from, DateTime nextCheckIn) {
  final d = daysBetween(from, nextCheckIn);
  if (d == 0) {
    return 'Check-in today';
  }
  if (d == 1) {
    return 'Check-in tomorrow';
  }
  return 'Check-in in $d days';
}
