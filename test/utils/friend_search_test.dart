import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/utils/friend_search.dart';

import '../helpers/friend_row_factory.dart';

void main() {
  group('friendMatchesSearchQuery', () {
    test('empty query matches everyone', () {
      final friend = testFriend(name: 'Sam');
      expect(friendMatchesSearchQuery(friend, ''), isTrue);
      expect(friendMatchesSearchQuery(friend, '   '), isTrue);
    });

    test('matches name case-insensitively', () {
      final friend = testFriend(name: 'Jordan Lee');
      expect(friendMatchesSearchQuery(friend, 'jordan'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'LEE'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'xyz'), isFalse);
    });

    test('matches notes, mood, closeness, chat, how we met, and phone', () {
      final friend = testFriend(
        name: 'Pat',
        notes: 'college roommate',
        closenessLevel: 'bestie',
        moodTag: 'busy',
        lastChatSnippet: 'trip planning',
        howWeMet: 'hackathon',
        phoneNumber: '+15550001111',
      );
      expect(friendMatchesSearchQuery(friend, 'roommate'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'bestie'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'busy'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'trip'), isTrue);
      expect(friendMatchesSearchQuery(friend, 'hackathon'), isTrue);
      expect(friendMatchesSearchQuery(friend, '555000'), isTrue);
    });
  });
}
