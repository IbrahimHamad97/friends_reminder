# Friends Reminder — project status

Living snapshot of **what’s shipped** vs **what’s planned**.  
Detailed history: [`CHANGELOG_FEATURES.md`](CHANGELOG_FEATURES.md) · Architecture: [`friends_reminder.md`](friends_reminder.md)

**Last updated:** 2026-06-02

---

## Done (shipped)

### Core app
- [x] Flutter app with Drift (SQLite), Material 3, `go_router` tabs (Home, Friends, Calendar, Settings)
- [x] Friends: CRUD, search, groups + ungrouped section, group membership
- [x] Home dashboard: upcoming birthdays (year-end), next check-ins strip
- [x] Calendar: birthday markers
- [x] Settings: theme (light/dark/system), reminder time of day, JSON export
- [x] Local notifications (birthday + check-in); **permission prompt on Home** (one-time), not at cold start
- [x] Check-in rhythm via **Reached out** (`lastContactedAt`) + closeness-based intervals

### Photos
- [x] Circular crop before save
- [x] Client-side JPEG resize/compress
- [x] **Cloudinary** upload; `photoPath` stores HTTPS URL
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
- [x] **Slim friend cards** on list (accent strip, birthday/cadence, occasion chips only)
- [x] Edit via `/friends/:id/edit`; add via `/friends/new`
- [x] **Save button loading state** + success snackbar (friend & group forms)
- [x] **Check-in from profile** — “Did you check in today?” card + last-conversation sheet
- [x] **Delete friend/group** → lands on Friends tab
- [x] **First check-in** is one full interval after add (not same day)

### Not done / parked
- [ ] **Monetization** (AdMob banners + PayPal) — **parked** after shareholder review

### Pre–Play Store (still outstanding)
- [ ] Change `applicationId` from `com.example.friends_reminder` in `android/app/build.gradle`
- [ ] Release signing (not debug keys)
- [ ] Privacy policy URL (needed for contacts + if ads added later)
- [ ] Optional: bundle fonts instead of runtime `google_fonts` download (storage/perf)

---

## To do (shareholder backlog)

### Core product — closeness-based reminders

| Level | Closeness (app) | Default days | Target cadence |
| ----- | ----------------- | ------------ | -------------- |
| 4 | Bestie | 7 | Random **every 1–2 weeks** (±1–2 days) |
| 3 | Close friend | 14 | Random **every 2–3 weeks** (±3–4 days) |
| 2 | Regular | 30 | Random **about monthly** (±1 week) |
| 1 | Acquaintance | 60 | Random **every 2–3 months** (±1 week) |

**Shipped:** defaults, form copy, random toggle, scheduler + Home/cards aligned, profile check-in flow + last-conversation sheet.

### UX & features (numbered backlog)

1. [ ] **Better catchphrase** — splash, store listing, in-app tagline
2. [x] **Import contacts** when adding a friend (phone number; device permissions)
3. [x] **Closeness choices: explain timed intervals** on each level in the form
4. [x] **Pop-up after check-in** — after logging a check-in, prompt to update **last conversation**
5. [x] **Disable Save while saving** — friend/group forms; prevent double submit
6. [ ] **Collapsible group sections (Friends tab)** — expand/collapse each group’s member list; optional remember state per group *(“Not in a group” can stay always open)*
7. [x] **After delete, navigate to Friends tab** — `go('/friends')` instead of only popping one route
8. [ ] **Google Calendar integration** — birthdays and/or check-ins (scope TBD: OAuth vs `.ics` export first)
9. [ ] **Change color theme** — new brand palette in `app_theme.dart` (+ splash/icons if needed)

### Suggested build order

1. Collapsible groups (#6)
2. Catchphrase (#1)
3. Theme refresh (#9)
4. Google Calendar (#8)

---

## Notes

- **Docs:** Ship features → dated entry in `CHANGELOG_FEATURES.md`; update `friends_reminder.md` when behavior changes.
- **Schema v7:** `useRandomCheckIn`, `activeCheckInIntervalDays` — delete/reinstall app during dev (no migration needed yet).
- **Item 6 confirmed:** collapsible **group sections on Friends list** (not friend form sections).
