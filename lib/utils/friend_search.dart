import '../data/database.dart';

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
  return false;
}
