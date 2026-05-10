// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FriendsTable extends Friends with TableInfo<$FriendsTable, FriendRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 128),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _birthdayMeta =
      const VerificationMeta('birthday');
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
      'birthday', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reminderIntervalDaysMeta =
      const VerificationMeta('reminderIntervalDays');
  @override
  late final GeneratedColumn<int> reminderIntervalDays = GeneratedColumn<int>(
      'reminder_interval_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(14));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastContactedAtMeta =
      const VerificationMeta('lastContactedAt');
  @override
  late final GeneratedColumn<DateTime> lastContactedAt =
      GeneratedColumn<DateTime>('last_contacted_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        birthday,
        notes,
        reminderIntervalDays,
        photoPath,
        lastContactedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends';
  @override
  VerificationContext validateIntegrity(Insertable<FriendRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(_birthdayMeta,
          birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta));
    } else if (isInserting) {
      context.missing(_birthdayMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('reminder_interval_days')) {
      context.handle(
          _reminderIntervalDaysMeta,
          reminderIntervalDays.isAcceptableOrUnknown(
              data['reminder_interval_days']!, _reminderIntervalDaysMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('last_contacted_at')) {
      context.handle(
          _lastContactedAtMeta,
          lastContactedAt.isAcceptableOrUnknown(
              data['last_contacted_at']!, _lastContactedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FriendRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      birthday: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birthday'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      reminderIntervalDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}reminder_interval_days'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      lastContactedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_contacted_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FriendsTable createAlias(String alias) {
    return $FriendsTable(attachedDatabase, alias);
  }
}

class FriendRow extends DataClass implements Insertable<FriendRow> {
  /// Surrogate primary key.
  final int id;

  /// Display name shown across the app (required, non-empty in validation).
  final String name;

  /// Birthday date used for reminders and calendar markers.
  final DateTime birthday;

  /// Optional free-form notes.
  final String? notes;

  /// How often to remind the user to reach out (1–365 days).
  final int reminderIntervalDays;

  /// Optional absolute path to a JPEG/PNG copied into app storage.
  final String? photoPath;

  /// When you last tapped "Reached out"; resets the check-in reminder rhythm.
  final DateTime? lastContactedAt;

  /// When this row was first created (UTC).
  final DateTime createdAt;
  const FriendRow(
      {required this.id,
      required this.name,
      required this.birthday,
      this.notes,
      required this.reminderIntervalDays,
      this.photoPath,
      this.lastContactedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['birthday'] = Variable<DateTime>(birthday);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['reminder_interval_days'] = Variable<int>(reminderIntervalDays);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || lastContactedAt != null) {
      map['last_contacted_at'] = Variable<DateTime>(lastContactedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FriendsCompanion toCompanion(bool nullToAbsent) {
    return FriendsCompanion(
      id: Value(id),
      name: Value(name),
      birthday: Value(birthday),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      reminderIntervalDays: Value(reminderIntervalDays),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      lastContactedAt: lastContactedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastContactedAt),
      createdAt: Value(createdAt),
    );
  }

  factory FriendRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthday: serializer.fromJson<DateTime>(json['birthday']),
      notes: serializer.fromJson<String?>(json['notes']),
      reminderIntervalDays:
          serializer.fromJson<int>(json['reminderIntervalDays']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      lastContactedAt: serializer.fromJson<DateTime?>(json['lastContactedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthday': serializer.toJson<DateTime>(birthday),
      'notes': serializer.toJson<String?>(notes),
      'reminderIntervalDays': serializer.toJson<int>(reminderIntervalDays),
      'photoPath': serializer.toJson<String?>(photoPath),
      'lastContactedAt': serializer.toJson<DateTime?>(lastContactedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FriendRow copyWith(
          {int? id,
          String? name,
          DateTime? birthday,
          Value<String?> notes = const Value.absent(),
          int? reminderIntervalDays,
          Value<String?> photoPath = const Value.absent(),
          Value<DateTime?> lastContactedAt = const Value.absent(),
          DateTime? createdAt}) =>
      FriendRow(
        id: id ?? this.id,
        name: name ?? this.name,
        birthday: birthday ?? this.birthday,
        notes: notes.present ? notes.value : this.notes,
        reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        lastContactedAt: lastContactedAt.present
            ? lastContactedAt.value
            : this.lastContactedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  FriendRow copyWithCompanion(FriendsCompanion data) {
    return FriendRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      notes: data.notes.present ? data.notes.value : this.notes,
      reminderIntervalDays: data.reminderIntervalDays.present
          ? data.reminderIntervalDays.value
          : this.reminderIntervalDays,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      lastContactedAt: data.lastContactedAt.present
          ? data.lastContactedAt.value
          : this.lastContactedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('notes: $notes, ')
          ..write('reminderIntervalDays: $reminderIntervalDays, ')
          ..write('photoPath: $photoPath, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, birthday, notes,
      reminderIntervalDays, photoPath, lastContactedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthday == this.birthday &&
          other.notes == this.notes &&
          other.reminderIntervalDays == this.reminderIntervalDays &&
          other.photoPath == this.photoPath &&
          other.lastContactedAt == this.lastContactedAt &&
          other.createdAt == this.createdAt);
}

class FriendsCompanion extends UpdateCompanion<FriendRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> birthday;
  final Value<String?> notes;
  final Value<int> reminderIntervalDays;
  final Value<String?> photoPath;
  final Value<DateTime?> lastContactedAt;
  final Value<DateTime> createdAt;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderIntervalDays = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FriendsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime birthday,
    this.notes = const Value.absent(),
    this.reminderIntervalDays = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        birthday = Value(birthday);
  static Insertable<FriendRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? birthday,
    Expression<String>? notes,
    Expression<int>? reminderIntervalDays,
    Expression<String>? photoPath,
    Expression<DateTime>? lastContactedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthday != null) 'birthday': birthday,
      if (notes != null) 'notes': notes,
      if (reminderIntervalDays != null)
        'reminder_interval_days': reminderIntervalDays,
      if (photoPath != null) 'photo_path': photoPath,
      if (lastContactedAt != null) 'last_contacted_at': lastContactedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FriendsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? birthday,
      Value<String?>? notes,
      Value<int>? reminderIntervalDays,
      Value<String?>? photoPath,
      Value<DateTime?>? lastContactedAt,
      Value<DateTime>? createdAt}) {
    return FriendsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      notes: notes ?? this.notes,
      reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
      photoPath: photoPath ?? this.photoPath,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reminderIntervalDays.present) {
      map['reminder_interval_days'] = Variable<int>(reminderIntervalDays.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (lastContactedAt.present) {
      map['last_contacted_at'] = Variable<DateTime>(lastContactedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthday: $birthday, ')
          ..write('notes: $notes, ')
          ..write('reminderIntervalDays: $reminderIntervalDays, ')
          ..write('photoPath: $photoPath, ')
          ..write('lastContactedAt: $lastContactedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FriendsTable friends = $FriendsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [friends];
}

typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  required String name,
  required DateTime birthday,
  Value<String?> notes,
  Value<int> reminderIntervalDays,
  Value<String?> photoPath,
  Value<DateTime?> lastContactedAt,
  Value<DateTime> createdAt,
});
typedef $$FriendsTableUpdateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> birthday,
  Value<String?> notes,
  Value<int> reminderIntervalDays,
  Value<String?> photoPath,
  Value<DateTime?> lastContactedAt,
  Value<DateTime> createdAt,
});

class $$FriendsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderIntervalDays => $composableBuilder(
      column: $table.reminderIntervalDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FriendsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
      column: $table.birthday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderIntervalDays => $composableBuilder(
      column: $table.reminderIntervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FriendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get reminderIntervalDays => $composableBuilder(
      column: $table.reminderIntervalDays, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastContactedAt => $composableBuilder(
      column: $table.lastContactedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FriendsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendsTable,
    FriendRow,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (FriendRow, BaseReferences<_$AppDatabase, $FriendsTable, FriendRow>),
    FriendRow,
    PrefetchHooks Function()> {
  $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> birthday = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> reminderIntervalDays = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime?> lastContactedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FriendsCompanion(
            id: id,
            name: name,
            birthday: birthday,
            notes: notes,
            reminderIntervalDays: reminderIntervalDays,
            photoPath: photoPath,
            lastContactedAt: lastContactedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime birthday,
            Value<String?> notes = const Value.absent(),
            Value<int> reminderIntervalDays = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime?> lastContactedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FriendsCompanion.insert(
            id: id,
            name: name,
            birthday: birthday,
            notes: notes,
            reminderIntervalDays: reminderIntervalDays,
            photoPath: photoPath,
            lastContactedAt: lastContactedAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FriendsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendsTable,
    FriendRow,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (FriendRow, BaseReferences<_$AppDatabase, $FriendsTable, FriendRow>),
    FriendRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
}
