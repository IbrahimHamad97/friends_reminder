import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell hosting the bottom [NavigationBar] and nested branch navigator.
///
/// [navigationShell] comes from [StatefulShellRoute.indexedStack] in [createAppRouter].
/// Branch order: Home (0), Friends (1), Calendar (2), Settings (3).
class AppShell extends StatelessWidget {
  /// Creates the shell that wraps [navigationShell].
  ///
  /// Parameters:
  /// - [navigationShell]: stateful shell managing the active tab branch.
  const AppShell({super.key, required this.navigationShell});

  /// Nested navigator for the currently selected tab branch.
  final StatefulNavigationShell navigationShell;

  /// Builds a [Scaffold] with the shell body and bottom [NavigationBar].
  ///
  /// Parameters:
  /// - [context]: build context for theme and layout.
  ///
  /// Returns: scaffold whose body is [navigationShell].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
