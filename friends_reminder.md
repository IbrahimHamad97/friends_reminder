# Friends Reminder

Private Flutter app for remembering **friend birthdays** and **check-in rhythms** (how often you want to be nudged to reach out). Friend and group data stay on-device in SQLite via **Drift**; **profile/cover photos** upload to **Cloudinary** (HTTPS URLs in the DB). Reminders use **local notifications** (no account or backend beyond image hosting).

---

## Table of contents

1. [Product overview](#product-overview)
2. [Tech stack](#tech-stack)
3. [Data model](#data-model)
4. [Architecture (code map)](#architecture-code-map)
5. [Navigation & routes](#navigation--routes)
6. [Features implemented so far](#features-implemented-so-far)
7. [Behavior details](#behavior-details)
8. [Testing & quality](#testing--quality)
9. [Future ideas & roadmap](#future-ideas--roadmap)
10. [Documentation & change log](#documentation--change-log)

---

## Product overview

- **Home**: Dashboard for the rest of the calendar year—upcoming birthdays and the next people due for a check-in (with human-readable “in N days” style copy).
- **Friends**: Searchable list organized into **groups** (color, optional photo, members) plus an **“Not in a group”** section. Each person opens a full-screen **friend editor**.
- **Calendar**: Month view of birthdays tied to stored friend data.
- **Settings**: Theme mode, default reminder **time of day**, notification permission hints, and **JSON export** of friends (backup / portability).

Core loop: add people → get birthday + check-in reminders → optionally tap **“Reached out”** on a friend to reset the rhythm from that date.

---

## Tech stack


| Area                   | Choice                                                                                                                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| UI                     | Flutter (Material 3)                                                                                                                                                                                      |
| Local DB               | Drift (SQLite)                                                                                                                                                                                            |
| Navigation             | `go_router` (stateful shell for tabs + modal-style full screens for forms)                                                                                                                                |
| Fonts                  | `google_fonts` (Plus Jakarta Sans)                                                                                                                                                                        |
| Images                 | `image_picker`; `crop_your_image` circular 1:1 crop; client-side resize/JPEG via `PickedPhotoReducer`; **`http` multipart upload** to **Cloudinary** (`FriendPhotoStorage` / `GroupPhotoStorage`, `CloudinaryUploadService`; see [Photos](#photos-cloudinary--client-side-processing)) |
| Env / networking       | `flutter_dotenv` (`assets/config/cloudinary.env`); **`http`** for uploads; **`Image.network`** / **`NetworkImage`** for URLs |
| Notifications          | `flutter_local_notifications` + `timezone` / `flutter_timezone`                                                                                                                                           |
| Sharing export         | `share_plus`                                                                                                                                                                                              |
| Color picking (groups) | `flutter_colorpicker`                                                                                                                                                                                     |


---

## Data model

Defined in `lib/data/database.dart` (schema version **4**).

### `Friends` → `FriendRow`


| Field                  | Role                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------------- |
| `id`                   | Primary key                                                                                  |
| `name`                 | Display name (required)                                                                      |
| `birthday`             | `DateTime` (year may be arbitrary; UI treats recurrence by month/day)                        |
| `notes`                | Optional free text                                                                           |
| `reminderIntervalDays` | Check-in cadence (default 14)                                                                |
| `photoPath`            | Optional **HTTPS** image URL (Cloudinary `secure_url`); legacy local paths are still shown if present until replaced |
| `lastContactedAt`      | When user last marked “reached out”; anchors reminder rhythm with `lastContactedAt` when set |
| `createdAt`            | Row creation (used as rhythm anchor when never contacted)                                    |


### `Groups` → `GroupRow`


| Field       | Role                      |
| ----------- | ------------------------- |
| `id`        | Primary key               |
| `name`      | Group label               |
| `colorArgb` | Stored `Color` value      |
| `photoPath` | Optional cover image URL (same semantics as friends) |
| `createdAt` | Metadata                  |


### `FriendGroupLinks` → `FriendGroupLinkRow`

Composite primary key `(friendId, groupId)`: many-to-many membership. Ungrouped friends appear only under **Not in a group**; friends in groups still appear under their group(s)—the UI lists grouped members under each group section.

### Migrations

- v2: reminder interval, photo, dropped legacy `description`
- v3: `lastContactedAt`
- v4: groups + link table

---

## Architecture (code map)

```
lib/
├── main.dart                 # DB, services, notification bootstrap, runApp
├── data/database.dart        # Drift schema + open connection
├── router/app_router.dart    # GoRouter: shell + form routes
├── theme/app_theme.dart      # Light/dark M3 themes (coral seed)
├── screens/                  # Full-page UI
├── services/                 # FriendService, GroupService, ThemeService, notifications, export, Cloudinary upload
├── utils/                    # date_utils, search, validators, home_dashboard_logic, etc.
└── widgets/                  # AppShell, FriendCard, FriendAvatar, FriendsGroupSection, …
```

- **Services** encapsulate Drift streams and writes (`FriendService`, `GroupService`), photo **Cloudinary** uploads (`CloudinaryUploadService`, `cloudinary_config.dart`), and local-only export/notifications.
- **Screens** bind streams and navigation; heavy forms live in `friend_form_screen.dart` and `group_form_screen.dart`.
- **Utils** keep birthday math and check-in rhythm logic consistent between UI and `NotificationScheduler` (`date_utils.dart`, `home_dashboard_logic.dart`).

---

## Navigation & routes

**Bottom tabs** (`lib/widgets/app_shell.dart`), order:


| Index | Path        | Screen              |
| ----- | ----------- | ------------------- |
| 0     | `/home`     | `HomeScreen`        |
| 1     | `/friends`  | `FriendsListScreen` |
| 2     | `/calendar` | `CalendarScreen`    |
| 3     | `/settings` | `SettingsScreen`    |


**Initial route**: `/home`.

**Full-screen routes** (root navigator, slide + fade): `/friends/new`, `/friends/:id/edit`, `/groups/new`, `/groups/:id/edit`.

---

## Features implemented so far

### Home tab (`lib/screens/home_screen.dart`)

- Watches **all friends** via `FriendService.watchAllFriends()`.
- **Next check-ins**: horizontal strip of up to 10 friends with soonest rhythm day; labels from `checkInReminderLabel` in `home_dashboard_logic.dart` (today / tomorrow / in N days).
- **Birthdays through year-end**: vertical list sorted by next occurrence in the **current calendar year** (`upcomingBirthdaysThroughYearEnd`); subtitles use `formatMonthDay` and `birthdayCountdownLabel`.
- Tapping entries navigates to the friend editor where applicable.
- While **searching** on Friends, group expansion behavior is handled on the Friends screen; Home is independent.

### Friends tab (`lib/screens/friends_list_screen.dart`)

- Streams: ordered friends for list, all groups by name, all friend–group links.
- **Search** filters by name and notes (`friend_search.dart`).
- **Groups**: each group is a `FriendsGroupSection` (`lib/widgets/friends_group_section.dart`): card with soft decorative blobs, **harmonized** group accent toward the theme, **title + member count**, overlapping **avatar cluster** (up to four faces + overflow badge), **wave ribbon** separator, inner tray of `FriendCard`s, **Edit** opens group form. Empty group shows a short invite copy.
- **Ungrouped** friends: section header + cards; optional **multi-group color dots** on cards when the person is in group(s) but shown in the ungrouped list (implementation uses link-derived color map).
- **FAB “Add”** sheet: add friend or new group.

### Friend form (`lib/screens/friend_form_screen.dart`)

- Name, birthday, notes, photo (gallery → **circular crop** sheet → client compress → **Cloudinary upload** on save), reminder interval, **Reached out** / last contacted, **group membership** multi-select.

### Group form (`lib/screens/group_form_screen.dart`)

- Name, color, optional photo (same **circular crop** flow, then **Cloudinary**), member checklist.

### Friend cards (`lib/widgets/friend_card.dart`)

- Avatar, name, birthday line, cadence line, optional notes preview, chips for **birthday today** and **check-in rhythm day**, chevron; respects `groupAccentColors` when provided.

### Calendar (`lib/screens/calendar_screen.dart`)

- Table-style calendar; marks days that match stored birthdays.

### Settings (`lib/screens/settings_screen.dart`)

- **Theme**: light / dark / system (`ThemeService` + `SharedPreferences`).
- **Reminder time**: persisted clock; triggers `NotificationScheduler.rescheduleAll`.
- **Export**: JSON snapshot of friends via `FriendsBackupExport` (`friends_reminder_backup.json`): name, birthday, notes, interval, `lastContactedAt`, `createdAt`. **Photos are not included** (and import is not implemented yet); see `lib/services/friends_backup_export.dart`.

### Notifications (`lib/services/notification_scheduler.dart`)

- Schedules **birthday** and **check-in** reminders locally.
- **Startup** (`main.dart`): initializes the plugin and time zones **without** showing an OS permission dialog.
- **First Home visit** (`lib/screens/home_screen.dart`): one-time dialog — **Allow** runs `NotificationScheduler.requestOsNotificationPermissions` then opens the in-app **Settings** tab; **Not now** dismisses and a snackbar points to Settings → **Local notifications** for written steps.
- Respects platform limits (e.g. fewer pending slots per friend on iOS).
- Skips or no-ops on unsupported platforms (e.g. web/Linux) where scheduling does not apply.

### Theming (`lib/theme/app_theme.dart`, `ThemeService`)

- Warm coral-forward palette; M3 surfaces; splash overlay wired from `main.dart` as applicable.

### Photos (Cloudinary + client-side processing)

- **Cloudinary**: after crop (non-web), the app **resizes/re-encodes JPEG** (`PickedPhotoReducer`), then **POST**s bytes to `https://api.cloudinary.com/v1_1/<cloud_name>/image/upload` with an **unsigned upload preset**. The JSON **`secure_url`** is stored in `photoPath` (same column name as before).
- **Configuration** (pick one or combine; `--dart-define` wins over the env file when both set a value):
  1. Edit **`assets/config/cloudinary.env`** in the project (bundled at build time): `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET`, optional `CLOUDINARY_FOLDER` (default `friends_reminder`). **Do not commit real secrets** to a public repo—use a private branch or local-only edits, or rely on `dart-define` in CI.
  2. Or pass **`--dart-define=CLOUDINARY_CLOUD_NAME=...`** and **`--dart-define=CLOUDINARY_UPLOAD_PRESET=...`** (and optionally `CLOUDINARY_FOLDER`) when running/building.
- **Cloudinary dashboard setup** (once per account):
  1. Copy your **cloud name** from the dashboard.
  2. **Settings → Upload → Upload presets → Add upload preset**: choose **Unsigned** (client-side upload from the app), enable **unsigned** uploading, and restrict to **Image** if you like. Note the **preset name** → `CLOUDINARY_UPLOAD_PRESET`.
  3. Optional: set a default folder in the preset, or rely on the app’s `folder` field (`<CLOUDINARY_FOLDER>/friends` or `…/groups`).
- **Where uploads go**: `FriendPhotoStorage` → folder segment `friends`; `GroupPhotoStorage` → `groups`.
- **Display**: `FriendAvatar` / form previews use **`buildLocalFileAvatar`**, which treats `http(s)://` as **`Image.network`** / **`Image.file`** with **`errorBuilder`** so a **broken or missing image falls back** to the caller’s widget (initial letter on friends, icon on group cover).
- **Deletion**: removing a friend/group clears the DB field; **remote images are not deleted** on Cloudinary (optional follow-up: Admin API / authenticated delete). **Local** paths are still deleted when encountered.
- **Android**: `INTERNET` permission is declared for upload + image load. **macOS**: sandbox **Outgoing connections (Client)** entitlement is enabled for the same.
- After a gallery pick (non-web), **`CircularCropScreen`** (`lib/screens/circular_crop_screen.dart`): **`crop_your_image`** with **`withCircleUi: true`**, 1:1, pinch/zoom; cropped bytes go to a temp file, then **`PickedPhotoReducer`** runs before upload.
- **`lib/utils/picked_photo_reduce.dart`**: max long edge **1024 px** (friend) / **1600 px** (group), JPEG quality **~80** / **~82**, strips most **EXIF / GPS** before upload.
- **Android / iOS / macOS**: tries **`FlutterImageCompress`** first; **fallback** `image` decode → scale → `encodeJpg` (Windows/Linux).
- Picker uses **`maxWidth: 2400`** before processing to limit decode memory.

---

## Behavior details

### Check-in rhythm (same rules everywhere)

- If `lastContactedAt` is set: rhythm days are multiples of `reminderIntervalDays` from that **date-only** anchor (see `isReachOutRhythmDay` in `date_utils.dart` and scheduler).
- If not: rhythm from **`createdAt` date-only** and interval.
- **Home “next check-in”** uses `nextCheckInRhythmDayOnOrAfter` in `home_dashboard_logic.dart` so the dashboard matches list/card “check-in day” semantics.

### Group accent color

- `FriendsGroupSection` blends stored group color slightly toward `ColorScheme.primary` so arbitrary user colors stay readable on M3 surfaces (`_harmonizedGroupAccent`).

---

## Testing & quality

- `test/date_utils_test.dart`: rhythm-day and related date helpers.
- `test/widget_test.dart`: smoke test that the app shell renders (Home + Friends labels).
- Run locally: `flutter analyze`, `flutter test`.

---

## Future ideas & roadmap

This section captures **directional** enhancements—not committed work. Prioritize by impact, privacy stance, and maintenance cost.

### Richer friend cards & context

- **Mood / status tags** (e.g. “going through a lot”, “good place”) so you recall emotional context before texting—would need new fields or a tag system + UI on `FriendCard` and the form.
- **Last conversation log** (short bullet: “cat, job stress, Portugal trip”) as a structured field or append-only mini journal—not the same as long `notes`; could power smarter reminders.
- **“How we met”** sentimental field (optional, single line or paragraph).
- **Anniversaries beyond birthdays**: friendiversary, met-on date, custom yearly events—new table or JSON column + calendar integration.

### Check-ins that feel more alive

- When a notification fires (or from Home), show a **suggested conversation starter** derived from notes or last log (“Ask how … is doing”).
- **Streak counter** for consecutive rhythm hits or logged check-ins—gamification + optional widget on Home.
- **“Random friend”** action: weighted toward people with old `lastContactedAt` or longest time since interaction—fun discovery surface (FAB or Home card).

### Calendar tab depth

- **“This week’s birthdays”** widget on Home or top of Calendar.
- Gentle **“You haven’t texted anyone in X days”** summary (computed from `lastContactedAt` across friends)—copy tone should stay kind, not punitive.

### Monetization / ads (only if you choose that product path)

- **Rewarded ad** to unlock a one-off **“relationship health”** insight (define metrics carefully; avoid junk science).
- **Rewarded or IAP** for **extra themes** or per-friend card accents (personalization users notice).
- **Ad-free window** as a reward after N logged check-ins (ethical, aligns with habit loop).

### Differentiators & delight

- **Voice memo notes** attached to a friend (storage, permissions, export implications).
- **Yearly “Friendship Wrapped”**: aggregates who you contacted most, longest streaks, birthdays hit, groups activity—**shareable graphic** for organic growth (seasonal, opt-in, privacy-first copy).
- Deeper **Widgets** (Android/iOS home screen) for this week’s birthdays or next check-in.

### Technical debt & platform

- Optional **import** symmetric to JSON export.
- **i18n** if you ship widely.
- **Onboarding** for notification permission and first friend.
- **Widget / golden tests** for `FriendsGroupSection` and Home sections.

---

## Documentation & change log

- **Product / architecture doc (this file)**: `friends_reminder.md` — update when behavior or stack changes in a lasting way.
- **Per-feature dated log**: `CHANGELOG_FEATURES.md` — each shipped feature gets a dated entry (summary, files, rationale). Start new work there when you merge a feature.

---

## Document maintenance

When you ship a feature: add a **dated entry** to `[CHANGELOG_FEATURES.md](CHANGELOG_FEATURES.md)`, add or extend a bullet under [Features implemented so far](#features-implemented-so-far) in this file when it is user-visible or architectural, and trim or promote roadmap items as needed.