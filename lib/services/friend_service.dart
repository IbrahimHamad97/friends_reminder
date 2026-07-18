import 'package:drift/drift.dart';

import '../data/database.dart';
import '../models/friend_level.dart';
import '../utils/check_in_interval.dart';
import 'friend_photo_storage.dart';

/// Coordinates friend persistence using [AppDatabase].
///
/// All database reads and writes for friends go through this service so UI and
/// routing stay decoupled from Drift details.
class FriendService {
  /// Creates a service bound to [database].
  ///
  /// Parameters:
  /// - [database]: open Drift database instance used for all operations.
  FriendService(this._database);

  final AppDatabase _database;

  /// Watches all friends ordered by upcoming birthday (approximate sort by month/day).
  ///
  /// Returns: a broadcast stream of friend rows; emits again when data changes.
  Stream<List<FriendRow>> watchFriendsOrderedByUpcomingBirthday() {
    return _database.select(_database.friends).watch().map((rows) {
      final now = DateTime.now();
      final sorted = List<FriendRow>.from(rows)
        ..sort((a, b) {
          final na = _nextBirthdaySortKey(a.birthday, now);
          final nb = _nextBirthdaySortKey(b.birthday, now);
          return na.compareTo(nb);
        });
      return sorted;
    });
  }

  /// Computes a sort key: days from [from] until the next calendar birthday.
  ///
  /// Parameters:
  /// - [birthday]: stored birthday (year may be ignored for display elsewhere).
  /// - [from]: reference date, usually "today".
  ///
  /// Returns: number of days until the next occurrence of month/day on/after [from].
  int _nextBirthdaySortKey(DateTime birthday, DateTime from) {
    var next = DateTime(from.year, birthday.month, birthday.day);
    if (next.isBefore(DateTime(from.year, from.month, from.day))) {
      next = DateTime(from.year + 1, birthday.month, birthday.day);
    }
    return next.difference(DateTime(from.year, from.month, from.day)).inDays;
  }

  /// Sorts [rows] in place by next upcoming birthday (same comparator as the main friends list).
  ///
  /// Parameters:
  /// - [rows]: mutable list of friends to reorder.
  /// - [from]: anchor date (usually today) for “next birthday” distance.
  ///
  /// Returns: nothing; [rows] is sorted in place.
  void sortFriendsByUpcomingBirthday(List<FriendRow> rows, DateTime from) {
    rows.sort((a, b) {
      final na = _nextBirthdaySortKey(a.birthday, from);
      final nb = _nextBirthdaySortKey(b.birthday, from);
      return na.compareTo(nb);
    });
  }

  /// Loads a single friend by primary key.
  ///
  /// Parameters:
  /// - [id]: friend identifier.
  ///
  /// Returns: the row if found, otherwise `null`.
  Future<FriendRow?> getFriendById(int id) {
    return (_database.select(_database.friends)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new friend and returns the new row id.
  ///
  /// Returns: generated [FriendRow.id].
  Future<int> createFriend({
    required String name,
    required DateTime birthday,
    String? notes,
    int reminderIntervalDays = 30,
    bool useRandomCheckIn = true,
    String closenessLevel = 'regular',
    String? moodTag,
    String? lastChatSnippet,
    String? howWeMet,
    String? phoneNumber,
  }) {
    final level = FriendLevel.fromStorage(closenessLevel);
    final active = resolveActiveCheckInIntervalDays(
      reminderIntervalDays: reminderIntervalDays,
      level: level,
      useRandomCheckIn: useRandomCheckIn,
    );
    return _database.into(_database.friends).insert(
          FriendsCompanion.insert(
            name: name,
            birthday: birthday,
            notes: Value(notes),
            reminderIntervalDays: Value(reminderIntervalDays),
            useRandomCheckIn: Value(useRandomCheckIn),
            activeCheckInIntervalDays: Value(active),
            closenessLevel: Value(closenessLevel),
            moodTag: Value(moodTag),
            lastChatSnippet: Value(lastChatSnippet),
            howWeMet: Value(howWeMet),
            phoneNumber: Value(phoneNumber),
          ),
        );
  }

  /// Updates fields for an existing friend (photo path is managed separately by the UI layer).
  ///
  /// Returns: number of rows updated (0 if id missing, 1 on success).
  Future<int> updateFriend({
    required int id,
    required String name,
    required DateTime birthday,
    String? notes,
    required int reminderIntervalDays,
    required bool useRandomCheckIn,
    required String closenessLevel,
    String? moodTag,
    String? lastChatSnippet,
    String? howWeMet,
    String? phoneNumber,
    bool rerollActiveInterval = true,
  }) async {
    final level = FriendLevel.fromStorage(closenessLevel);
    final active = rerollActiveInterval
        ? resolveActiveCheckInIntervalDays(
            reminderIntervalDays: reminderIntervalDays,
            level: level,
            useRandomCheckIn: useRandomCheckIn,
          )
        : (useRandomCheckIn
            ? (await getFriendById(id))?.activeCheckInIntervalDays ?? reminderIntervalDays
            : reminderIntervalDays);

    return (_database.update(_database.friends)..where((t) => t.id.equals(id))).write(
          FriendsCompanion(
            name: Value(name),
            birthday: Value(birthday),
            notes: Value(notes),
            reminderIntervalDays: Value(reminderIntervalDays),
            useRandomCheckIn: Value(useRandomCheckIn),
            activeCheckInIntervalDays: Value(active),
            closenessLevel: Value(closenessLevel),
            moodTag: Value(moodTag),
            lastChatSnippet: Value(lastChatSnippet),
            howWeMet: Value(howWeMet),
            phoneNumber: Value(phoneNumber),
          ),
        );
  }

  /// Sets only the stored photo path (after copying a file into app storage).
  ///
  /// Parameters:
  /// - [id]: friend id.
  /// - [photoPath]: absolute path, or `null` to clear.
  ///
  /// Returns: number of rows updated.
  Future<int> setFriendPhotoPath(int id, String? photoPath) {
    return (_database.update(_database.friends)..where((t) => t.id.equals(id))).write(
          FriendsCompanion(
            photoPath: Value(photoPath),
          ),
        );
  }

  /// Sets when you last logged reaching out and rolls the next check-in interval.
  ///
  /// Pass `null` to clear (rhythm falls back to creation date).
  ///
  /// Returns: number of rows updated.
  Future<int> setLastContactedAt(int id, DateTime? when) async {
    if (when == null) {
      return (_database.update(_database.friends)..where((t) => t.id.equals(id))).write(
            const FriendsCompanion(
              lastContactedAt: Value(null),
            ),
          );
    }
    final row = await getFriendById(id);
    if (row == null) {
      return 0;
    }
    final level = FriendLevel.fromStorage(row.closenessLevel);
    final active = resolveActiveCheckInIntervalDays(
      reminderIntervalDays: row.reminderIntervalDays,
      level: level,
      useRandomCheckIn: row.useRandomCheckIn,
    );
    return (_database.update(_database.friends)..where((t) => t.id.equals(id))).write(
          FriendsCompanion(
            lastContactedAt: Value(when),
            activeCheckInIntervalDays: Value(active),
          ),
        );
  }

  /// Marks a check-in today and rolls the next reminder interval.
  Future<int> logCheckIn(int id) {
    return setLastContactedAt(id, DateTime.now());
  }

  /// Updates only the last-conversation snippet (empty string clears it).
  Future<int> setLastChatSnippet(int id, String? snippet) {
    final trimmed = snippet?.trim();
    return (_database.update(_database.friends)..where((t) => t.id.equals(id))).write(
          FriendsCompanion(
            lastChatSnippet: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
          ),
        );
  }

  /// Deletes a friend permanently; clears local photo file if [photoPath] is not a remote URL.
  ///
  /// Parameters:
  /// - [id]: friend identifier.
  ///
  /// Returns: number of rows deleted.
  Future<int> deleteFriend(int id) async {
    final row = await getFriendById(id);
    final deleted =
        await (_database.delete(_database.friends)..where((t) => t.id.equals(id))).go();
    if (deleted > 0 && row?.photoPath != null) {
      await FriendPhotoStorage.deleteIfExists(row!.photoPath);
    }
    return deleted;
  }

  /// Returns all friends once (no watching), ordered by name for stable picks.
  ///
  /// Returns: current snapshot of rows.
  Future<List<FriendRow>> getAllFriends() {
    return (_database.select(_database.friends)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watches the full friend list for calendar markers and lists.
  ///
  /// Returns: a stream emitting whenever any friend row changes.
  Stream<List<FriendRow>> watchAllFriends() {
    return _database.select(_database.friends).watch();
  }
}
