import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import 'group_photo_storage.dart';

/// Coordinates [GroupRow] rows and [FriendGroupLinkRow] membership in [AppDatabase].
///
/// UI should use this class instead of querying Drift tables directly so group logic
/// stays in one place (including broadcast streams used by the friends list).
class GroupService {
  /// Creates a service bound to [db].
  ///
  /// Parameters:
  /// - [db]: open application database.
  GroupService(this._db);

  final AppDatabase _db;

  /// Subscriptions that keep [watchFriendIdToGroupColors] in sync with link/group tables.
  StreamSubscription<List<FriendGroupLinkRow>>? _colorLinkSub;
  StreamSubscription<List<GroupRow>>? _colorGroupSub;

  /// Broadcast stream of friend id → list of group accent [Color]s.
  final StreamController<Map<int, List<Color>>> _colorMapCtrl =
      StreamController<Map<int, List<Color>>>.broadcast();

  /// Subscriptions for [watchGroupMemberCounts].
  StreamSubscription<List<FriendGroupLinkRow>>? _countLinkSub;
  StreamSubscription<List<GroupRow>>? _countGroupSub;

  /// Broadcast stream of group id → member count.
  final StreamController<Map<int, int>> _memberCountsCtrl =
      StreamController<Map<int, int>>.broadcast();

  /// Watches friend → group accent colors for UI dots (e.g. ungrouped section).
  ///
  /// On first listen, registers table watches and emits the current map. Subsequent
  /// listeners share the same underlying subscriptions.
  ///
  /// Returns: broadcast stream of maps; empty map when there are no links.
  Stream<Map<int, List<Color>>> watchFriendIdToGroupColors() {
    void emitColors() {
      _friendColorMap().then((m) {
        if (!_colorMapCtrl.isClosed) {
          _colorMapCtrl.add(m);
        }
      });
    }

    _colorLinkSub ??= _db.select(_db.friendGroupLinks).watch().listen((_) => emitColors());
    _colorGroupSub ??= _db.select(_db.groups).watch().listen((_) => emitColors());
    emitColors();
    return _colorMapCtrl.stream;
  }

  /// Watches how many friends belong to each group.
  ///
  /// Returns: broadcast stream of group id → count (includes zeros for empty groups).
  Stream<Map<int, int>> watchGroupMemberCounts() {
    void emitCounts() {
      _loadAllMemberCounts().then((m) {
        if (!_memberCountsCtrl.isClosed) {
          _memberCountsCtrl.add(m);
        }
      });
    }

    _countLinkSub ??= _db.select(_db.friendGroupLinks).watch().listen((_) => emitCounts());
    _countGroupSub ??= _db.select(_db.groups).watch().listen((_) => emitCounts());
    emitCounts();
    return _memberCountsCtrl.stream;
  }

  /// Builds a map of friend id → ordered list of group accent colors from current rows.
  ///
  /// Returns: map keyed by [FriendRow.id]; value order follows link table read order.
  Future<Map<int, List<Color>>> _friendColorMap() async {
    final links = await _db.select(_db.friendGroupLinks).get();
    if (links.isEmpty) {
      return {};
    }
    final groups = await _db.select(_db.groups).get();
    final idToColor = {for (final g in groups) g.id: Color(g.colorArgb)};
    final map = <int, List<Color>>{};
    for (final l in links) {
      final c = idToColor[l.groupId];
      if (c != null) {
        map.putIfAbsent(l.friendId, () => []).add(c);
      }
    }
    return map;
  }

  /// Loads every group and counts its members (used by [watchGroupMemberCounts]).
  ///
  /// Returns: map from group id to non-negative member count.
  Future<Map<int, int>> _loadAllMemberCounts() async {
    final groups = await _db.select(_db.groups).get();
    final map = <int, int>{};
    for (final g in groups) {
      map[g.id] = await memberCountForGroup(g.id);
    }
    return map;
  }

  /// Watches all groups sorted alphabetically by name.
  ///
  /// Returns: stream of [GroupRow] lists; emits on any group change.
  Stream<List<GroupRow>> watchGroupsOrderedByName() {
    return (_db.select(_db.groups)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// One-shot load of all groups sorted by name (for forms before a watch is needed).
  ///
  /// Returns: current rows, ordered ascending by [GroupRow.name].
  Future<List<GroupRow>> getAllGroupsOrdered() {
    return (_db.select(_db.groups)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Loads a single group by primary key.
  ///
  /// Parameters:
  /// - [id]: group id.
  ///
  /// Returns: the row, or `null` if missing.
  Future<GroupRow?> getGroupById(int id) {
    return (_db.select(_db.groups)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new group row.
  ///
  /// Parameters:
  /// - [name]: display name (1–128 chars in schema).
  /// - [colorArgb]: packed ARGB color (typically opaque `0xFF......`).
  /// - [photoPath]: optional absolute path to a cover image already on disk.
  ///
  /// Returns: generated [GroupRow.id].
  Future<int> createGroup({
    required String name,
    required int colorArgb,
    String? photoPath,
  }) {
    return _db.into(_db.groups).insert(
          GroupsCompanion.insert(
            name: name,
            colorArgb: colorArgb,
            photoPath: Value(photoPath),
          ),
        );
  }

  /// Updates name and color for an existing group (photo handled separately).
  ///
  /// Parameters:
  /// - [id]: group to update.
  /// - [name]: new display name.
  /// - [colorArgb]: new packed ARGB color.
  ///
  /// Returns: number of rows written (0 or 1).
  Future<int> updateGroup({
    required int id,
    required String name,
    required int colorArgb,
  }) {
    return (_db.update(_db.groups)..where((t) => t.id.equals(id))).write(
          GroupsCompanion(
            name: Value(name),
            colorArgb: Value(colorArgb),
          ),
        );
  }

  /// Sets or clears the stored cover image path for a group.
  ///
  /// Parameters:
  /// - [id]: group id.
  /// - [photoPath]: Cloudinary HTTPS URL, legacy disk path, or `null` to clear.
  ///
  /// Returns: number of rows updated.
  Future<int> setGroupPhotoPath(int id, String? photoPath) {
    return (_db.update(_db.groups)..where((t) => t.id.equals(id))).write(
          GroupsCompanion(photoPath: Value(photoPath)),
        );
  }

  /// Deletes a group, its membership links (cascade), and any **local** cover file (remote URLs are not deleted on Cloudinary).
  ///
  /// Parameters:
  /// - [id]: group id.
  ///
  /// Returns: number of group rows deleted.
  Future<int> deleteGroup(int id) async {
    final row = await getGroupById(id);
    final n = await (_db.delete(_db.groups)..where((t) => t.id.equals(id))).go();
    if (n > 0 && row?.photoPath != null) {
      await GroupPhotoStorage.deleteIfExists(row!.photoPath);
    }
    return n;
  }

  /// Lists friend ids that belong to [groupId].
  ///
  /// Parameters:
  /// - [groupId]: group primary key.
  ///
  /// Returns: friend ids (unordered).
  Future<List<int>> getMemberIdsForGroup(int groupId) async {
    final rows = await (_db.select(_db.friendGroupLinks)
          ..where((l) => l.groupId.equals(groupId)))
        .get();
    return rows.map((e) => e.friendId).toList();
  }

  /// Replaces the member list for one group: removes old links, inserts one per [friendIds].
  ///
  /// Parameters:
  /// - [groupId]: group to update.
  /// - [friendIds]: friends who should belong to the group after the call.
  ///
  /// Returns: future completing when the transaction finishes.
  Future<void> setMembersForGroup(int groupId, Set<int> friendIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.friendGroupLinks)..where((l) => l.groupId.equals(groupId))).go();
      for (final fid in friendIds) {
        await _db.into(_db.friendGroupLinks).insert(
              FriendGroupLinksCompanion.insert(
                friendId: fid,
                groupId: groupId,
              ),
            );
      }
    });
  }

  /// Replaces every group link for [friendId] with membership in [groupIds] only.
  ///
  /// Parameters:
  /// - [friendId]: friend primary key.
  /// - [groupIds]: set of group ids the friend should belong to (may be empty).
  ///
  /// Returns: future completing when the transaction finishes.
  Future<void> setGroupsForFriend(int friendId, Set<int> groupIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.friendGroupLinks)..where((l) => l.friendId.equals(friendId))).go();
      for (final gid in groupIds) {
        await _db.into(_db.friendGroupLinks).insert(
              FriendGroupLinksCompanion.insert(
                friendId: friendId,
                groupId: gid,
              ),
            );
      }
    });
  }

  /// Reads which groups a friend belongs to.
  ///
  /// Parameters:
  /// - [friendId]: friend primary key.
  ///
  /// Returns: set of group ids (possibly empty).
  Future<Set<int>> getGroupIdsForFriend(int friendId) async {
    final rows = await (_db.select(_db.friendGroupLinks)
          ..where((l) => l.friendId.equals(friendId)))
        .get();
    return rows.map((e) => e.groupId).toSet();
  }

  /// Groups a friend belongs to, in the same order as [getAllGroupsOrdered].
  Future<List<GroupRow>> getGroupsForFriend(int friendId) async {
    final ids = await getGroupIdsForFriend(friendId);
    if (ids.isEmpty) {
      return [];
    }
    final all = await getAllGroupsOrdered();
    return all.where((g) => ids.contains(g.id)).toList();
  }

  /// Watches the entire friend–group link table (for rebuilding grouped UI).
  ///
  /// Returns: stream of all [FriendGroupLinkRow] rows.
  Stream<List<FriendGroupLinkRow>> watchFriendGroupLinks() {
    return _db.select(_db.friendGroupLinks).watch();
  }

  /// Counts members in a group (length of link rows for [groupId]).
  ///
  /// Parameters:
  /// - [groupId]: group primary key.
  ///
  /// Returns: number of distinct friend links (non-negative).
  Future<int> memberCountForGroup(int groupId) async {
    final rows = await (_db.select(_db.friendGroupLinks)
          ..where((l) => l.groupId.equals(groupId)))
        .get();
    return rows.length;
  }
}
