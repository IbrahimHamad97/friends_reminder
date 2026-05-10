import '../data/database.dart';
import '../models/upcoming_birthday.dart';
import 'date_utils.dart';

/// Lists friends whose next birthday falls within [withinDays] of [from], soonest first.
///
/// Parameters:
/// - [friends]: full friend list from the database.
/// - [from]: anchor “today” for comparisons (time-of-day ignored via [dateOnly]).
/// - [withinDays]: inclusive horizon (e.g. 30).
///
/// Returns: sorted [UpcomingBirthdayEntry] items with `daysUntil` in `[0, withinDays]`.
List<UpcomingBirthdayEntry> upcomingBirthdaysWithinHorizon(
  List<FriendRow> friends, {
  DateTime? from,
  int withinDays = 30,
}) {
  final anchor = dateOnly(from ?? DateTime.now());
  final result = <UpcomingBirthdayEntry>[];
  for (final friend in friends) {
    final next = nextBirthdayOccurrence(friend.birthday, anchor);
    final daysUntil = next.difference(anchor).inDays;
    if (daysUntil >= 0 && daysUntil <= withinDays) {
      result.add(
        UpcomingBirthdayEntry(
          friend: friend,
          nextOccurrence: next,
          daysUntil: daysUntil,
        ),
      );
    }
  }
  result.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
  return result;
}
