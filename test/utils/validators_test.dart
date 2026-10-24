import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/utils/validators.dart';

void main() {
  group('validateFriendName', () {
    test('rejects empty and oversized names', () {
      expect(validateFriendName(null), isNotNull);
      expect(validateFriendName('  '), isNotNull);
      expect(validateFriendName('a' * 129), isNotNull);
    });

    test('accepts trimmed non-empty names', () {
      expect(validateFriendName('  Sam  '), isNull);
    });
  });

  group('validateReminderIntervalDays', () {
    test('rejects non-numbers and out of range', () {
      expect(validateReminderIntervalDays(null), isNotNull);
      expect(validateReminderIntervalDays('abc'), isNotNull);
      expect(validateReminderIntervalDays('0'), isNotNull);
      expect(validateReminderIntervalDays('366'), isNotNull);
    });

    test('accepts 1–365', () {
      expect(validateReminderIntervalDays('1'), isNull);
      expect(validateReminderIntervalDays('365'), isNull);
    });
  });

  group('validateOptionalPhone', () {
    test('allows empty', () {
      expect(validateOptionalPhone(null), isNull);
      expect(validateOptionalPhone(''), isNull);
    });

    test('requires 7–15 digits', () {
      expect(validateOptionalPhone('123456'), isNotNull);
      expect(validateOptionalPhone('+1 (555) 123-4567'), isNull);
      expect(validateOptionalPhone('1' * 16), isNotNull);
    });
  });

  group('validateOptionalShortLine', () {
    test('allows empty and enforces max length', () {
      expect(validateOptionalShortLine(null), isNull);
      expect(validateOptionalShortLine('ok'), isNull);
      expect(validateOptionalShortLine('x' * 201), isNotNull);
      expect(validateOptionalShortLine('x' * 10, maxLength: 5), isNotNull);
    });
  });
}
