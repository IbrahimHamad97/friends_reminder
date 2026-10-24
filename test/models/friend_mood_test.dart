import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/models/friend_mood.dart';

void main() {
  group('FriendMood', () {
    test('fromStorage maps known keys', () {
      expect(FriendMood.fromStorage('good_place'), FriendMood.goodPlace);
      expect(FriendMood.fromStorage('BUSY'), FriendMood.busy);
      expect(FriendMood.fromStorage('tough_time'), FriendMood.toughTime);
      expect(FriendMood.fromStorage('celebrating'), FriendMood.celebrating);
    });

    test('fromStorage returns null for empty or unknown', () {
      expect(FriendMood.fromStorage(null), isNull);
      expect(FriendMood.fromStorage(''), isNull);
      expect(FriendMood.fromStorage('  '), isNull);
      expect(FriendMood.fromStorage('nope'), isNull);
    });
  });
}
