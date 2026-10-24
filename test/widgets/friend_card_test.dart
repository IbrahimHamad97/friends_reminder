import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/widgets/friend_card.dart';

import '../helpers/friend_row_factory.dart';

void main() {
  testWidgets('shows name and frozen badge when friend is frozen',
      (tester) async {
    final friend = testFriend(name: 'Frozen Friend', isFrozen: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FriendCard(
            friend: friend,
            referenceDate: DateTime(2024, 6, 1),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Frozen Friend'), findsOneWidget);
    expect(find.textContaining('Frozen'), findsWidgets);
  });

  testWidgets('invokes onTap', (tester) async {
    var tapped = false;
    final friend = testFriend(name: 'Tap Me');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FriendCard(
            friend: friend,
            referenceDate: DateTime(2024, 6, 1),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap Me'));
    expect(tapped, isTrue);
  });
}
