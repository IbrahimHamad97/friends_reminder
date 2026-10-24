import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/services/friend_service.dart';
import 'package:friends_reminder/services/group_section_prefs.dart';
import 'package:friends_reminder/services/group_service.dart';

void main() {
  late AppDatabase database;
  late FriendService friends;
  late GroupService groups;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    friends = FriendService(database);
    groups = GroupService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('createGroup and setGroupsForFriend wire membership', () async {
    final friendId = await friends.createFriend(
      name: 'Sam',
      birthday: DateTime(1991, 2, 2),
      useRandomCheckIn: false,
    );
    final groupId = await groups.createGroup(
      name: 'College',
      colorArgb: 0xFF00897B,
    );

    await groups.setGroupsForFriend(friendId, {groupId});
    final memberIds = await groups.getMemberIdsForGroup(groupId);
    expect(memberIds, [friendId]);

    final friendGroups = await groups.getGroupIdsForFriend(friendId);
    expect(friendGroups, {groupId});
  });

  test('deleteGroup removes links and forgets section prefs', () async {
    final friendId = await friends.createFriend(
      name: 'Sam',
      birthday: DateTime(1991, 2, 2),
      useRandomCheckIn: false,
    );
    final groupId = await groups.createGroup(
      name: 'Work',
      colorArgb: 0xFF3366FF,
    );
    await groups.setGroupsForFriend(friendId, {groupId});
    await GroupSectionPrefs.instance.setExpanded(groupId, false);

    final deleted = await groups.deleteGroup(groupId);
    expect(deleted, 1);
    expect(await groups.getGroupById(groupId), isNull);
    expect(await groups.getMemberIdsForGroup(groupId), isEmpty);
    // Default after forget is expanded again.
    expect(await GroupSectionPrefs.instance.isExpanded(groupId), isTrue);

    // Friend row remains.
    expect(await friends.getFriendById(friendId), isNotNull);
  });

  test('purgeOrphanGroupLinks clears stale membership rows', () async {
    final friendId = await friends.createFriend(
      name: 'Sam',
      birthday: DateTime(1991, 2, 2),
      useRandomCheckIn: false,
    );
    final groupId = await groups.createGroup(
      name: 'Temp',
      colorArgb: 0xFF112233,
    );
    await groups.setGroupsForFriend(friendId, {groupId});

    // Delete group row without going through deleteGroup helper path that
    // already clears links — simulate orphan by raw delete then purge.
    await (database.delete(database.groups)
          ..where((t) => t.id.equals(groupId)))
        .go();
    final purged = await groups.purgeOrphanGroupLinks();
    expect(purged, greaterThanOrEqualTo(1));
    expect(await groups.getMemberIdsForGroup(groupId), isEmpty);
  });
}
