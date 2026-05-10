import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell hosting the bottom [NavigationBar] and nested branch navigator.
///
/// The [navigationShell] is provided by [StatefulShellRoute] from go_router.
class AppShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  ///
  /// Parameters:
  /// - [navigationShell]: stateful shell managing indexed branches.
  const AppShell({super.key, required this.navigationShell});

  /// Nested navigator for the currently selected tab.
  final StatefulNavigationShell navigationShell;

  /// Maps [navigationShell] branch changes to the bottom bar.
  ///
  /// Parameters:
  /// - [context]: build context for icon colors.
  ///
  /// Returns: configured [Scaffold] with body and [NavigationBar].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
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
