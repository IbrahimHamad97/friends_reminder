import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/models/friend_level.dart';
import 'package:friends_reminder/utils/check_in_interval.dart';
import 'package:friends_reminder/utils/date_utils.dart';
import 'package:friends_reminder/utils/home_dashboard_logic.dart';

FriendRow _friend({
  required DateTime createdAt,
  DateTime? lastContactedAt,
  int reminderIntervalDays = 7,
  int activeCheckInIntervalDays = 7,
  bool useRandomCheckIn = false,
}) {
  return FriendRow(
    id: 1,
    name: 'Alex',
    birthday: DateTime(1990, 5, 5),
    reminderIntervalDays: reminderIntervalDays,
    useRandomCheckIn: useRandomCheckIn,
    activeCheckInIntervalDays: activeCheckInIntervalDays,
    closenessLevel: 'regular',
    createdAt: createdAt,
    lastContactedAt: lastContactedAt,
  );
}

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

  group('isReachOutRhythmDay', () {
    test('first check-in is one interval after creation', () {
      final friend = _friend(createdAt: DateTime(2024, 1, 1));
      expect(isReachOutRhythmDay(DateTime(2024, 1, 1), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 7), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 8), friend), isTrue);
    });

    test('after lastContacted, due date is one interval later', () {
      final friend = _friend(
        createdAt: DateTime(2024, 1, 1),
        lastContactedAt: DateTime(2024, 1, 10),
        activeCheckInIntervalDays: 7,
      );
      expect(isReachOutRhythmDay(DateTime(2024, 1, 16), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 17), friend), isTrue);
    });
  });

  group('nextCheckInRhythmDayOnOrAfter', () {
    test('new friend first check-in is one interval after creation', () {
      final friend = _friend(createdAt: DateTime(2024, 1, 1));
      final today = DateTime(2024, 1, 1);
      final next = nextCheckInRhythmDayOnOrAfter(today, friend);
      expect(next, DateTime(2024, 1, 8));
      expect(checkInReminderLabel(today, next!), 'Check-in in 7 days');
    });
  });

  group('lastContactedSummary', () {
    test('recognizes today in local time', () {
      final now = DateTime.now();
      expect(lastContactedSummary(now), 'Logged today');
    });
  });
}
