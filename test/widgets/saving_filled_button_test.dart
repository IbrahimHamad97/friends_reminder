import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/widgets/saving_filled_button.dart';

void main() {
  testWidgets('idle button shows label and fires onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavingFilledButton(
            saving: false,
            label: 'Save',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(pressed, isTrue);
  });

  testWidgets('saving state disables button and shows saving label',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavingFilledButton(
            saving: true,
            label: 'Save',
            savingLabel: 'Saving…',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Saving…'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
