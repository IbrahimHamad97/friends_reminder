import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/friend_service.dart';
import '../utils/friend_search.dart';
import '../widgets/empty_state.dart';
import '../widgets/friend_card.dart';

/// Shows all friends sorted by next birthday, with search and create/edit flows.
class FriendsListScreen extends StatefulWidget {
  /// Creates the list screen bound to [friendService].
  ///
  /// Parameters:
  /// - [friendService]: stream/source of friend rows.
  const FriendsListScreen({super.key, required this.friendService});

  /// Data access for friends.
  final FriendService friendService;

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Current filter string (lowercase trimming done in [friendMatchesSearchQuery]).
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Clears the search field and resets filter.
  ///
  /// Returns: nothing.
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  /// Builds title, [SearchBar], and filtered list inside a [CustomScrollView].
  ///
  /// Parameters:
  /// - [context]: build context; used for navigation via [GoRouter].
  ///
  /// Returns: sliver-based scroll view.
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: StreamBuilder(
        stream: widget.friendService.watchFriendsOrderedByUpcomingBirthday(),
        builder: (context, snapshot) {
          final friends = snapshot.data ?? [];
          final busy = snapshot.connectionState == ConnectionState.waiting && friends.isEmpty;
          final filtered = friends
              .where((f) => friendMatchesSearchQuery(f, _searchQuery))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Friends',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              if (!busy && friends.isNotEmpty)
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
                        Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              if (busy)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (friends.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No friends yet',
                    message:
                        'Add people you care about and never miss a birthday. Tap below to start.',
                    actionLabel: 'Add your first friend',
                    onAction: () => context.push('/friends/new'),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No matches',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nothing matches “${_searchQuery.trim()}”. Try another word or clear the search.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final friend = filtered[index];
                        return FriendCard(
                          friend: friend,
                          referenceDate: today,
                          onTap: () => context.push('/friends/${friend.id}/edit'),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/friends/new'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add friend'),
      ),
    );
  }
}
