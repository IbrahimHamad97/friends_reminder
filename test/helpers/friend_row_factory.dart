import 'package:friends_reminder/data/database.dart';

/// Builds a [FriendRow] with sensible defaults for unit tests.
FriendRow testFriend({
  int id = 1,
  String name = 'Alex',
  DateTime? birthday,
  String? notes,
  int reminderIntervalDays = 7,
  bool useRandomCheckIn = false,
  int activeCheckInIntervalDays = 7,
  String? photoPath,
  DateTime? lastContactedAt,
  String closenessLevel = 'regular',
  String? moodTag,
  String? lastChatSnippet,
  String? howWeMet,
  String? phoneNumber,
  bool isFrozen = false,
  DateTime? createdAt,
}) {
  return FriendRow(
    id: id,
    name: name,
    birthday: birthday ?? DateTime(1990, 5, 5),
    notes: notes,
    reminderIntervalDays: reminderIntervalDays,
    useRandomCheckIn: useRandomCheckIn,
    activeCheckInIntervalDays: activeCheckInIntervalDays,
    photoPath: photoPath,
    lastContactedAt: lastContactedAt,
    closenessLevel: closenessLevel,
    moodTag: moodTag,
    lastChatSnippet: lastChatSnippet,
    howWeMet: howWeMet,
    phoneNumber: phoneNumber,
    isFrozen: isFrozen,
    createdAt: createdAt ?? DateTime(2024, 1, 1),
  );
}
