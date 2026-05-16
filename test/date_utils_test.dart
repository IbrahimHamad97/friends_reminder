import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/utils/date_utils.dart';

void main() {
  group('isReachOutRhythmDay', () {
    test('anchors from createdAt when lastContacted is null', () {
      final created = DateTime(2024, 1, 1);
      final friend = FriendRow(
        id: 1,
        name: 'Alex',
        birthday: DateTime(1990, 5, 5),
        reminderIntervalDays: 7,
        closenessLevel: 'regular',
        createdAt: created,
      );
      expect(isReachOutRhythmDay(DateTime(2024, 1, 1), friend), isTrue);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 8), friend), isTrue);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 2), friend), isFalse);
    });

    test('after lastContacted, first rhythm day is one interval later', () {
      final contacted = DateTime(2024, 1, 10, 15, 30);
      final friend = FriendRow(
        id: 2,
        name: 'Sam',
        birthday: DateTime(1992, 3, 3),
        reminderIntervalDays: 7,
        closenessLevel: 'regular',
        createdAt: DateTime(2024, 1, 1),
        lastContactedAt: contacted,
      );
      expect(isReachOutRhythmDay(DateTime(2024, 1, 10), friend), isFalse);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 17), friend), isTrue);
      expect(isReachOutRhythmDay(DateTime(2024, 1, 24), friend), isTrue);
    });
  });

  group('lastContactedSummary', () {
    test('recognizes today in local time', () {
      final now = DateTime.now();
      expect(lastContactedSummary(now), 'Logged today');
    });
  });
}
