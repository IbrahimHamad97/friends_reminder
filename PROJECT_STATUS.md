# Friends Reminder — project status

Living snapshot of **what’s shipped** vs **what’s planned**.  
Detailed history: [`CHANGELOG_FEATURES.md`](CHANGELOG_FEATURES.md) · Architecture: [`friends_reminder.md`](friends_reminder.md)

**Last updated:** 2026-10-24

---

## Done (shipped)

### Core app
- [x] Flutter app with Drift (SQLite), Material 3, `go_router` tabs (Home, Friends, Calendar, Settings)
- [x] Friends: CRUD, search, groups + ungrouped section, group membership
- [x] Home dashboard: upcoming birthdays (year-end), next check-ins strip
- [x] Calendar: birthday markers
- [x] Settings hub → Appearance / Reminders / Data & privacy
- [x] Local notifications (birthday + check-in); **soft Enable banners** on Home (compact) + Settings/Reminders (detailed) — OS dialog on tap; app settings if permanently denied; **no auto prompt on launch**
- [x] **Exact-alarm banner** (Android) — shown when notifications are on but Alarms & reminders are off; CTA opens that settings screen only (never on notification Deny)
- [x] Check-in rhythm via **Reached out** / profile check-in + closeness-based intervals

### Photos
- [x] Circular crop before save
- [x] Client-side JPEG resize/compress
- [x] **On-device** JPEG storage under app documents; `photoPath` stores absolute path (leftover remote URLs still display until replaced)
- [x] Avatar fallback to **initial letter** on missing/broken images

### Friend profile (schema v7)
- [x] **Closeness levels:** Bestie, Close, Regular, Acquaintance (`FriendLevel`)
- [x] **Closeness → default cadence** in form (7 / 14 / 30 / 60 days) with band copy
- [x] **Random check-in timing** per level (toggle off for exact intervals); rolled on save & reach-out
- [x] Optional **mood** tag, **last conversation**, **how you met**, notes
- [x] Optional **phone number** — detail screen **Call** + **WhatsApp** (`url_launcher`)
- [x] **Import phone from contacts** (Android/iOS) on friend form

### Navigation & UX
- [x] **Friend detail** screen (`/friends/:id`) — read-first; rich context lives here
- [x] **Slim friend cards** on list (birthday/cadence, occasion chips)
- [x] Edit via `/friends/:id/edit`; add via `/friends/new`
- [x] **Save button loading state** + success snackbar (friend & group forms)
- [x] **Check-in from profile** — card CTA + last-conversation sheet (cancelable)
- [x] **Delete friend/group** → lands on Friends tab
- [x] **First check-in** is one full interval after add (not same day)
- [x] **Collapsible group sections** on Friends tab (remembered per group; search force-expands)
- [x] **Delete on group header** — ⋯ menu with Edit / Delete + confirm (friends stay; group + cover link removed)
- [x] **Freeze friend** — `isFrozen` (schema v8); pauses notifications; hidden from Home/Calendar; stays on Friends with badge; Freeze/Unfreeze on profile
- [x] **Theme gallery** — 12 palettes (6 light / 6 dark), preview checkmark, Apply
- [x] **System theme** — default on first launch; follows device light/dark (Sky / Aubergine); selectable in Appearance

### Not done / parked
- [ ] **Monetization** (AdMob banners + remove-ads IAP) — **parked** after shareholder review. Direction when unparked: free tier with ads; one-time or subscription **Remove ads** via **Google Play Billing / App Store IAP** (not PayPal alone). Entitlement lives on the store account and restores after reinstall—**independent of on-device friend/photo data**. Local-only storage does not block this.

### Pre–Play Store (still outstanding)
- [ ] Change `applicationId` from `com.example.friends_reminder` in `android/app/build.gradle`
- [ ] Release signing (not debug keys)
- [ ] Privacy policy URL (needed for contacts + if ads added later)
- [ ] Optional: bundle fonts instead of runtime `google_fonts` download (storage/perf)

---

## Core product — closeness-based reminders (trademark)

Randomized check-in intervals by friendship level:

| Level | Closeness (app) | Default days | Target cadence |
| ----- | ----------------- | ------------ | -------------- |
| 4 | Bestie | 7 | Random **every 1–2 weeks** (±1–2 days) |
| 3 | Close friend | 14 | Random **every 2–3 weeks** (±3–4 days) |
| 2 | Regular | 30 | Random **about monthly** (±1 week) |
| 1 | Acquaintance | 60 | Random **every 2–3 months** (±1 week) |

**Shipped:** defaults, form copy, random toggle, scheduler + Home/cards aligned, profile check-in + conversation sheet.

---

## To do (partner / shareholder backlog)

### Previously numbered items

1. [ ] **Better catchphrase** — splash, store listing, in-app tagline
2. [x] **Import contacts** when adding a friend (phone number; device permissions)
3. [x] **Closeness choices: explain timed intervals** on each level in the form
4. [x] **Pop-up after check-in** — after logging a check-in, prompt to update **last conversation**
5. [x] **Disable Save while saving** — friend/group forms; prevent double submit
6. [x] **Collapsible group sections** — expand/collapse + **delete on the group header** (⋯ menu; also still available from group edit form)
7. [x] **After delete, navigate to Friends tab** — `go('/friends')`
8. [ ] **Google Calendar integration** — birthdays and/or check-ins (prefer `.ics` export first, then OAuth if needed)
9. [x] **Change color theme** — global palette catalog (light/dark sections)

### New items (2026-10 partner list)

10. [ ] **Notification action buttons** — e.g. Check in / Log from the notification (plus in-app “floaty” quick check-in entry)
11. [x] **Freeze friend** — pause reminders / hide from active loops without deleting; prefer over hard delete
12. [ ] **Snooze** — from notification (and maybe detail): **1 hour**, **1 day**, or **until next cycle**
13. [x] **System theme default** — System preference follows device light/dark (default Sky / Aubergine); first launch defaults to System
14. [x] **Exact-alarm / reliable schedule banner** — soft banner when notifications on but exact alarms off; CTA → Alarms & reminders settings only

### Photos & backup (follow-ups)

15. [~] **Tell the user photos live on Cloudinary** — superseded by #17.
16. [~] **Delete uploaded photos when the app is removed** — superseded by #17 (local files go away with uninstall).
17. [x] **Remove Cloudinary; keep photos on device** — `FriendPhotoStorage` / `GroupPhotoStorage` write under app documents; Cloudinary upload/config/env removed; docs/Settings “on-device” copy matches reality again.

### Tests

18. [x] **Add tests** — unit/widget coverage for check-in catch-up (`nextCheckInNotificationDay`), cadence reroll, freeze + active friends, themes, notification banners, validators/search/phone, FriendService/GroupService, Home smoke test. Run with `flutter test`.

### Suggested build order

1. **Catchphrase (#1)** — easy; brand strings on splash / taglines  
2. **Notification actions + floaty check-in (#10)** — medium–hard; platform notification actions → reuse check-in flow  
3. **Snooze (#12)** — medium; builds on notification actions  
4. **Google Calendar (#8)** — hard; ship `.ics` first, OAuth sync later  

### Difficulty cheat sheet

| Item | Effort | Approach |
| ---- | ------ | -------- |
| #13 System theme default | Done | `system` pref + `didChangePlatformBrightness` → Sky / Aubergine |
| #14 Exact-alarm banner | Done | `canScheduleExactNotifications` + soft banner → `requestExactAlarmsPermission` |
| #1 Catchphrase | Easy | Swap splash/subtitle (+ store copy later) |
| #17 Local photos (drop Cloudinary) | Done | App-dir JPEG + local `photoPath`; Cloudinary removed |
| #6 Delete on group header | Done | Header ⋯ → Edit / Delete; confirm; expand tap untouched |
| #11 Freeze | Done | `isFrozen` schema v8; scheduler/Home/Calendar skip; Friends + profile controls |
| #10 Notification actions | Medium–hard | `flutter_local_notifications` actions + payload → existing check-in flow |
| #12 Snooze | Medium | Reschedule one-shot or roll next cycle; optional `snoozedUntil` |
| #8 Google Calendar | Hard | Stage 1: share `.ics`; Stage 2: Google OAuth + Calendar API |

---

## Parked product idea (separate app)

**Split-costs after group travel** — calculate who owes whom (not send money). Keep as a **new product**, not a Friends Reminder module.

---

## Notes

- **Docs:** Ship features → dated entry in `CHANGELOG_FEATURES.md`; update `friends_reminder.md` when behavior changes.
- **Schema:** kept at version **1** until Play Store release (wipe/reinstall when tables change in dev). Current tables include `isFrozen`, random check-in fields, groups, etc.
- **Item 6:** collapsible **group sections on Friends list** (not friend form sections). Header delete shipped.
- **Item 9:** themes shipped; further palette polish is optional, not blocking.
- **Monetization vs on-device:** Friend/photo data stays local. Purchase state does **not**—Play/App Store hold the sub or lifetime unlock; uninstall wipes SQLite but “Restore purchases” brings back no-ads. Network is still needed for ads + buy/restore; no Friends Reminder backend required for that MVP. Prefer one-time remove-ads over a sub for a small utility unless recurring revenue is a goal.
