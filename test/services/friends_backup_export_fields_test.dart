import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/services/friend_service.dart';

/// Ensures export-related friend fields (including freeze) round-trip in DB.
void main() {
  late AppDatabase database;
  late FriendService service;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = FriendService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('frozen flag and profile fields survive create/update', () async {
    final id = await service.createFriend(
      name: 'Export Me',
      birthday: DateTime(1992, 4, 4),
      notes: 'note',
      reminderIntervalDays: 14,
      useRandomCheckIn: false,
      closenessLevel: 'close',
      moodTag: 'good_place',
      lastChatSnippet: 'coffee',
      howWeMet: 'work',
      phoneNumber: '+15551234567',
    );
    await service.setFrozen(id, true);

    final row = await service.getFriendById(id);
    expect(row!.isFrozen, isTrue);
    expect(row.notes, 'note');
    expect(row.closenessLevel, 'close');
    expect(row.moodTag, 'good_place');
    expect(row.lastChatSnippet, 'coffee');
    expect(row.howWeMet, 'work');
    expect(row.phoneNumber, '+15551234567');
  });
}
