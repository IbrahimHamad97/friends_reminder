import 'package:shared_preferences/shared_preferences.dart';

/// Persists expand/collapse for Friends-tab group sections.
class GroupSectionPrefs {
  GroupSectionPrefs._();

  static final GroupSectionPrefs instance = GroupSectionPrefs._();

  static String _key(int groupId) => 'group_section_expanded_$groupId';

  /// Whether [groupId]'s member list should show. Defaults to expanded.
  Future<bool> isExpanded(int groupId) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key(groupId)) ?? true;
  }

  /// Saves expand/collapse for [groupId].
  Future<void> setExpanded(int groupId, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key(groupId), value);
  }

  /// Drops the saved expand/collapse for a deleted group.
  Future<void> forget(int groupId) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key(groupId));
  }
}
