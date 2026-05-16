import '../data/database.dart';
import '../models/friend_level.dart';
import '../models/friend_mood.dart';

/// Returns whether [friend] matches a free-text [query] on name or notes.
///
/// Parameters:
/// - [friend]: row to test.
/// - [query]: user search string; trimmed, case-insensitive; empty matches all.
///
/// Returns: `true` when [query] is empty or occurs in name or notes.
bool friendMatchesSearchQuery(FriendRow friend, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return true;
  }
  if (friend.name.toLowerCase().contains(q)) {
    return true;
  }
  final notes = friend.notes;
  if (notes != null && notes.toLowerCase().contains(q)) {
    return true;
  }
  final level = FriendLevel.fromStorage(friend.closenessLevel);
  if (level.label.toLowerCase().contains(q) ||
      level.shortLabel.toLowerCase().contains(q)) {
    return true;
  }
  final mood = FriendMood.fromStorage(friend.moodTag);
  if (mood != null && mood.label.toLowerCase().contains(q)) {
    return true;
  }
  final chat = friend.lastChatSnippet;
  if (chat != null && chat.toLowerCase().contains(q)) {
    return true;
  }
  final met = friend.howWeMet;
  if (met != null && met.toLowerCase().contains(q)) {
    return true;
  }
  final phone = friend.phoneNumber;
  if (phone != null && phone.toLowerCase().contains(q)) {
    return true;
  }
  return false;
}
