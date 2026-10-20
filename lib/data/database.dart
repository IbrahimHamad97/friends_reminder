import 'package:drift/drift.dart';

import 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_io.dart' as db_connection;

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

  /// When true, reminders are paused and the friend is hidden from Home / Calendar loops.
  BoolColumn get isFrozen => boolean().withDefault(const Constant(false))();

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
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? db_connection.openConnection());

  /// Always `1` until a production release — wipe/reinstall in dev when the schema changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );
}
