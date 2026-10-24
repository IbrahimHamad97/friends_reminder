import 'package:flutter_test/flutter_test.dart';

import 'package:friends_reminder/utils/group_palette.dart';

void main() {
  test('defaultGroupColorArgb is opaque teal', () {
    final color = defaultGroupColorArgb();
    expect(color >>> 24, 0xFF);
    expect(color, 0xFF00897B);
  });
}
