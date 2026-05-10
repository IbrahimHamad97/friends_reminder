import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/calendar_screen.dart';
import '../screens/friend_form_screen.dart';
import '../screens/friends_list_screen.dart';
import '../screens/settings_screen.dart';
import '../services/friend_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_shell.dart';

/// Builds the application router with a tabbed shell and full-screen forms.
///
/// Parameters:
/// - [friendService]: data access for friend screens.
/// - [themeService]: persisted theme for settings.
/// - [rootNavigatorKey]: key assigned to the root navigator for overlays.
///
/// Returns: configured [GoRouter] with initial location `/friends`.
GoRouter createAppRouter({
  required FriendService friendService,
  required ThemeService themeService,
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/friends',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                name: 'friends',
                builder: (context, state) => FriendsListScreen(
                  friendService: friendService,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                builder: (context, state) => CalendarScreen(
                  friendService: friendService,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => SettingsScreen(
                  themeService: themeService,
                  friendService: friendService,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/friends/new',
        name: 'friend-new',
        builder: (context, state) => FriendFormScreen(
          friendService: friendService,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/friends/:id/edit',
        name: 'friend-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return FriendFormScreen(
            friendService: friendService,
            friendId: id,
          );
        },
      ),
    ],
  );
}
