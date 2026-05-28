# Absensi SMK Jaya Buana

Face-recognition student attendance app built in Flutter. The app turns a
single Android device into a self-contained attendance terminal for SMK Jaya
Buana: students stand in front of the camera, the app recognises them with
**MobileFaceNet**, and the result is written into a local **SQLite** database.

Everything is local — there is no backend, no internet account, no cloud sync.
All data lives in the application documents directory of the device.

---

## Table of contents
1. [Tech stack](#tech-stack)
2. [Project structure](#project-structure)
3. [Setup](#setup)
4. [First-time launch flow](#first-time-launch-flow)
5. [Main camera screen](#main-camera-screen)
6. [Admin menu](#admin-menu)
   1. [Students](#students)
   2. [Reports](#reports)
   3. [Settings](#settings)
7. [Face recognition pipeline](#face-recognition-pipeline)
8. [Attendance logic (status rules)](#attendance-logic-status-rules)
9. [Database schema](#database-schema)
10. [Default & seeded data](#default--seeded-data)

---

## Tech stack

- **Flutter / Dart** — UI and app logic
- **sqflite** — SQLite storage (with `path_provider` for the DB path)
- **camera** — live preview, still capture, and the image stream used for
  live face-box detection
- **image_picker** — pas-foto upload for enrolment
- **image** — JPEG/PNG decode, resize to 112×112 for the model input
- **google_mlkit_face_detection** — detect the face bounding box (both for
  the live overlay and for cropping during enrolment / scanning)
- **tflite_flutter** — run the pretrained `mobilefacenet.tflite` model to turn
  a cropped face into a 192-dimension embedding vector
- **audioplayers** — short feedback sound after a scan
- **device_info_plus** — auto-detected device name used as the settings default
- **pdf + printing** — generate and share the multi-page attendance PDF report
- **share_plus** — share the `.sql` database backup to the developer's WhatsApp
- **url_launcher** — fallback "Contact developer" WhatsApp chat link
- **intl** — month/day formatting
- **crypto** — sha256 hash of the admin PIN

## Project structure

```
lib/
├── main.dart                                  # bootstrap, decides first route
├── routing/app_router.dart                    # named routes + route observer
├── core/
│   ├── constants/                             # app-wide strings & asset names
│   ├── theme/                                 # tokens, light/dark theme
│   ├── data/
│   │   ├── app_database.dart                  # all SQLite CRUD (schema v3)
│   │   ├── app_settings.dart                  # typed settings + service
│   │   ├── models.dart                        # Admin, SchoolClass, Student…
│   │   └── seed.dart                          # first-run dummy data
│   ├── services/
│   │   ├── face_recognition_service.dart      # ML Kit + MobileFaceNet pipeline
│   │   ├── sound_service.dart                 # plays scan-feedback sounds
│   │   ├── device_info_service.dart           # auto-detect device name
│   │   ├── database_backup_service.dart       # writes the .sql backup file
│   │   └── attendance_finalizer_service.dart  # auto-marks Absent + auto-checks-out
│   ├── utils/
│   │   ├── time_utils.dart                    # status rules from clock-in/out
│   │   └── pin_validator.dart                 # 6-digit PIN rules
│   └── widgets/                               # shared UI atoms (JbButton,
│                                              # JbPinDots, ShakeWidget…)
├── features/
│   ├── registration/                          # single-page admin sign-up
│   ├── camera/                                # idle camera, PIN gate,
│   │                                          # recognised screen, success
│   ├── menu/                                  # admin home (3 tiles)
│   ├── settings/                              # class CRUD, schedule, terminal
│   ├── students/                              # list, enrol/edit, photo embed
│   └── reports/                               # filters, recap, PDF export
assets/
├── icons/        # SVG icon set
├── images/       # logo.png (also the Android launcher icon)
├── models/       # mobilefacenet.tflite goes here
└── sounds/       # soft_chime.mp3, beep.mp3, success_ding.mp3
backup_db.sql     # readable schema (v2) + dummy data for reference
```

## Setup

1. Install the **MobileFaceNet** model file.
   Download `mobilefacenet.tflite` (a `1 × 112 × 112 × 3` input, `1 × 192`
   output model) and copy it to:
   ```
   assets/models/mobilefacenet.tflite
   ```
   See [`assets/models/README.md`](assets/models/README.md) for details.
   If the file is missing the app still runs but the embedding falls back to a
   deterministic hash — **do not ship without the real model**.

2. (Optional) Drop three short audio files into `assets/sounds/`:
   `soft_chime.mp3`, `beep.mp3`, `success_ding.mp3`. Missing files silently
   no-op.

3. Fetch packages and run on an Android device:
   ```bash
   flutter pub get
   flutter run
   ```

Android `minSdk` is **24** (required for ML Kit + the recent camera plugin).
Permissions for `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`,
`WRITE_EXTERNAL_STORAGE` plus `<queries>` for the WhatsApp link are declared in
[`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

The launcher icon is generated from `assets/images/logo.png` via
`flutter_launcher_icons` (`dart run flutter_launcher_icons`). The adaptive
icon uses `adaptive_icon_foreground_inset: 25` so the full Jaya Buana crest —
including the "JAYA BUANA" wordmark — stays inside the safe zone and is never
clipped by the launcher mask (circle / squircle / rounded square).

## First-time launch flow

Registration is a **single page** — there is no password, only a username and
a 6-digit PIN:

1. Enter a **username**.
2. **Create the admin PIN** — 6 digits entered on the on-screen keypad.
   Validation runs as soon as the 6th digit lands:
   - rejects all-same digits (e.g. `111111`)
   - rejects strictly ascending / descending runs (e.g. `123456`, `654321`)
   - on rejection the dots flash red and **shake**, then clear
   - on success the dots flash green and the page advances to confirm
3. **Confirm the PIN** — re-enter the same 6 digits. A mismatch shakes and
   clears; a match flashes green and the account is created.

The PIN is hashed (sha256) and stored in the `admin` table. The seeder then
runs (dummy classes + students + the current month's attendance) and the app
navigates to the camera screen.

There is **no login / logout** flow. Once the admin row exists the camera
screen is the home screen; the PIN gate is the only way into admin areas.

## Main camera screen

- Live preview from the **front camera** with a light vignette (only mild
  darkening at the very top and bottom for text legibility).
- **Live face box** — an image stream runs ML Kit face detection continuously
  and draws an animated green bracket around the detected face. When no face
  is present, the gold idle guide frame is shown instead.
- A gold **"Start scan"** pill at the bottom captures a still and runs the
  recognition pipeline behind a *Processing face…* dialog.
- After matching:
  - **Found** → the **Recognized** screen, which shows the just-captured photo
    framed in green at the top, and a card with the student's data
    (photo, name, NIS, class, confidence %, clock-in / clock-out buttons).
    Auto-dismisses after **10 seconds**.
  - **Not found** → an error dialog ("Face not recognized · contact admin").
- The **refresh** button (top-right) re-initialises the camera if it ever
  fails to start.
- The **burger** button (top-right) opens the **password gate**.
- Navigation never recreates the camera page — the menu / recognised / success
  screens are pushed on top and *popped* back, so the camera keeps running.

## Admin menu

Three equally-styled tiles: **Students · Reports · Settings** (tapping a tile
shows a blue ripple). Today's date and the admin username are at the top.
The footer holds two side-by-side buttons with the app version centered
beneath them:

- **Contact developer** (left) — opens the developer's WhatsApp chat
  (**+62 851-7822-6071**) pre-filled with a help message.
- **Backup Database** (right) — writes a fresh `.sql` backup of the whole
  database, then opens the system share sheet so the admin can send that file
  to the developer; the button shows a spinner while the backup is prepared.

The close button returns to the live camera.

### Students

- Filter by class via the funnel icon (default = **All classes**).
- Live search by name or NIS.
- Draft students are dimmed and tagged `DRAFT`.
- A trash icon deletes the student (and all their attendance).
- The **+ Enroll face** button opens the enrolment screen.

#### Enroll / edit a student

- One pas-foto field. Tap to pick from gallery or camera; the image is copied
  into the app documents folder so its path is stable.
- **Process embed** runs detect → crop → resize → MobileFaceNet → L2-normalise
  and stores the 192-d vector as a `BLOB`. A status line confirms
  `Embedding ready` or `No face detected`.
- Name, NIS and a class dropdown are required.
- **Save draft** writes the row with `is_draft = 1` (no embedding required).
- **Submit** requires a successful embedding.

### Reports

- Filter sheet: **class · year · month · day** (any level can be "Any" to
  widen the scope — month-only, year-only, or all-time).
- Recap row: PRESENT · LATE · ABSENT counts + %.
- Per-student table with P / L / A and attendance %.
- Tapping a row opens a day-by-day detail dialog for that student.
- The blue **EXPORT** footer sits below the scrollable table (not covering it)
  and the **PDF** button generates a styled, multi-page report matching the
  active filter: a **summary page** (recap + per-student table) followed by
  **one fresh page per student** listing every day's date, check-in time,
  check-out time and status.
- Only **completed** rows (with a `check_out_time`) are aggregated.

### Settings

- **01 · Classes** — each class is a card. Tap to toggle whether the terminal
  recognises it. Edit / delete live inside the card; a class still used by a
  student cannot be deleted.
- **02 · Schedule**
  - `CLOCK-IN` — scans up to one hour after this are *present*, later *late*.
  - `CLOCK-OUT` — earliest time the check-out button becomes enabled.
  - `LAST CHECK-OUT` — daily cut-off; a record with no check-out by then stays
    incomplete, so the student counts as absent for that day.
- **03 · This terminal**
  - `Device name` — free text, pre-filled from the real device name.
  - `Sound on scan` — *Soft chime · Beep · Success ding · Silent*.

## Face recognition pipeline

Both enrolment and scanning use the same pipeline
([`face_recognition_service.dart`](lib/core/services/face_recognition_service.dart)):

1. **Detect** — ML Kit returns face bounding boxes; the largest is chosen.
2. **Crop & resize** — cropped to the face, resized to `112 × 112`.
3. **Embed** — normalised to `[-1, 1]` and run through `mobilefacenet.tflite`,
   producing a 192-d vector that is L2-normalised.
4. **Match** — for scanning, the probe vector is compared against every
   enrolled student in the *active* classes using **cosine similarity**; the
   best match above `0.65` wins.

The live camera overlay uses a separate, lighter ML Kit detector (fast mode)
on the camera image stream just to draw the face box — it does not embed.

## Attendance logic (status rules)

| Moment | Outcome |
| --- | --- |
| Scans **before `clockIn + 1h`** | check-in saved, status = **present** |
| Scans **after `clockIn + 1h`** | check-in saved, status = **late** |
| Already checked-in | check-in button disabled |
| Scans at/after `clockOut` | check-out button enabled |
| **No check-in at all** on a school day | **absent** row inserted by auto-finalize → shows up in the A column |
| **Checked in but no check-out** by `lastCheckOut` | `check_out_time` auto-filled with `lastCheckOut`, row flagged `auto_checkout = 1`; status stays **present** / **late** |

**"Absent" now means the student did not come to school** (no check-in
record at all). Forgetting to scan out is **not** absent — it is "I came in
but the terminal auto-closed my day", surfaced with a small ⚠️ (asterisk
`*` in the PDF) next to the auto-filled check-out time.

This shift is implemented by the **auto-finalize** routine
([`attendance_finalizer_service.dart`](lib/core/services/attendance_finalizer_service.dart)),
which runs fire-and-forget at app launch and again (awaited) whenever the
Reports page is loaded. It walks every past weekday in the enrolment
window, inserts `absent` placeholders for students with no record, and
auto-checks-out students who forgot — idempotent thanks to the
`UNIQUE(student_id, date)` constraint and a `WHERE check_out_time IS NULL`
guard on the update.

A full breakdown of the time-to-status mapping (with a visual timeline,
the auto-finalize section, and concrete scenarios using real seeded
students) lives in
[`docs/attendance_time_rules.html`](docs/attendance_time_rules.html).

## Database schema

Full DDL + sample rows: [`backup_db.sql`](backup_db.sql). Summary (**v3**):

```
admin       (id, username, pin_hash, created_at)          -- no password
classes     (id, name UNIQUE, created_at)
students    (id, name, nis UNIQUE, class_id → classes.id,
             photo_path, embedding BLOB, is_draft, created_at)
attendance  (id, student_id → students.id, date,
             check_in_time, check_out_time, status,
             auto_checkout,
             UNIQUE (student_id, date))
settings    (key PRIMARY KEY, value)

indexes: idx_students_class, idx_attendance_student, idx_attendance_date
```

Embeddings are the raw little-endian bytes of a `Float32List(192)` (768 bytes).
The `settings` table keeps small values as strings, e.g.
`active_class_ids = "1,2,5"`, `clock_in_time = "07:00"`.

The database is at version **3**. v3 added the `auto_checkout INTEGER NOT
NULL DEFAULT 0` column to `attendance` (used by the auto-finalize routine
described in [Attendance logic](#attendance-logic-status-rules)). The
migration ladder applies a non-destructive `ALTER TABLE` for v2 → v3, so
production v2 data is preserved. Pre-v2 installs (dev-stage) still rebuild
from scratch.

A full `.sql` dump of the **live** database (schema + every row, with `BLOB`
embeddings hex-encoded as `X'…'`) can be produced on demand by
`AppDatabase.exportSqlDump()`. The **Contact developer** action
([Admin menu](#admin-menu)) uses this to write a timestamped
`backup_smk_jaya_buana_<date>.sql` file before sharing it — the dump can be
replayed against an empty SQLite database to restore the install.

## Default & seeded data

The seeder ([`lib/core/data/seed.dart`](lib/core/data/seed.dart)) runs once
after registration:

| | |
| --- | --- |
| Admin PIN | set by you on the registration screen (6 random digits) |
| Classes | `X · RPL · A`, `X · TKR · A`, `XI · RPL · A`, `XI · MM · A`, `XII · AKL · B`, `XII · Animation` |
| Students | 12 dummy students across the classes |
| Attendance | every weekday of the current month for the first 8 students (with one recurring absence and one recurring late) |

To re-seed, delete the app data (or the `smk_jaya_buana.db` file) and register
again.
