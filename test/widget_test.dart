import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:friends_reminder/data/database.dart';
import 'package:friends_reminder/main.dart';
import 'package:friends_reminder/services/friend_service.dart';
import 'package:friends_reminder/services/theme_service.dart';

void main() {
  testWidgets('Friends tab renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    final friendService = FriendService(database);
    final themeService = ThemeService();
    await themeService.load();

    await tester.pumpWidget(
      FriendsReminderApp(
        friendService: friendService,
        themeService: themeService,
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('Friends'), findsWidgets);

    await database.close();
    await tester.pump(const Duration(milliseconds: 50));
  });
}
