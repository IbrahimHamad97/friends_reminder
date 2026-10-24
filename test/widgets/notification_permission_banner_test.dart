import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/widgets/notification_permission_banner.dart';

void main() {
  testWidgets('compact banner shows Enable and invokes callback',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationPermissionBanner.compact(
            onEnable: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.textContaining('Enable notifications'), findsOneWidget);
    await tester.tap(find.text('Enable'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('detailed banner disables Enable while busy', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationPermissionBanner.detailed(
            busy: true,
            onEnable: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Opening…'), findsOneWidget);
    await tester.tap(find.text('Opening…'));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
