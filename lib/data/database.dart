import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

/// Drift table storing one friend record per row.
///
/// [birthday] is stored as a full [DateTime]; the calendar year may be arbitrary
/// if the user only cares about month/day—the UI formats birthdays accordingly.
@DataClassName('FriendRow')
class Friends extends Table {
  /// Surrogate primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Display name shown across the app (required, non-empty in validation).
  TextColumn get name => text().withLength(min: 1, max: 128)();

  /// Birthday date used for reminders and calendar markers.
  DateTimeColumn get birthday => dateTime()();

  /// Optional free-form notes.
  TextColumn get notes => text().nullable()();

  /// Base check-in cadence in days (1–365); closeness picks the default.
  IntColumn get reminderIntervalDays =>
      integer().withDefault(const Constant(30))();

  /// When true, each cycle uses [activeCheckInIntervalDays] rolled from the base + level band.
  BoolColumn get useRandomCheckIn =>
      boolean().withDefault(const Constant(true))();

  /// Interval for the current pending check-in cycle (rolled or equal to [reminderIntervalDays]).
  IntColumn get activeCheckInIntervalDays =>
      integer().withDefault(const Constant(30))();

  /// Optional absolute path to a JPEG/PNG copied into app storage.
  TextColumn get photoPath => text().nullable()();

  /// When you last tapped "Reached out"; resets the check-in reminder rhythm.
  DateTimeColumn get lastContactedAt => dateTime().nullable()();

  /// Closeness tier: `bestie`, `close`, `regular`, `casual` — see [FriendLevel].
  TextColumn get closenessLevel =>
      text().withDefault(const Constant('regular'))();

  /// Optional mood tag: `good_place`, `busy`, `tough_time`, `celebrating`.
  TextColumn get moodTag => text().nullable()();

  /// Short “last talked about…” line for cards (separate from long [notes]).
  TextColumn get lastChatSnippet => text().nullable()();

  /// Optional one-liner, e.g. how you met.
  TextColumn get howWeMet => text().nullable()();

  /// Optional mobile number (digits / + for display; used for call + WhatsApp on detail).
  TextColumn get phoneNumber => text().nullable()();

  /// When this row was first created (UTC).
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// User-defined group (color, optional cover image, many friends).
@DataClassName('GroupRow')
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 128)();

  /// Flutter [Color.value] (ARGB).
  IntColumn get colorArgb => integer()();

  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Many-to-many: which friends belong to which group.
@DataClassName('FriendGroupLinkRow')
class FriendGroupLinks extends Table {
  IntColumn get friendId =>
      integer().references(Friends, #id, onDelete: KeyAction.cascade)();

  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {friendId, groupId};
}

/// Application SQLite database opened on the device documents directory.
@DriftDatabase(tables: [Friends, Groups, FriendGroupLinks])
class AppDatabase extends _$AppDatabase {
  /// Creates the database, using [executor] when provided (mainly for tests).
  ///
  /// Parameters:
  /// - [executor]: optional in-memory or test executor.
  ///
  /// Returns: an opened [AppDatabase] ready for queries.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  /// Applies additive upgrades and column drops when opening older DB files.
  ///
  /// Returns: drift migration strategy for create/upgrade paths.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(friends, friends.reminderIntervalDays);
            await m.addColumn(friends, friends.photoPath);
            await customStatement(
              'ALTER TABLE friends DROP COLUMN description',
            );
          }
          if (from < 3) {
            await m.addColumn(friends, friends.lastContactedAt);
          }
          if (from < 4) {
            await m.createTable(groups);
            await m.createTable(friendGroupLinks);
          }
          if (from < 5) {
            await m.addColumn(friends, friends.closenessLevel);
            await m.addColumn(friends, friends.moodTag);
            await m.addColumn(friends, friends.lastChatSnippet);
            await m.addColumn(friends, friends.howWeMet);
          }
          if (from < 6) {
            await m.addColumn(friends, friends.phoneNumber);
          }
        },
      );
}

/// Opens a SQLite file in app documents and returns a lazy [QueryExecutor].
///
/// Returns: a [LazyDatabase] that Drift will open on first access.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'friends_reminder.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
