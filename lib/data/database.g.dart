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
  static const VerificationMeta _closenessLevelMeta =
      const VerificationMeta('closenessLevel');
  @override
  late final GeneratedColumn<String> closenessLevel = GeneratedColumn<String>(
      'closeness_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('regular'));
  static const VerificationMeta _moodTagMeta =
      const VerificationMeta('moodTag');
  @override
  late final GeneratedColumn<String> moodTag = GeneratedColumn<String>(
      'mood_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastChatSnippetMeta =
      const VerificationMeta('lastChatSnippet');
  @override
  late final GeneratedColumn<String> lastChatSnippet = GeneratedColumn<String>(
      'last_chat_snippet', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _howWeMetMeta =
      const VerificationMeta('howWeMet');
  @override
  late final GeneratedColumn<String> howWeMet = GeneratedColumn<String>(
      'how_we_met', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        closenessLevel,
        moodTag,
        lastChatSnippet,
        howWeMet,
        phoneNumber,
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
    if (data.containsKey('closeness_level')) {
      context.handle(
          _closenessLevelMeta,
          closenessLevel.isAcceptableOrUnknown(
              data['closeness_level']!, _closenessLevelMeta));
    }
    if (data.containsKey('mood_tag')) {
      context.handle(_moodTagMeta,
          moodTag.isAcceptableOrUnknown(data['mood_tag']!, _moodTagMeta));
    }
    if (data.containsKey('last_chat_snippet')) {
      context.handle(
          _lastChatSnippetMeta,
          lastChatSnippet.isAcceptableOrUnknown(
              data['last_chat_snippet']!, _lastChatSnippetMeta));
    }
    if (data.containsKey('how_we_met')) {
      context.handle(_howWeMetMeta,
          howWeMet.isAcceptableOrUnknown(data['how_we_met']!, _howWeMetMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
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
      closenessLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}closeness_level'])!,
      moodTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood_tag']),
      lastChatSnippet: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_chat_snippet']),
      howWeMet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}how_we_met']),
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number']),
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

  /// Closeness tier: `bestie`, `close`, `regular`, `casual` — see [FriendLevel].
  final String closenessLevel;

  /// Optional mood tag: `good_place`, `busy`, `tough_time`, `celebrating`.
  final String? moodTag;

  /// Short “last talked about…” line for cards (separate from long [notes]).
  final String? lastChatSnippet;

  /// Optional one-liner, e.g. how you met.
  final String? howWeMet;

  /// Optional mobile number (digits / + for display; used for call + WhatsApp on detail).
  final String? phoneNumber;

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
      required this.closenessLevel,
      this.moodTag,
      this.lastChatSnippet,
      this.howWeMet,
      this.phoneNumber,
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
    map['closeness_level'] = Variable<String>(closenessLevel);
    if (!nullToAbsent || moodTag != null) {
      map['mood_tag'] = Variable<String>(moodTag);
    }
    if (!nullToAbsent || lastChatSnippet != null) {
      map['last_chat_snippet'] = Variable<String>(lastChatSnippet);
    }
    if (!nullToAbsent || howWeMet != null) {
      map['how_we_met'] = Variable<String>(howWeMet);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
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
      closenessLevel: Value(closenessLevel),
      moodTag: moodTag == null && nullToAbsent
          ? const Value.absent()
          : Value(moodTag),
      lastChatSnippet: lastChatSnippet == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChatSnippet),
      howWeMet: howWeMet == null && nullToAbsent
          ? const Value.absent()
          : Value(howWeMet),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
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
      closenessLevel: serializer.fromJson<String>(json['closenessLevel']),
      moodTag: serializer.fromJson<String?>(json['moodTag']),
      lastChatSnippet: serializer.fromJson<String?>(json['lastChatSnippet']),
      howWeMet: serializer.fromJson<String?>(json['howWeMet']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
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
      'closenessLevel': serializer.toJson<String>(closenessLevel),
      'moodTag': serializer.toJson<String?>(moodTag),
      'lastChatSnippet': serializer.toJson<String?>(lastChatSnippet),
      'howWeMet': serializer.toJson<String?>(howWeMet),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
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
          String? closenessLevel,
          Value<String?> moodTag = const Value.absent(),
          Value<String?> lastChatSnippet = const Value.absent(),
          Value<String?> howWeMet = const Value.absent(),
          Value<String?> phoneNumber = const Value.absent(),
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
        closenessLevel: closenessLevel ?? this.closenessLevel,
        moodTag: moodTag.present ? moodTag.value : this.moodTag,
        lastChatSnippet: lastChatSnippet.present
            ? lastChatSnippet.value
            : this.lastChatSnippet,
        howWeMet: howWeMet.present ? howWeMet.value : this.howWeMet,
        phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
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
      closenessLevel: data.closenessLevel.present
          ? data.closenessLevel.value
          : this.closenessLevel,
      moodTag: data.moodTag.present ? data.moodTag.value : this.moodTag,
      lastChatSnippet: data.lastChatSnippet.present
          ? data.lastChatSnippet.value
          : this.lastChatSnippet,
      howWeMet: data.howWeMet.present ? data.howWeMet.value : this.howWeMet,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
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
          ..write('closenessLevel: $closenessLevel, ')
          ..write('moodTag: $moodTag, ')
          ..write('lastChatSnippet: $lastChatSnippet, ')
          ..write('howWeMet: $howWeMet, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      birthday,
      notes,
      reminderIntervalDays,
      photoPath,
      lastContactedAt,
      closenessLevel,
      moodTag,
      lastChatSnippet,
      howWeMet,
      phoneNumber,
      createdAt);
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
          other.closenessLevel == this.closenessLevel &&
          other.moodTag == this.moodTag &&
          other.lastChatSnippet == this.lastChatSnippet &&
          other.howWeMet == this.howWeMet &&
          other.phoneNumber == this.phoneNumber &&
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
  final Value<String> closenessLevel;
  final Value<String?> moodTag;
  final Value<String?> lastChatSnippet;
  final Value<String?> howWeMet;
  final Value<String?> phoneNumber;
  final Value<DateTime> createdAt;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthday = const Value.absent(),
    this.notes = const Value.absent(),
    this.reminderIntervalDays = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.lastContactedAt = const Value.absent(),
    this.closenessLevel = const Value.absent(),
    this.moodTag = const Value.absent(),
    this.lastChatSnippet = const Value.absent(),
    this.howWeMet = const Value.absent(),
    this.phoneNumber = const Value.absent(),
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
    this.closenessLevel = const Value.absent(),
    this.moodTag = const Value.absent(),
    this.lastChatSnippet = const Value.absent(),
    this.howWeMet = const Value.absent(),
    this.phoneNumber = const Value.absent(),
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
    Expression<String>? closenessLevel,
    Expression<String>? moodTag,
    Expression<String>? lastChatSnippet,
    Expression<String>? howWeMet,
    Expression<String>? phoneNumber,
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
      if (closenessLevel != null) 'closeness_level': closenessLevel,
      if (moodTag != null) 'mood_tag': moodTag,
      if (lastChatSnippet != null) 'last_chat_snippet': lastChatSnippet,
      if (howWeMet != null) 'how_we_met': howWeMet,
      if (phoneNumber != null) 'phone_number': phoneNumber,
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
      Value<String>? closenessLevel,
      Value<String?>? moodTag,
      Value<String?>? lastChatSnippet,
      Value<String?>? howWeMet,
      Value<String?>? phoneNumber,
      Value<DateTime>? createdAt}) {
    return FriendsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      notes: notes ?? this.notes,
      reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
      photoPath: photoPath ?? this.photoPath,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      closenessLevel: closenessLevel ?? this.closenessLevel,
      moodTag: moodTag ?? this.moodTag,
      lastChatSnippet: lastChatSnippet ?? this.lastChatSnippet,
      howWeMet: howWeMet ?? this.howWeMet,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
    if (closenessLevel.present) {
      map['closeness_level'] = Variable<String>(closenessLevel.value);
    }
    if (moodTag.present) {
      map['mood_tag'] = Variable<String>(moodTag.value);
    }
    if (lastChatSnippet.present) {
      map['last_chat_snippet'] = Variable<String>(lastChatSnippet.value);
    }
    if (howWeMet.present) {
      map['how_we_met'] = Variable<String>(howWeMet.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
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
          ..write('closenessLevel: $closenessLevel, ')
          ..write('moodTag: $moodTag, ')
          ..write('lastChatSnippet: $lastChatSnippet, ')
          ..write('howWeMet: $howWeMet, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _colorArgbMeta =
      const VerificationMeta('colorArgb');
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
      'color_argb', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorArgb, photoPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<GroupRow> instance,
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
    if (data.containsKey('color_argb')) {
      context.handle(_colorArgbMeta,
          colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta));
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
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
  GroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorArgb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_argb'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupRow extends DataClass implements Insertable<GroupRow> {
  final int id;
  final String name;

  /// Flutter [Color.value] (ARGB).
  final int colorArgb;
  final String? photoPath;
  final DateTime createdAt;
  const GroupRow(
      {required this.id,
      required this.name,
      required this.colorArgb,
      this.photoPath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color_argb'] = Variable<int>(colorArgb);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      colorArgb: Value(colorArgb),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory GroupRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GroupRow copyWith(
          {int? id,
          String? name,
          int? colorArgb,
          Value<String?> photoPath = const Value.absent(),
          DateTime? createdAt}) =>
      GroupRow(
        id: id ?? this.id,
        name: name ?? this.name,
        colorArgb: colorArgb ?? this.colorArgb,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        createdAt: createdAt ?? this.createdAt,
      );
  GroupRow copyWithCompanion(GroupsCompanion data) {
    return GroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorArgb, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorArgb == this.colorArgb &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<GroupRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> colorArgb;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int colorArgb,
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        colorArgb = Value(colorArgb);
  static Insertable<GroupRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorArgb,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? colorArgb,
      Value<String?>? photoPath,
      Value<DateTime>? createdAt}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      photoPath: photoPath ?? this.photoPath,
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
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FriendGroupLinksTable extends FriendGroupLinks
    with TableInfo<$FriendGroupLinksTable, FriendGroupLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendGroupLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<int> friendId = GeneratedColumn<int>(
      'friend_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES friends (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [friendId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend_group_links';
  @override
  VerificationContext validateIntegrity(Insertable<FriendGroupLinkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {friendId, groupId};
  @override
  FriendGroupLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendGroupLinkRow(
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}friend_id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
    );
  }

  @override
  $FriendGroupLinksTable createAlias(String alias) {
    return $FriendGroupLinksTable(attachedDatabase, alias);
  }
}

class FriendGroupLinkRow extends DataClass
    implements Insertable<FriendGroupLinkRow> {
  final int friendId;
  final int groupId;
  const FriendGroupLinkRow({required this.friendId, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['friend_id'] = Variable<int>(friendId);
    map['group_id'] = Variable<int>(groupId);
    return map;
  }

  FriendGroupLinksCompanion toCompanion(bool nullToAbsent) {
    return FriendGroupLinksCompanion(
      friendId: Value(friendId),
      groupId: Value(groupId),
    );
  }

  factory FriendGroupLinkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendGroupLinkRow(
      friendId: serializer.fromJson<int>(json['friendId']),
      groupId: serializer.fromJson<int>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'friendId': serializer.toJson<int>(friendId),
      'groupId': serializer.toJson<int>(groupId),
    };
  }

  FriendGroupLinkRow copyWith({int? friendId, int? groupId}) =>
      FriendGroupLinkRow(
        friendId: friendId ?? this.friendId,
        groupId: groupId ?? this.groupId,
      );
  FriendGroupLinkRow copyWithCompanion(FriendGroupLinksCompanion data) {
    return FriendGroupLinkRow(
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendGroupLinkRow(')
          ..write('friendId: $friendId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(friendId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendGroupLinkRow &&
          other.friendId == this.friendId &&
          other.groupId == this.groupId);
}

class FriendGroupLinksCompanion extends UpdateCompanion<FriendGroupLinkRow> {
  final Value<int> friendId;
  final Value<int> groupId;
  final Value<int> rowid;
  const FriendGroupLinksCompanion({
    this.friendId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendGroupLinksCompanion.insert({
    required int friendId,
    required int groupId,
    this.rowid = const Value.absent(),
  })  : friendId = Value(friendId),
        groupId = Value(groupId);
  static Insertable<FriendGroupLinkRow> custom({
    Expression<int>? friendId,
    Expression<int>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (friendId != null) 'friend_id': friendId,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendGroupLinksCompanion copyWith(
      {Value<int>? friendId, Value<int>? groupId, Value<int>? rowid}) {
    return FriendGroupLinksCompanion(
      friendId: friendId ?? this.friendId,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (friendId.present) {
      map['friend_id'] = Variable<int>(friendId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendGroupLinksCompanion(')
          ..write('friendId: $friendId, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FriendsTable friends = $FriendsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $FriendGroupLinksTable friendGroupLinks =
      $FriendGroupLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [friends, groups, friendGroupLinks];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('friends',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('friend_group_links', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('friend_group_links', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  required String name,
  required DateTime birthday,
  Value<String?> notes,
  Value<int> reminderIntervalDays,
  Value<String?> photoPath,
  Value<DateTime?> lastContactedAt,
  Value<String> closenessLevel,
  Value<String?> moodTag,
  Value<String?> lastChatSnippet,
  Value<String?> howWeMet,
  Value<String?> phoneNumber,
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
  Value<String> closenessLevel,
  Value<String?> moodTag,
  Value<String?> lastChatSnippet,
  Value<String?> howWeMet,
  Value<String?> phoneNumber,
  Value<DateTime> createdAt,
});

final class $$FriendsTableReferences
    extends BaseReferences<_$AppDatabase, $FriendsTable, FriendRow> {
  $$FriendsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FriendGroupLinksTable, List<FriendGroupLinkRow>>
      _friendGroupLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.friendGroupLinks,
              aliasName: $_aliasNameGenerator(
                  db.friends.id, db.friendGroupLinks.friendId));

  $$FriendGroupLinksTableProcessedTableManager get friendGroupLinksRefs {
    final manager =
        $$FriendGroupLinksTableTableManager($_db, $_db.friendGroupLinks)
            .filter((f) => f.friendId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_friendGroupLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<String> get closenessLevel => $composableBuilder(
      column: $table.closenessLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moodTag => $composableBuilder(
      column: $table.moodTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChatSnippet => $composableBuilder(
      column: $table.lastChatSnippet,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get howWeMet => $composableBuilder(
      column: $table.howWeMet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> friendGroupLinksRefs(
      Expression<bool> Function($$FriendGroupLinksTableFilterComposer f) f) {
    final $$FriendGroupLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.friendGroupLinks,
        getReferencedColumn: (t) => t.friendId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendGroupLinksTableFilterComposer(
              $db: $db,
              $table: $db.friendGroupLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<String> get closenessLevel => $composableBuilder(
      column: $table.closenessLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moodTag => $composableBuilder(
      column: $table.moodTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChatSnippet => $composableBuilder(
      column: $table.lastChatSnippet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get howWeMet => $composableBuilder(
      column: $table.howWeMet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get closenessLevel => $composableBuilder(
      column: $table.closenessLevel, builder: (column) => column);

  GeneratedColumn<String> get moodTag =>
      $composableBuilder(column: $table.moodTag, builder: (column) => column);

  GeneratedColumn<String> get lastChatSnippet => $composableBuilder(
      column: $table.lastChatSnippet, builder: (column) => column);

  GeneratedColumn<String> get howWeMet =>
      $composableBuilder(column: $table.howWeMet, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> friendGroupLinksRefs<T extends Object>(
      Expression<T> Function($$FriendGroupLinksTableAnnotationComposer a) f) {
    final $$FriendGroupLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.friendGroupLinks,
        getReferencedColumn: (t) => t.friendId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendGroupLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.friendGroupLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
    (FriendRow, $$FriendsTableReferences),
    FriendRow,
    PrefetchHooks Function({bool friendGroupLinksRefs})> {
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
            Value<String> closenessLevel = const Value.absent(),
            Value<String?> moodTag = const Value.absent(),
            Value<String?> lastChatSnippet = const Value.absent(),
            Value<String?> howWeMet = const Value.absent(),
            Value<String?> phoneNumber = const Value.absent(),
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
            closenessLevel: closenessLevel,
            moodTag: moodTag,
            lastChatSnippet: lastChatSnippet,
            howWeMet: howWeMet,
            phoneNumber: phoneNumber,
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
            Value<String> closenessLevel = const Value.absent(),
            Value<String?> moodTag = const Value.absent(),
            Value<String?> lastChatSnippet = const Value.absent(),
            Value<String?> howWeMet = const Value.absent(),
            Value<String?> phoneNumber = const Value.absent(),
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
            closenessLevel: closenessLevel,
            moodTag: moodTag,
            lastChatSnippet: lastChatSnippet,
            howWeMet: howWeMet,
            phoneNumber: phoneNumber,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FriendsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({friendGroupLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (friendGroupLinksRefs) db.friendGroupLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (friendGroupLinksRefs)
                    await $_getPrefetchedData<FriendRow, $FriendsTable,
                            FriendGroupLinkRow>(
                        currentTable: table,
                        referencedTable: $$FriendsTableReferences
                            ._friendGroupLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FriendsTableReferences(db, table, p0)
                                .friendGroupLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.friendId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
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
    (FriendRow, $$FriendsTableReferences),
    FriendRow,
    PrefetchHooks Function({bool friendGroupLinksRefs})>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String name,
  required int colorArgb,
  Value<String?> photoPath,
  Value<DateTime> createdAt,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> colorArgb,
  Value<String?> photoPath,
  Value<DateTime> createdAt,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, GroupRow> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FriendGroupLinksTable, List<FriendGroupLinkRow>>
      _friendGroupLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.friendGroupLinks,
              aliasName: $_aliasNameGenerator(
                  db.groups.id, db.friendGroupLinks.groupId));

  $$FriendGroupLinksTableProcessedTableManager get friendGroupLinksRefs {
    final manager =
        $$FriendGroupLinksTableTableManager($_db, $_db.friendGroupLinks)
            .filter((f) => f.groupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_friendGroupLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
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

  ColumnFilters<int> get colorArgb => $composableBuilder(
      column: $table.colorArgb, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> friendGroupLinksRefs(
      Expression<bool> Function($$FriendGroupLinksTableFilterComposer f) f) {
    final $$FriendGroupLinksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.friendGroupLinks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendGroupLinksTableFilterComposer(
              $db: $db,
              $table: $db.friendGroupLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
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

  ColumnOrderings<int> get colorArgb => $composableBuilder(
      column: $table.colorArgb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
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

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> friendGroupLinksRefs<T extends Object>(
      Expression<T> Function($$FriendGroupLinksTableAnnotationComposer a) f) {
    final $$FriendGroupLinksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.friendGroupLinks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendGroupLinksTableAnnotationComposer(
              $db: $db,
              $table: $db.friendGroupLinks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    GroupRow,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (GroupRow, $$GroupsTableReferences),
    GroupRow,
    PrefetchHooks Function({bool friendGroupLinksRefs})> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> colorArgb = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            colorArgb: colorArgb,
            photoPath: photoPath,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int colorArgb,
            Value<String?> photoPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            colorArgb: colorArgb,
            photoPath: photoPath,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({friendGroupLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (friendGroupLinksRefs) db.friendGroupLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (friendGroupLinksRefs)
                    await $_getPrefetchedData<GroupRow, $GroupsTable,
                            FriendGroupLinkRow>(
                        currentTable: table,
                        referencedTable: $$GroupsTableReferences
                            ._friendGroupLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .friendGroupLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    GroupRow,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (GroupRow, $$GroupsTableReferences),
    GroupRow,
    PrefetchHooks Function({bool friendGroupLinksRefs})>;
typedef $$FriendGroupLinksTableCreateCompanionBuilder
    = FriendGroupLinksCompanion Function({
  required int friendId,
  required int groupId,
  Value<int> rowid,
});
typedef $$FriendGroupLinksTableUpdateCompanionBuilder
    = FriendGroupLinksCompanion Function({
  Value<int> friendId,
  Value<int> groupId,
  Value<int> rowid,
});

final class $$FriendGroupLinksTableReferences extends BaseReferences<
    _$AppDatabase, $FriendGroupLinksTable, FriendGroupLinkRow> {
  $$FriendGroupLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FriendsTable _friendIdTable(_$AppDatabase db) =>
      db.friends.createAlias(
          $_aliasNameGenerator(db.friendGroupLinks.friendId, db.friends.id));

  $$FriendsTableProcessedTableManager get friendId {
    final $_column = $_itemColumn<int>('friend_id')!;

    final manager = $$FriendsTableTableManager($_db, $_db.friends)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_friendIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups.createAlias(
      $_aliasNameGenerator(db.friendGroupLinks.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<int>('group_id')!;

    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FriendGroupLinksTableFilterComposer
    extends Composer<_$AppDatabase, $FriendGroupLinksTable> {
  $$FriendGroupLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableFilterComposer get friendId {
    final $$FriendsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.friends,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendsTableFilterComposer(
              $db: $db,
              $table: $db.friends,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendGroupLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendGroupLinksTable> {
  $$FriendGroupLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableOrderingComposer get friendId {
    final $$FriendsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.friends,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendsTableOrderingComposer(
              $db: $db,
              $table: $db.friends,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendGroupLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendGroupLinksTable> {
  $$FriendGroupLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$FriendsTableAnnotationComposer get friendId {
    final $$FriendsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.friendId,
        referencedTable: $db.friends,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FriendsTableAnnotationComposer(
              $db: $db,
              $table: $db.friends,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FriendGroupLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendGroupLinksTable,
    FriendGroupLinkRow,
    $$FriendGroupLinksTableFilterComposer,
    $$FriendGroupLinksTableOrderingComposer,
    $$FriendGroupLinksTableAnnotationComposer,
    $$FriendGroupLinksTableCreateCompanionBuilder,
    $$FriendGroupLinksTableUpdateCompanionBuilder,
    (FriendGroupLinkRow, $$FriendGroupLinksTableReferences),
    FriendGroupLinkRow,
    PrefetchHooks Function({bool friendId, bool groupId})> {
  $$FriendGroupLinksTableTableManager(
      _$AppDatabase db, $FriendGroupLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendGroupLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendGroupLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendGroupLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> friendId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendGroupLinksCompanion(
            friendId: friendId,
            groupId: groupId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int friendId,
            required int groupId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FriendGroupLinksCompanion.insert(
            friendId: friendId,
            groupId: groupId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FriendGroupLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({friendId = false, groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (friendId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.friendId,
                    referencedTable:
                        $$FriendGroupLinksTableReferences._friendIdTable(db),
                    referencedColumn:
                        $$FriendGroupLinksTableReferences._friendIdTable(db).id,
                  ) as T;
                }
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$FriendGroupLinksTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$FriendGroupLinksTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FriendGroupLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendGroupLinksTable,
    FriendGroupLinkRow,
    $$FriendGroupLinksTableFilterComposer,
    $$FriendGroupLinksTableOrderingComposer,
    $$FriendGroupLinksTableAnnotationComposer,
    $$FriendGroupLinksTableCreateCompanionBuilder,
    $$FriendGroupLinksTableUpdateCompanionBuilder,
    (FriendGroupLinkRow, $$FriendGroupLinksTableReferences),
    FriendGroupLinkRow,
    PrefetchHooks Function({bool friendId, bool groupId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$FriendGroupLinksTableTableManager get friendGroupLinks =>
      $$FriendGroupLinksTableTableManager(_db, _db.friendGroupLinks);
}
