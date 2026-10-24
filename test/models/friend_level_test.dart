import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/models/friend_level.dart';

void main() {
  group('FriendLevel', () {
    test('defaultReminderDays match product cadence table', () {
      expect(FriendLevel.bestie.defaultReminderDays, 7);
      expect(FriendLevel.close.defaultReminderDays, 14);
      expect(FriendLevel.regular.defaultReminderDays, 30);
      expect(FriendLevel.casual.defaultReminderDays, 60);
    });

    test('fromStorage maps known keys and falls back to regular', () {
      expect(FriendLevel.fromStorage('bestie'), FriendLevel.bestie);
      expect(FriendLevel.fromStorage('CLOSE'), FriendLevel.close);
      expect(FriendLevel.fromStorage(null), FriendLevel.regular);
      expect(FriendLevel.fromStorage('unknown'), FriendLevel.regular);
    });

    test('randomVarianceDays are non-empty bands', () {
      for (final level in FriendLevel.values) {
        final (min, max) = level.randomVarianceDays;
        expect(min, lessThanOrEqualTo(max));
        expect(min, greaterThan(0));
      }
    });
  });
}
