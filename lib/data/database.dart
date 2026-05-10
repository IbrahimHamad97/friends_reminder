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

  /// How often to remind the user to reach out (1–365 days).
  IntColumn get reminderIntervalDays =>
      integer().withDefault(const Constant(14))();

  /// Optional absolute path to a JPEG/PNG copied into app storage.
  TextColumn get photoPath => text().nullable()();

  /// When you last tapped "Reached out"; resets the check-in reminder rhythm.
  DateTimeColumn get lastContactedAt => dateTime().nullable()();

  /// When this row was first created (UTC).
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Application SQLite database opened on the device documents directory.
@DriftDatabase(tables: [Friends])
class AppDatabase extends _$AppDatabase {
  /// Creates the database, using [executor] when provided (mainly for tests).
  ///
  /// Parameters:
  /// - [executor]: optional in-memory or test executor.
  ///
  /// Returns: an opened [AppDatabase] ready for queries.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
