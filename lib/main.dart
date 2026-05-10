import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/database.dart';
import 'router/app_router.dart';
import 'services/friend_service.dart';
import 'services/notification_scheduler.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'widgets/splash_overlay.dart';

/// Application entry: opens the Drift database, loads theme prefs, starts UI.
///
/// Returns: does not return; schedules [runApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final friendService = FriendService(database);
  final themeService = ThemeService();
  await themeService.load();
  try {
    await NotificationScheduler.instance.initialize();
    await NotificationScheduler.instance.rescheduleAll(friendService);
  } catch (e, st) {
    debugPrint('Notification bootstrap failed: $e\n$st');
  }
  runApp(
    FriendsReminderApp(
      friendService: friendService,
      themeService: themeService,
    ),
  );
}

/// Root widget wiring themes and [GoRouter] navigation.
class FriendsReminderApp extends StatefulWidget {
  /// Creates the app shell with services constructed in [main].
  ///
  /// Parameters:
  /// - [friendService]: friend persistence API for routed screens.
  /// - [themeService]: persisted light/dark preference.
  const FriendsReminderApp({
    super.key,
    required this.friendService,
    required this.themeService,
  });

  /// Friend data access shared across routes.
  final FriendService friendService;

  /// Theme controller listened to by [MaterialApp].
  final ThemeService themeService;

  @override
  State<FriendsReminderApp> createState() => _FriendsReminderAppState();
}

class _FriendsReminderAppState extends State<FriendsReminderApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter _router = createAppRouter(
    friendService: widget.friendService,
    themeService: widget.themeService,
    rootNavigatorKey: _rootNavigatorKey,
  );

  /// Rebuilds when [ThemeService] notifies listeners.
  ///
  /// Returns: nothing.
  void _onThemeChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  /// Refreshes local notification schedules when returning from background.
  ///
  /// Parameters:
  /// - [state]: lifecycle transition from the binding.
  ///
  /// Returns: nothing.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationScheduler.instance.rescheduleAll(widget.friendService);
    }
  }

  /// Builds the themed [MaterialApp.router].
  ///
  /// Parameters:
  /// - [context]: build context.
  ///
  /// Returns: configured root widget.
  @override
  Widget build(BuildContext context) {
    return SplashOverlay(
      child: MaterialApp.router(
        title: 'Friends Reminder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: widget.themeService.mode,
        routerConfig: _router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
