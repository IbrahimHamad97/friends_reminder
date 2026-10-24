import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/services/friend_service.dart';

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

  Future<int> addFriend({
    String name = 'Alex',
    int reminderIntervalDays = 30,
    bool useRandomCheckIn = false,
    String closenessLevel = 'regular',
  }) {
    return service.createFriend(
      name: name,
      birthday: DateTime(1990, 5, 5),
      reminderIntervalDays: reminderIntervalDays,
      useRandomCheckIn: useRandomCheckIn,
      closenessLevel: closenessLevel,
    );
  }

  group('createFriend', () {
    test('persists row and rolls active interval when random is on', () async {
      final id = await addFriend(
        useRandomCheckIn: true,
        closenessLevel: 'bestie',
        reminderIntervalDays: 7,
      );
      final row = await service.getFriendById(id);
      expect(row, isNotNull);
      expect(row!.name, 'Alex');
      expect(row.isFrozen, isFalse);
      expect(row.activeCheckInIntervalDays, inInclusiveRange(5, 9));
    });

    test('keeps fixed active interval when random is off', () async {
      final id = await addFriend(
        useRandomCheckIn: false,
        reminderIntervalDays: 14,
      );
      final row = await service.getFriendById(id);
      expect(row!.activeCheckInIntervalDays, 14);
    });
  });

  group('updateFriend reroll', () {
    test('preserves active interval when rerollActiveInterval is false',
        () async {
      final id = await addFriend(
        useRandomCheckIn: true,
        closenessLevel: 'bestie',
        reminderIntervalDays: 7,
      );
      final before = await service.getFriendById(id);
      final previousActive = before!.activeCheckInIntervalDays;

      await service.updateFriend(
        id: id,
        name: 'Alex Updated',
        birthday: before.birthday,
        reminderIntervalDays: before.reminderIntervalDays,
        useRandomCheckIn: before.useRandomCheckIn,
        closenessLevel: before.closenessLevel,
        rerollActiveInterval: false,
      );

      final after = await service.getFriendById(id);
      expect(after!.name, 'Alex Updated');
      expect(after.activeCheckInIntervalDays, previousActive);
    });

    test('rerolls active interval when rerollActiveInterval is true', () async {
      final id = await addFriend(
        useRandomCheckIn: true,
        closenessLevel: 'bestie',
        reminderIntervalDays: 7,
      );
      final before = await service.getFriendById(id);

      await service.updateFriend(
        id: id,
        name: before!.name,
        birthday: before.birthday,
        reminderIntervalDays: 7,
        useRandomCheckIn: true,
        closenessLevel: 'bestie',
        rerollActiveInterval: true,
      );

      final after = await service.getFriendById(id);
      expect(after!.activeCheckInIntervalDays, inInclusiveRange(5, 9));
    });
  });

  group('freeze', () {
    test('setFrozen toggles flag and getActiveFriends excludes frozen',
        () async {
      final activeId = await addFriend(name: 'Active');
      final frozenId = await addFriend(name: 'Frozen');

      await service.setFrozen(frozenId, true);

      final frozen = await service.getFriendById(frozenId);
      expect(frozen!.isFrozen, isTrue);

      final active = await service.getActiveFriends();
      expect(active.map((f) => f.id), [activeId]);
      expect(active.every((f) => !f.isFrozen), isTrue);

      await service.setFrozen(frozenId, false);
      final unfrozen = await service.getActiveFriends();
      expect(unfrozen.map((f) => f.id), containsAll([activeId, frozenId]));
    });
  });

  group('logCheckIn', () {
    test('sets lastContactedAt and rolls a new active interval', () async {
      final id = await addFriend(
        useRandomCheckIn: true,
        closenessLevel: 'regular',
        reminderIntervalDays: 30,
      );
      await service.logCheckIn(id);
      final row = await service.getFriendById(id);
      expect(row!.lastContactedAt, isNotNull);
      expect(row.activeCheckInIntervalDays, inInclusiveRange(23, 37));
    });
  });

  group('sortFriendsByUpcomingBirthday', () {
    test('orders by next birthday from the given anchor', () async {
      final a = await addFriend(name: 'Late');
      final b = await addFriend(name: 'Soon');
      await service.updateFriend(
        id: a,
        name: 'Late',
        birthday: DateTime(1990, 12, 1),
        reminderIntervalDays: 30,
        useRandomCheckIn: false,
        closenessLevel: 'regular',
        rerollActiveInterval: false,
      );
      await service.updateFriend(
        id: b,
        name: 'Soon',
        birthday: DateTime(1990, 3, 15),
        reminderIntervalDays: 30,
        useRandomCheckIn: false,
        closenessLevel: 'regular',
        rerollActiveInterval: false,
      );

      final rows = await service.getAllFriends();
      service.sortFriendsByUpcomingBirthday(rows, DateTime(2024, 3, 1));
      expect(rows.first.name, 'Soon');
      expect(rows.last.name, 'Late');
    });
  });
}
