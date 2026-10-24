import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/utils/home_dashboard_logic.dart';
import 'package:friends_reminder/utils/upcoming_birthdays.dart';

import '../helpers/friend_row_factory.dart';

void main() {
  group('upcomingBirthdaysThroughYearEnd', () {
    test('includes remaining birthdays this year and sorts soonest first', () {
      final from = DateTime(2024, 10, 1);
      final friends = [
        testFriend(id: 1, name: 'Zed', birthday: DateTime(1990, 12, 1)),
        testFriend(id: 2, name: 'Ann', birthday: DateTime(1990, 11, 5)),
        testFriend(id: 3, name: 'Bob', birthday: DateTime(1990, 2, 1)),
      ];
      final result = upcomingBirthdaysThroughYearEnd(friends, from);
      expect(result.map((e) => e.friend.name), ['Ann', 'Zed']);
      expect(result.first.nextBirthday, DateTime(2024, 11, 5));
    });
  });

  group('nextCheckInReminders', () {
    test('sorts by next check-in and respects limit', () {
      final from = DateTime(2024, 1, 1);
      final friends = [
        testFriend(
          id: 1,
          name: 'Slow',
          createdAt: DateTime(2024, 1, 1),
          reminderIntervalDays: 30,
          activeCheckInIntervalDays: 30,
        ),
        testFriend(
          id: 2,
          name: 'Soon',
          createdAt: DateTime(2024, 1, 1),
          reminderIntervalDays: 7,
          activeCheckInIntervalDays: 7,
        ),
        testFriend(
          id: 3,
          name: 'AlsoSoon',
          createdAt: DateTime(2024, 1, 1),
          reminderIntervalDays: 7,
          activeCheckInIntervalDays: 7,
        ),
      ];
      final result = nextCheckInReminders(friends, from, limit: 2);
      expect(result.length, 2);
      expect(result.map((e) => e.friend.name), ['AlsoSoon', 'Soon']);
      expect(result.first.nextCheckIn, DateTime(2024, 1, 8));
    });
  });

  group('upcomingBirthdaysWithinHorizon', () {
    test('keeps only birthdays inside the horizon', () {
      final from = DateTime(2024, 5, 1);
      final friends = [
        testFriend(id: 1, name: 'Near', birthday: DateTime(1990, 5, 10)),
        testFriend(id: 2, name: 'Far', birthday: DateTime(1990, 8, 1)),
      ];
      final result = upcomingBirthdaysWithinHorizon(
        friends,
        from: from,
        withinDays: 30,
      );
      expect(result.map((e) => e.friend.name), ['Near']);
      expect(result.single.daysUntil, 9);
    });
  });

  group('checkInReminderLabel', () {
    test('covers today tomorrow and later', () {
      final from = DateTime(2024, 1, 1);
      expect(checkInReminderLabel(from, from), 'Check-in today');
      expect(
        checkInReminderLabel(from, DateTime(2024, 1, 2)),
        'Check-in tomorrow',
      );
      expect(
        checkInReminderLabel(from, DateTime(2024, 1, 6)),
        'Check-in in 5 days',
      );
    });
  });
}
