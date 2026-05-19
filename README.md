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
10. [Default credentials & seeded data](#default-credentials--seeded-data)

---

## Tech stack

- **Flutter / Dart** — UI and app logic
- **sqflite** — SQLite storage (with `path_provider` for the DB path)
- **camera** — live preview + still capture for the scan and enrol flows
- **image_picker** — pas-foto upload for enrolment
- **google_mlkit_face_detection** — detect the face bounding box in a still
  image and crop to it
- **tflite_flutter** — run the pretrained `mobilefacenet.tflite` model to turn
  the cropped face into a 192-dimension embedding vector
- **image** — JPEG/PNG decode, resize to 112×112 for the model input
- **audioplayers** — short feedback sound after a scan
- **device_info_plus** — auto-detected device name shown in settings
- **pdf + printing** — generate and share the attendance PDF report
- **intl** — month/day formatting
- **crypto** — sha256 hash of the admin password and PIN

## Project structure

```
lib/
├── main.dart                                  # bootstrap, decides first route
├── routing/app_router.dart                    # named routes
├── core/
│   ├── constants/                             # app-wide strings & asset names
│   ├── theme/                                 # tokens, light/dark theme
│   ├── data/
│   │   ├── app_database.dart                  # all SQLite CRUD
│   │   ├── app_settings.dart                  # typed settings + service
│   │   ├── models.dart                        # Admin, SchoolClass, Student…
│   │   └── seed.dart                          # first-run dummy data
│   ├── services/
│   │   ├── face_recognition_service.dart      # ML Kit + MobileFaceNet pipeline
│   │   ├── sound_service.dart                 # plays scan-feedback sounds
│   │   └── device_info_service.dart           # auto-detect device name
│   ├── utils/time_utils.dart                  # status rules from clock-in/out
│   └── widgets/                               # shared UI atoms (JbButton…)
├── features/
│   ├── registration/                          # 2-step admin sign-up
│   ├── camera/                                # idle camera, PIN gate,
│   │                                          # recognised dialog, success
│   ├── menu/                                  # admin home (3 tiles)
│   ├── settings/                              # class CRUD, schedule, terminal
│   ├── students/                              # list, enrol/edit, photo embed
│   └── reports/                               # filters, recap, PDF export
assets/
├── icons/        # SVG icon set
├── models/       # mobilefacenet.tflite goes here
└── sounds/       # soft_chime.mp3, beep.mp3, success_ding.mp3
backup_db.sql     # readable schema + dummy data for reference
```

## Setup

1. Install the **MobileFaceNet** model file.
   Download `mobilefacenet.tflite` from any reputable public source (a
   `1 × 112 × 112 × 3` input, `1 × 192` output model) and copy it to:
   ```
   assets/models/mobilefacenet.tflite
   ```
   See [`assets/models/README.md`](assets/models/README.md) for the details.
   If the file is missing the app keeps running but the embedding falls back
   to a deterministic hash — **do not ship without the real model**.

2. (Optional) Drop three short audio files into `assets/sounds/`:
   `soft_chime.mp3`, `beep.mp3`, `success_ding.mp3`. Missing files
   silently no-op.

3. Fetch packages and run on an Android device:
   ```bash
   flutter pub get
   flutter run
   ```

Android `minSdk` is set to **24** (required for ML Kit + the recent camera
plugin). Permissions for `CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`
and `WRITE_EXTERNAL_STORAGE` are declared in
[`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml).

## First-time launch flow

1. **Registration step 1 — Account.**
   Admin enters a username, password and password confirmation. The page
   uses a password-strength meter and the standard "show/hide" eye toggle.
2. **Registration step 2 — PIN.**
   Admin enters a 4–8 digit PIN and confirms it. The PIN is what guards the
   admin menu later on (so it's worth remembering).
3. The credentials are hashed (sha256) and stored in the `admin` table.
   On success, the seeder runs (dummy classes + students + a few days of
   attendance) and the app navigates straight to the camera screen.

There is **no login / logout** flow. Once the admin row exists the camera
screen is the home screen forever; the PIN gate is the only way back into
admin areas.

## Main camera screen

- Live preview from the **front camera** (or first available camera).
- A subtle dark overlay + grid keeps the brand feel from the design mocks.
- The gold scan frame at the centre pulses when scanning.
- Tapping the **gold "Start scan" pill** at the bottom captures a still and
  runs the recognition pipeline.
- A modal *Processing face…* dialog is shown while the pipeline runs.
- After matching:
  - **Found** → navigate to the **Recognized** sheet with the student's
    photo, name, NIS, class, confidence percentage and clock-in / clock-out
    buttons. Auto-dismisses after **10 seconds**.
  - **Not found** → an error dialog (“Face not recognized · contact admin”).
- The burger icon (top-right) opens the **password gate** (modal bottom
  sheet) which requires the admin PIN before opening the admin menu.

## Admin menu

Three big tiles: **Students · Reports · Settings**. Today's date and the
admin's username are shown at the top. The close button at the top right and
the "Back to camera" footer both return to the camera screen.

### Students

- Filter by class via the funnel icon (default = **All classes**).
- Live search by name or NIS.
- Each row shows a coloured avatar (or the uploaded photo), the student's
  name, NIS and class.
- Draft students are dimmed (50% opacity) and tagged `DRAFT`.
- A trash icon on each row deletes the student (and all their attendance).
- A floating **+ Enroll face** button opens the enrolment screen.

#### Enroll / edit a student

- One pas-foto field. Tap to pick from gallery or take with the camera; the
  picked image is copied to the app's documents folder so the path is
  stable.
- **Process embed** runs the full pipeline: detect face → crop → resize →
  embed with MobileFaceNet → L2-normalise → store as a `BLOB` on the
  student row. Status indicator confirms `Embedding ready` or
  `No face detected`.
- Name, NIS and class dropdown are required.
- **Save draft** writes the row with `is_draft = 1` (no embedding required).
- **Submit** requires a successful embedding and writes `is_draft = 0`.
- Re-opening an existing student loads their values; the same screen
  doubles as the editor.

### Reports

- Filter sheet: **class · year · month · day**.
  - Year can be set to "Any" → all time.
  - Month "Any" with a year set → year-only filter.
  - Day "Any" with a month set → month-only filter.
- Recap row: PRESENT · LATE · ABSENT (counts + %).
- Table per student with P / L / A / attendance %.
- Tapping a row opens a dialog with the day-by-day breakdown for that
  student within the current filter scope.
- The bottom **PDF** button generates a styled PDF
  (`pdf` package, `printing` plugin) and opens the platform share / print
  sheet. The PDF reflects the same class / date filter shown on screen.
- Only **completed** attendance rows (where `check_out_time IS NOT NULL`)
  are included in the recap, table and PDF, per the spec.

### Settings

- **01 · Classes.** Every class is a card. Tap to toggle whether the
  terminal recognises it. Edit and delete buttons live inside the card.
  A class that's still in use by any student cannot be deleted; you'll
  see a snackbar reminding you why.
- **02 · Schedule.**
  - `CLOCK-IN` — opens the school day. Students who scan up to one hour
    after this time are marked *present*; later scans are *late*.
  - `CLOCK-OUT` — earliest moment a student can check out. A check-out
    button stays disabled until the current time crosses this threshold.
  - `LAST CHECK-OUT` — the daily cut-off (default `18:00`). Any record
    without a check-out by this time stays untracked, so the student is
    effectively absent for the day in the reports.
- **03 · This terminal.**
  - `Device name` — free-text; pre-filled from the actual device name on
    first launch (manufacturer + model on Android).
  - `Sound on scan` — one of *Soft chime · Beep · Success ding · Silent*.
    The chosen sound plays right after every scan.
  - `Detected device` — read-only, shows the raw value from
    `device_info_plus`.

## Face recognition pipeline

Both enrolment and live scanning follow the same pipeline (see
[`face_recognition_service.dart`](lib/core/services/face_recognition_service.dart)):

1. **Detect** — `google_mlkit_face_detection` returns one or more bounding
   boxes. We pick the largest (treated as the closest / most likely
   target).
2. **Crop & resize** — the matching crop of the source image is resized to
   `112 × 112` with the `image` package.
3. **Embed** — the resized RGB image is normalised to `[-1, 1]` floats and
   fed to `mobilefacenet.tflite`, returning a 192-dimension vector. The
   vector is L2-normalised so cosine similarity can be a simple dot
   product.
4. **Match** — for the scan flow, the probe vector is compared against
   every enrolled student in the currently *active* classes (see Settings)
   using **cosine similarity**. The student with the highest similarity is
   chosen, with a default acceptance threshold of `0.65`.

The pipeline is one-shot per tap (not a continuous stream) — this keeps the
ML Kit / TFLite invocations cheap and gives a clean UI: idle → tap →
progress dialog → recognised sheet.

## Attendance logic (status rules)

All three statuses (`present` / `late` / `absent`) are derived from the
configured `CLOCK-IN`, `CLOCK-OUT` and `LAST CHECK-OUT` settings:

| Moment | Outcome |
| --- | --- |
| Student scans **before `clockIn + 1h`** | check-in saved, status = **present** |
| Student scans **after `clockIn + 1h`** | check-in saved, status = **late** |
| Already checked-in, scans again | check-in button disabled |
| Scans after `clockOut` | check-out button enabled |
| Never checks-out before `lastCheckOut` | record stays incomplete → excluded from reports → counted as **absent** in any report containing that day |

Reports only consider **completed** attendance rows (both `check_in_time`
and `check_out_time` populated). Anything else does not contribute to a
student's percentage. This matches the brief:

> *“data yang masuk ke laporan adalah data yang sudah ada checkout nya,
> karena kan harus melakukan checkout agar data nya tersimpan ke laporan”*.

## Database schema

Full DDL + sample rows live in [`backup_db.sql`](backup_db.sql). Quick
summary:

```
admin       (id, username, password_hash, pin_hash, created_at)
classes     (id, name UNIQUE, created_at)
students    (id, name, nis UNIQUE, class_id → classes.id,
             photo_path, embedding BLOB, is_draft, created_at)
attendance  (id, student_id → students.id, date,
             check_in_time, check_out_time, status,
             UNIQUE (student_id, date))
settings    (key PRIMARY KEY, value)
```

Embeddings are stored as the raw little-endian bytes of a
`Float32List(192)` (768 bytes). The `settings` table keeps small things as
strings: `active_class_ids = "1,2,5"`, `clock_in_time = "07:00"`, etc.

## Default credentials & seeded data

The seeder in [`lib/core/data/seed.dart`](lib/core/data/seed.dart) and the
fixtures in [`backup_db.sql`](backup_db.sql) ship the same demo data:

| | |
| --- | --- |
| Admin username | `admin_smk` |
| Admin password | `admin123` |
| Admin PIN | `1234` |
| Classes | `X · RPL · A`, `X · TKR · A`, `XI · RPL · A`, `XI · MM · A`, `XII · AKL · B`, `XII · Animation` |
| Students | 12 dummy students spread across the classes |
| Attendance history | last 5 weekdays for the first 7 students (1 absent, 1 late) |

On a fresh device the seeder only runs once after the admin completes
registration, so you'll need to delete the app data (or the
`smk_jaya_buana.db` file in the app documents directory) to re-seed.
