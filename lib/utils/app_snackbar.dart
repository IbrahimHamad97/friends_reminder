import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] so snackbars survive popping form routes.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Shows a short floating snackbar on the app root messenger.
void showAppSnackBar(
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      showCloseIcon: true,
    ),
  );
}
