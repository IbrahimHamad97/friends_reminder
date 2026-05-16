import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'friend_service.dart';

/// Writes friends data as JSON and opens the share sheet (files on mobile/desktop).
class FriendsBackupExport {
  FriendsBackupExport._();

  /// Serializes all friends and shares as `friends_reminder_backup.json`.
  ///
  /// Photos are not embedded (paths are device-local). Import is not implemented yet.
  static Future<void> shareJson(FriendService friends) async {
    final rows = await friends.getAllFriends();
    final payload = <String, dynamic>{
      'version': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'friends': rows
          .map(
            (f) => <String, dynamic>{
              'name': f.name,
              'birthday': f.birthday.toUtc().toIso8601String(),
              'notes': f.notes,
              'reminderIntervalDays': f.reminderIntervalDays,
              'lastContactedAt': f.lastContactedAt?.toUtc().toIso8601String(),
              'closenessLevel': f.closenessLevel,
              'moodTag': f.moodTag,
              'lastChatSnippet': f.lastChatSnippet,
              'howWeMet': f.howWeMet,
              'phoneNumber': f.phoneNumber,
              'createdAt': f.createdAt.toUtc().toIso8601String(),
            },
          )
          .toList(),
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);

    if (kIsWeb) {
      await Share.share(jsonStr, subject: 'Friends Reminder backup');
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/friends_reminder_backup.json');
    await file.writeAsString(jsonStr);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Friends Reminder backup',
    );
  }
}
