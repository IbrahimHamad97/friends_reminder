# Friends Reminder — feature change log

Short, **dated** notes for each meaningful change: what shipped, why, and where to look in code.  
The living product/architecture overview stays in **`friends_reminder.md`**.

**Convention:** newest entry first.

---

## 2026-05-10 — Optional phone + Call / WhatsApp on friend detail

**Summary:** Friends can store an optional **mobile number**. On **friend detail**, **Call** opens the dialer (`tel:`) and **WhatsApp** opens `wa.me` (with `whatsapp://` fallback). Form field with validation; JSON export includes `phoneNumber`. Schema **v6**.

**Primary code:** `lib/utils/friend_phone.dart`, `lib/screens/friend_detail_screen.dart`, `lib/screens/friend_form_screen.dart`, `lib/data/database.dart`, `android/app/src/main/AndroidManifest.xml` (package visibility for tel/WhatsApp).

**Dependencies:** `url_launcher`.

---

## 2026-05-10 — Friend detail screen + calmer list cards

**Summary:** New **`/friends/:id`** `FriendDetailScreen` holds closeness/mood chips, how you met, last conversation, notes, groups, and **Reached out** actions. `FriendCard` is slim again: accent strip, name, optional group dots, occasion chips, birthday + cadence only. Home, calendar, and friends list open **detail** first; **Edit** still goes to the form.

**Primary code:** `lib/screens/friend_detail_screen.dart`, `lib/router/app_router.dart`, `lib/widgets/friend_card.dart`, `lib/services/group_service.dart` (`getGroupsForFriend`).

---

## 2026-05-10 — Richer friend cards + closeness levels

**Summary:** Friends gain **closeness** (Bestie, Close friend, Regular, Acquaintance), optional **mood** tags, a **last conversation** snippet, and **how you met** — all editable in the friend form and shown on richer `FriendCard` rows (level accent bar, chips, quote box).

**Schema:** v5 — `closenessLevel`, `moodTag`, `lastChatSnippet`, `howWeMet` on `Friends`.

**Primary code:** `lib/models/friend_level.dart`, `lib/models/friend_mood.dart`, `lib/widgets/friend_card.dart`, `lib/screens/friend_form_screen.dart`, `lib/data/database.dart`, `lib/utils/friend_search.dart`.

**Export:** JSON backup `version` 2 includes the new fields.

---

## 2026-05-10 — Avatar load errors + Home notification prompt

**Summary:** Friend/group photo widgets fall back to the existing **letter** (or group **icon**) preview when a **URL or file fails to decode**. OS notification permission is **no longer requested at cold start**; the **Home** tab shows a **one-time** dialog — **Allow** requests permissions and jumps to **Settings**; **Not now** shows a snackbar and Settings documents how to enable later.

**Primary code:** `lib/widgets/local_file_avatar_io.dart`, `lib/services/notification_scheduler.dart` (`requestOsNotificationPermissions`), `lib/screens/home_screen.dart`, `lib/services/notification_schedule_prefs.dart`, `lib/screens/settings_screen.dart`.

**Docs:** `friends_reminder.md` — Notifications + Photos display bullets.

---

## 2026-05-10 — Cloudinary for friend and group photos

**Summary:** Friend avatars and group cover images are **uploaded to Cloudinary** after the existing circular crop and client-side JPEG resize/compress. The Drift `photoPath` column now stores the **`secure_url`** (HTTPS). Legacy absolute filesystem paths still render until the user replaces the photo.

**User-visible:** Same crop and save flow; photos load from the network. Saving without Cloudinary configured shows the existing form error snackbar (`StateError` message). Removing a photo or deleting a friend/group does **not** delete assets on Cloudinary (URLs are dropped locally only).

**Technical:**

| Piece | Location |
|-------|-----------|
| Env / defines | `assets/config/cloudinary.env`, `lib/services/cloudinary_config.dart` |
| Multipart upload | `lib/services/cloudinary_upload_service.dart` (`http`) |
| Upload entry points | `lib/services/friend_photo_storage.dart`, `lib/services/group_photo_storage.dart` |
| Bytes pipeline | `PickedPhotoReducer.readReducedJpegBytes` in `lib/utils/picked_photo_reduce.dart` |
| URL vs file avatars | `lib/widgets/local_file_avatar_io.dart`, `local_file_avatar_stub.dart` |
| Bootstrap | `lib/main.dart` — `dotenv.load` for bundled env file |
| Android INTERNET | `android/app/src/main/AndroidManifest.xml` |
| macOS outbound network | `macos/Runner/DebugProfile.entitlements`, `Release.entitlements` |

**Dependencies:** `http`, `flutter_dotenv`.

**Docs:** `friends_reminder.md` — product overview, tech stack, data model `photoPath`, architecture, Photos section, forms.

**Your Cloudinary setup:** Create an **unsigned** upload preset, set `CLOUDINARY_CLOUD_NAME` and `CLOUDINARY_UPLOAD_PRESET` in `assets/config/cloudinary.env` (or use `--dart-define` for CI/release).

---

## 2026-05-12 — Circular photo crop before save

**Summary:** Gallery picks for friend and group photos open a full-screen **circular** 1:1 crop editor (`crop_your_image`, `withCircleUi: true`, interactive zoom/pan). Cancel discards; **Use this crop** writes a temp file and returns to the form, then the existing JPEG resize/compress pipeline runs on save.

**Primary code:** `lib/screens/circular_crop_screen.dart`, `lib/utils/circular_photo_crop.dart`; wired from `friend_form_screen.dart` and `group_form_screen.dart` (read `XFile` bytes then `pushCropEditor`).

**Dependencies:** `crop_your_image` (replaced attempted `image_cropper`, which pulled a platform interface incompatible with this Flutter SDK’s `Color` API).

**Docs:** `friends_reminder.md` — Images row + Photos (Cloudinary) + form bullets.

---

## 2026-05-12 — App-side photo compression (local-only storage)

**Summary:** Friend and group photos picked from the gallery are **resized** (max long edge), **re-encoded as JPEG** at a fixed quality band, and written through a pipeline that **drops original file metadata** (EXIF/GPS) as much as practical—without any cloud upload. Aligns with a single-device, no-login product.

**Details:**

| Step | Implementation |
|------|------------------|
| Resize (max long edge) | 1024 px friend avatars, 1600 px group covers |
| Re-encode | JPEG quality ~80 (friend) / ~82 (group); stored as `.jpg` |
| Metadata | Fresh JPEG from pixels / native encoder—no preservation of original EXIF |

**Primary code:**

- `lib/utils/picked_photo_reduce.dart` — `PickedPhotoReducer`, `PickedPhotoKind`
- `lib/services/friend_photo_storage.dart` — calls reducer before final `friend_<id>.jpg`
- `lib/services/group_photo_storage.dart` — calls reducer before final `group_<id>.jpg`
- `lib/screens/friend_form_screen.dart` / `group_form_screen.dart` — picker `maxWidth: 2400`, `imageQuality: 95` as a memory-friendly pre-step

**Dependencies:** `flutter_image_compress`, `image`, `crop_your_image` (see `pubspec.yaml`).

**Docs:** `friends_reminder.md` — tech stack + “Photos (Cloudinary)” under features.

---

## Template (copy for the next entry)

```markdown
## YYYY-MM-DD — Short title

**Summary:** One or two sentences.

**User-visible:** What changed in the UI or behavior.

**Technical:** Key files, migrations, new deps.

**Follow-ups:** Optional TODOs.
```
