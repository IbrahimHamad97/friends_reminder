import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/calendar_screen.dart';
import '../screens/friend_detail_screen.dart';
import '../screens/friend_form_screen.dart';
import '../screens/friends_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/group_form_screen.dart';
import '../screens/settings_screen.dart';
import '../services/friend_service.dart';
import '../services/group_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_shell.dart';

/// Builds the application [GoRouter]: tabbed shell plus full-screen friend/group forms.
///
/// Shell routes (indexed stack):
/// - `/home` — dashboard: upcoming birthdays and next check-ins.
/// - `/friends` — main list with groups and ungrouped people.
/// - `/calendar` — birthday calendar.
/// - `/settings` — theme, reminders, export.
///
/// Full-screen routes (slide + fade transition) use the root navigator:
/// - `/friends/new`, `/friends/:id` (detail), `/friends/:id/edit` (form).
/// - `/groups/new`, `/groups/:id/edit` — group form.
///
/// Parameters:
/// - [friendService]: friend persistence for routed screens.
/// - [groupService]: group and membership persistence.
/// - [themeService]: persisted light/dark/system theme.
/// - [rootNavigatorKey]: key for the root navigator (overlays, full-screen pages).
///
/// Returns: configured [GoRouter] with [initialLocation] `/home`.
GoRouter createAppRouter({
  required FriendService friendService,
  required GroupService groupService,
  required ThemeService themeService,
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => HomeScreen(
                  friendService: friendService,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/friends',
                name: 'friends',
                builder: (context, state) => FriendsListScreen(
                  friendService: friendService,
                  groupService: groupService,
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
        pageBuilder: (context, state) => _slideUpPage<void>(
          key: state.pageKey,
          child: FriendFormScreen(
            friendService: friendService,
            groupService: groupService,
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/friends/:id/edit',
        name: 'friend-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _slideUpPage<void>(
            key: state.pageKey,
            child: FriendFormScreen(
              friendService: friendService,
              groupService: groupService,
              friendId: id,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/friends/:id',
        name: 'friend-detail',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _slideUpPage<void>(
            key: state.pageKey,
            child: FriendDetailScreen(
              friendService: friendService,
              groupService: groupService,
              friendId: id,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/groups/new',
        name: 'group-new',
        pageBuilder: (context, state) => _slideUpPage<void>(
          key: state.pageKey,
          child: GroupFormScreen(
            groupService: groupService,
            friendService: friendService,
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/groups/:id/edit',
        name: 'group-edit',
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _slideUpPage<void>(
            key: state.pageKey,
            child: GroupFormScreen(
              groupService: groupService,
              friendService: friendService,
              groupId: id,
            ),
          );
        },
      ),
    ],
  );
}

/// Full-screen page with a short fade + upward slide (used for friend/group forms).
///
/// Parameters:
/// - [key]: stable page key from [GoRouterState.pageKey].
/// - [child]: screen widget to wrap.
///
/// Returns: a [CustomTransitionPage] suitable for [GoRoute.pageBuilder].
CustomTransitionPage<void> _slideUpPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
