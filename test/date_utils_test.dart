import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/models/friend_level.dart';
import 'package:friends_reminder/utils/check_in_interval.dart';
import 'package:friends_reminder/utils/date_utils.dart';
import 'package:friends_reminder/utils/home_dashboard_logic.dart';

import 'helpers/friend_row_factory.dart';

void main() {
  group('rollCheckInIntervalDays', () {
    test('returns base when random is off', () {
      expect(
        rollCheckInIntervalDays(
          baseDays: 30,
          level: FriendLevel.regular,
          randomEnabled: false,
        ),
        30,
      );
    });

    test('varies within bestie band when random is on', () {
      final values = <int>{};
      for (var i = 0; i < 40; i++) {
        values.add(
          rollCheckInIntervalDays(
            baseDays: 7,
            level: FriendLevel.bestie,
            randomEnabled: true,
            random: Random(i),
          ),
        );
      }
      expect(values.length, greaterThan(1));
      expect(values.every((v) => v >= 5 && v <= 9), isTrue);
    });
  });

  group('nextCheckInDueDate', () {
    test('anchors on createdAt when never contacted', () {
      final friend = testFriend(
        createdAt: DateTime(2024, 1, 1),
        activeCheckInIntervalDays: 7,
      );
      expect(nextCheckInDueDate(friend), DateTime(2024, 1, 8));
    });

    test('anchors on lastContactedAt when set', () {
      final friend = testFriend(
        createdAt: DateTime(2024, 1, 1),
        lastContactedAt: DateTime(2024, 1, 10),
        activeCheckInIntervalDays: 7,
      );
      expect(nextCheckInDueDate(friend), DateTime(2024, 1, 17));
    });
  });

  group('isReachOutRhythmDay', () {
    test('first check-in is one interval after creation', () {
      final friend = testFriend(createdAt: DateTime(2024, 1, 1));
      expect(isReachOutRhythmDay(DateTime(2024, 1, 1), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 7), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 8), friend), isTrue);
    });

    test('after lastContacted, due date is one interval later', () {
      final friend = testFriend(
        createdAt: DateTime(2024, 1, 1),
        lastContactedAt: DateTime(2024, 1, 10),
        activeCheckInIntervalDays: 7,
      );
      expect(isReachOutRhythmDay(DateTime(2024, 1, 16), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 17), friend), isTrue);
    });

    test('returns false when interval is invalid', () {
      final friend = testFriend(reminderIntervalDays: 0);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 1), friend), isFalse);
    });
  });

  group('nextCheckInNotificationDay', () {
    test('keeps due day when reminder clock is still ahead', () {
      final day = nextCheckInNotificationDay(
        dueDay: DateTime(2024, 3, 10),
        now: DateTime(2024, 3, 10, 8, 0),
        hour: 9,
        minute: 0,
      );
      expect(day, DateTime(2024, 3, 10));
    });

    test('fires later today when due clock already passed but today clock is ahead',
        () {
      final day = nextCheckInNotificationDay(
        dueDay: DateTime(2024, 3, 8),
        now: DateTime(2024, 3, 10, 8, 0),
        hour: 9,
        minute: 0,
      );
      expect(day, DateTime(2024, 3, 10));
    });

    test('fires tomorrow when overdue and today reminder clock already passed',
        () {
      final day = nextCheckInNotificationDay(
        dueDay: DateTime(2024, 3, 8),
        now: DateTime(2024, 3, 10, 10, 0),
        hour: 9,
        minute: 0,
      );
      expect(day, DateTime(2024, 3, 11));
    });
  });

  group('nextBirthdayOccurrence', () {
    test('returns later this year when birthday is ahead', () {
      expect(
        nextBirthdayOccurrence(DateTime(1990, 6, 15), DateTime(2024, 3, 1)),
        DateTime(2024, 6, 15),
      );
    });

    test('rolls to next year when birthday already passed', () {
      expect(
        nextBirthdayOccurrence(DateTime(1990, 2, 1), DateTime(2024, 3, 1)),
        DateTime(2025, 2, 1),
      );
    });

    test('returns today when birthday is today', () {
      expect(
        nextBirthdayOccurrence(DateTime(1990, 3, 1), DateTime(2024, 3, 1)),
        DateTime(2024, 3, 1),
      );
    });
  });

  group('formatMonthDay / isSameMonthDay', () {
    test('formats month abbreviation and day', () {
      expect(formatMonthDay(DateTime(2024, 5, 10)), 'May 10');
    });

    test('compares month and day only', () {
      expect(
        isSameMonthDay(DateTime(2024, 5, 10), DateTime(1990, 5, 10)),
        isTrue,
      );
      expect(
        isSameMonthDay(DateTime(2024, 5, 11), DateTime(1990, 5, 10)),
        isFalse,
      );
    });
  });

  group('nextCheckInRhythmDayOnOrAfter', () {
    test('new friend first check-in is one interval after creation', () {
      final friend = testFriend(createdAt: DateTime(2024, 1, 1));
      final today = DateTime(2024, 1, 1);
      final next = nextCheckInRhythmDayOnOrAfter(today, friend);
      expect(next, DateTime(2024, 1, 8));
      expect(checkInReminderLabel(today, next!), 'Check-in in 7 days');
    });

    test('returns today when due date is overdue', () {
      final friend = testFriend(
        createdAt: DateTime(2024, 1, 1),
        activeCheckInIntervalDays: 7,
      );
      final today = DateTime(2024, 1, 20);
      expect(nextCheckInRhythmDayOnOrAfter(today, friend), today);
      expect(checkInReminderLabel(today, today), 'Check-in today');
    });
  });

  group('lastContactedSummary', () {
    test('recognizes today in local time', () {
      final now = DateTime.now();
      expect(lastContactedSummary(now), 'Logged today');
    });

    test('recognizes yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(lastContactedSummary(yesterday), 'Logged yesterday');
    });
  });

  group('checkInCadenceLabel', () {
    test('describes fixed weekly cadence', () {
      final friend = testFriend(
        reminderIntervalDays: 7,
        useRandomCheckIn: false,
      );
      expect(checkInCadenceLabel(friend), 'Weekly check-in reminder');
    });

    test('includes current cycle days when random is on', () {
      final friend = testFriend(
        reminderIntervalDays: 7,
        useRandomCheckIn: true,
        activeCheckInIntervalDays: 8,
      );
      expect(
        checkInCadenceLabel(friend),
        'Check-in about weekly (~8 days this cycle)',
      );
    });
  });
}
