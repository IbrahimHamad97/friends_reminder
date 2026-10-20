import 'package:drift/drift.dart';

/// Web / non-IO stub — this app uses on-device SQLite (Android / iOS / desktop).
QueryExecutor openConnection() {
  throw UnsupportedError(
    'Friends Reminder needs a native SQLite database. '
    'Run on an Android/iOS device or emulator, not Chrome/web.',
  );
}
