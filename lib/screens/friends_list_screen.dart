import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../services/friend_service.dart';
import '../services/group_service.dart';
import '../utils/friend_search.dart';
import '../widgets/empty_state.dart';
import '../widgets/friends_group_section.dart';
import '../widgets/friend_card.dart';

/// Main friends hub: **groups** (ribbon sections + member list), then **“Not in a group”**.
///
/// Search filters all visible cards. The FAB opens a sheet to add a **friend** or a **group**.
/// **Edit** on a group opens the group form; friend cards open the friend editor.
class FriendsListScreen extends StatefulWidget {
  /// Creates the friends hub screen.
  ///
  /// Parameters:
  /// - [friendService]: friend queries and ordering.
  /// - [groupService]: group, link, and color data for sections and dots.
  const FriendsListScreen({
    super.key,
    required this.friendService,
    required this.groupService,
  });

  /// Friend persistence and watch streams.
  final FriendService friendService;

  /// Group persistence, membership links, and derived color maps.
  final GroupService groupService;

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

/// [State] for [FriendsListScreen]: search text and FAB sheet wiring.
class _FriendsListScreenState extends State<FriendsListScreen> {
  /// Filters the list by name and notes ([friendMatchesSearchQuery]).
  final TextEditingController _searchController = TextEditingController();

  /// Lowercased filter source; updated via [_searchController] listener.
  String _searchQuery = '';

  /// Subscribes [_searchController] to rebuild when the query changes.
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  /// Disposes the search controller.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Clears the search field and resets [_searchQuery].
  ///
  /// Returns: nothing.
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  /// Presents **Add friend** and **New group** actions (uses [GoRouter.push] after dismiss).
  ///
  /// Returns: nothing.
  void _showAddMenu() {
    final router = GoRouter.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded),
                title: const Text('Add friend'),
                subtitle: const Text('Birthday, reminders, photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  router.push('/friends/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_special_rounded),
                title: const Text('New group'),
                subtitle: const Text('Color, cover photo, members'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  router.push('/groups/new');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Builds nested [StreamBuilder]s for friends, groups, and links, then a [CustomScrollView].
  ///
  /// Parameters:
  /// - [context]: build context for theme and navigation.
  ///
  /// Returns: scaffold with scrollable grouped content and FAB.
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final topInset = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<List<FriendRow>>(
        stream: widget.friendService.watchFriendsOrderedByUpcomingBirthday(),
        builder: (context, friendSnap) {
          final friends = friendSnap.data ?? [];
          final busy = friendSnap.connectionState == ConnectionState.waiting &&
              friends.isEmpty;
          final filtered = friends
              .where((f) => friendMatchesSearchQuery(f, _searchQuery))
              .toList();
          final friendById = {for (final f in friends) f.id: f};

          return StreamBuilder<List<GroupRow>>(
            stream: widget.groupService.watchGroupsOrderedByName(),
            builder: (context, groupSnap) {
              final groups = groupSnap.data ?? <GroupRow>[];

              return StreamBuilder<List<FriendGroupLinkRow>>(
                stream: widget.groupService.watchFriendGroupLinks(),
                builder: (context, linkSnap) {
                  final links = linkSnap.data ?? <FriendGroupLinkRow>[];
                  final colorMap = _friendIdToColors(groups, links);

                  final groupToFriendIds = <int, List<int>>{};
                  final inAnyGroup = <int>{};
                  for (final l in links) {
                    if (!friendById.containsKey(l.friendId)) {
                      continue;
                    }
                    groupToFriendIds
                        .putIfAbsent(l.groupId, () => [])
                        .add(l.friendId);
                    inAnyGroup.add(l.friendId);
                  }

                  final ungrouped = filtered
                      .where((f) => !inAnyGroup.contains(f.id))
                      .toList();
                  widget.friendService
                      .sortFriendsByUpcomingBirthday(ungrouped, today);

                  if (busy) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (friends.isEmpty) {
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding:
                              EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Friends',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            title: 'No friends yet',
                            message:
                                'Add people you care about and organize them into groups. Tap below to start.',
                            actionLabel: 'Add friend or group',
                            onAction: _showAddMenu,
                          ),
                        ),
                      ],
                    );
                  }

                  if (filtered.isEmpty) {
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding:
                              EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Friends',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          sliver: SliverToBoxAdapter(
                            child: SearchBar(
                              hintText: 'Search by name or notes',
                              controller: _searchController,
                              leading: const Icon(Icons.search_rounded),
                              trailing: [
                                if (_searchQuery.isNotEmpty)
                                  IconButton(
                                    tooltip: 'Clear',
                                    onPressed: _clearSearch,
                                    icon: const Icon(Icons.clear_rounded),
                                  ),
                              ],
                              elevation: const WidgetStatePropertyAll(0),
                              backgroundColor: WidgetStatePropertyAll(
                                scheme.surfaceContainerHighest
                                    .withValues(alpha: 0.55),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 56, color: scheme.outline),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No matches',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nothing matches “${_searchQuery.trim()}”.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton.tonal(
                                    onPressed: _clearSearch,
                                    child: const Text('Clear search'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final slivers = <Widget>[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Friends',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: SearchBar(
                          hintText: 'Search by name or notes',
                          controller: _searchController,
                          leading: const Icon(Icons.search_rounded),
                          trailing: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                tooltip: 'Clear',
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.clear_rounded),
                              ),
                          ],
                          elevation: const WidgetStatePropertyAll(0),
                          backgroundColor: WidgetStatePropertyAll(
                            scheme.surfaceContainerHighest
                                .withValues(alpha: 0.55),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ),
                  ];

                  for (final g in groups) {
                    final ids = groupToFriendIds[g.id] ?? [];
                    final members = ids
                        .map((id) => friendById[id])
                        .whereType<FriendRow>()
                        .where((f) => friendMatchesSearchQuery(f, _searchQuery))
                        .toList();
                    widget.friendService
                        .sortFriendsByUpcomingBirthday(members, today);

                    slivers.add(
                      SliverToBoxAdapter(
                        child: FriendsGroupSection(
                          group: g,
                          members: members,
                          referenceDate: today,
                          onEditGroup: () =>
                              context.push('/groups/${g.id}/edit'),
                          onFriendTap: (f) =>
                              context.push('/friends/${f.id}/edit'),
                        ),
                      ),
                    );
                  }

                  if (ungrouped.isNotEmpty) {
                    slivers.add(
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  color: scheme.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Not in a group',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    slivers.add(
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final friend = ungrouped[index];
                              return FriendCard(
                                friend: friend,
                                referenceDate: today,
                                groupAccentColors: colorMap[friend.id],
                                onTap: () =>
                                    context.push('/friends/${friend.id}/edit'),
                              );
                            },
                            childCount: ungrouped.length,
                          ),
                        ),
                      ),
                    );
                  }

                  return CustomScrollView(slivers: slivers);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_friends_list',
        onPressed: _showAddMenu,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  /// Builds friend id → list of group accent colors for the ungrouped section.
  ///
  /// Parameters:
  /// - [groups]: all group rows (for id → color).
  /// - [links]: all membership links.
  ///
  /// Returns: map suitable for [FriendCard.groupAccentColors].
  Map<int, List<Color>> _friendIdToColors(
      List<GroupRow> groups, List<FriendGroupLinkRow> links) {
    final idToColor = {for (final g in groups) g.id: Color(g.colorArgb)};
    final map = <int, List<Color>>{};
    for (final l in links) {
      final c = idToColor[l.groupId];
      if (c != null) {
        map.putIfAbsent(l.friendId, () => []).add(c);
      }
    }
    return map;
  }
}
