import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/utils/friend_phone.dart';

void main() {
  group('normalizeFriendPhoneInput', () {
    test('returns null for blank input', () {
      expect(normalizeFriendPhoneInput(null), isNull);
      expect(normalizeFriendPhoneInput('   '), isNull);
    });

    test('trims non-empty input', () {
      expect(normalizeFriendPhoneInput('  +15551212  '), '+15551212');
    });
  });

  group('phoneDigitsOnly', () {
    test('strips non-digits', () {
      expect(phoneDigitsOnly('+1 (555) 123-4567'), '15551234567');
    });
  });

  group('formatFriendPhoneDisplay', () {
    test('keeps plain numbers as entered', () {
      expect(formatFriendPhoneDisplay('5551234567'), '5551234567');
    });

    test('groups digits after a leading plus', () {
      expect(formatFriendPhoneDisplay('+15551234567'), '+155 512 345 67');
    });
  });
}
