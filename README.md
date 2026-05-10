# Friends Reminder

Private Flutter app for remembering friend **birthdays** and **check-in rhythms**. Everything stays on the device: friends live in a local SQLite database (via Drift), and reminders use **local notifications** (no cloud backend in this build).

## Overview

- **Friends list** sorted by upcoming birthday, with optional photo avatars, notes, and a customizable reach-out cadence (every *n* days).
- **Calendar** view marking birthdays and browsing friends by day.
- **Local notifications** for birthdays and check-ins at a **reminder time** you pick in Settings (not tied to midnight unless you choose it).
- **“Reached out today”** on the edit screen resets the check-in rhythm from that date.
- **Export backup** (JSON) from Settings for names, dates, notes, and cadence—photos remain as files on device only.

Platforms targeted by typical Flutter workflows: **Android**, **iOS**, **Desktop**, **Web** (notifications and some native features may be limited on web/Linux).

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) stable channel, compatible with **Dart SDK ^3.6.0** (see `pubspec.yaml`).
- For mobile builds: Xcode (macOS + iOS), Android Studio / Android SDK (Android).
- Optional: a connected device or running emulator/simulator.

Check your environment:

```bash
flutter doctor -v
```

## Getting dependencies

From the project root:

```bash
cd friends_reminder
flutter pub get
```

## Regenerating code (Drift)

After changing `lib/data/database.dart` or Drift tables, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running the app (debug)

```bash
flutter run
```

Pick a device when prompted, or specify:

```bash
flutter run -d chrome          # web
flutter run -d windows         # Windows desktop
flutter devices                # list devices
```

## Tests & analysis

```bash
flutter analyze
flutter test
```

## Release builds

### Android APK (side-loading)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

Configure signing in `android/` per [Flutter Android deployment](https://docs.flutter.dev/deployment/android).

### iOS (IPA / App Store)

```bash
flutter build ipa --release
```

Requires Apple developer setup; see [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios).

### Windows

```bash
flutter build windows --release
```

### macOS

```bash
flutter build macos --release
```

### Web

```bash
flutter build web --release
```

---

## Project layout (high level)

| Path | Role |
|------|------|
| `lib/main.dart` | App entry, DB, notification bootstrap |
| `lib/data/` | Drift database schema |
| `lib/services/` | Friends API, notifications, theme, backup export |
| `lib/screens/` | Friends list, calendar, friend form, settings |
| `lib/router/` | `go_router` shell routes |
| `lib/widgets/` | Cards, shell, splash overlay |
| `test/` | Widget + unit tests |

## Permissions & OS notes

- **Notifications**: grant when prompted so reminders fire.
- **Android 14+**: “Alarms & reminders” / exact alarm permission may be required for reliable times.
- **Photos**: image picker uses platform permissions where applicable.


