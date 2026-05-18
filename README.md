# SMK Jaya Buana — Attendance App

Face-recognition student attendance terminal for SMK Jaya Buana. This stage
is a **pure UI slice** from the standalone HTML mock — no business logic, no
API calls, no state management library. Dummy data lives in
`lib/core/utils/mock_data.dart`.

## Architecture

Feature-first clean architecture (presentation layer only at this stage):

```
lib/
├── core/
│   ├── theme/           app_colors, app_typography, app_spacing, app_theme + JbColors ThemeExtension
│   ├── constants/       app_strings (all English copy), app_assets (svg paths)
│   ├── utils/           mock_data (10 students, 7 report rows, HueGradient)
│   └── widgets/         jb_button, jb_text_field, jb_chip, jb_avatar, jb_status_pill,
│                        jb_card, jb_dot, jb_icons (+ JbLogo)
├── features/
│   ├── registration/    01 · Registration
│   ├── camera/          02 · Camera Idle | 03 · Password Gate | 08 · Recognized | 10 · Success
│   ├── menu/            04 · Menu
│   ├── settings/        05 · Settings
│   ├── students/        06 · Students | 07 · Add Student
│   └── reports/         09 · Reports
├── routing/
│   └── app_router.dart  named routes + hidden /_dev navigator
└── main.dart
```

Domain & data layers are intentionally omitted at this stage — add them
when wiring real logic.

## Screens & Routes

| #  | Screen          | Route             | Notes                                                   |
|----|-----------------|-------------------|---------------------------------------------------------|
| 01 | Registration    | `/registration`   | First-time admin signup, password strength bar          |
| 02 | Camera Idle     | `/camera`         | Dark gradient + grid, gold face-scan frame, READY pill  |
| 03 | Password Gate   | `/password-gate`  | **Modal bottom sheet** with numeric keypad              |
| 04 | Menu            | `/menu`           | Greeting + 3 tiles (Students / Reports / Settings)      |
| 05 | Settings        | `/settings`       | Grade picker · class name · schedule · device           |
| 06 | Students        | `/students`       | Searchable list with status pills, "Enroll face" FAB    |
| 07 | Add Student     | `/add-student`    | 3-angle face capture + name + NIS                       |
| 08 | Recognized      | `/recognized`     | Card over camera with Clock-in / Clock-out actions      |
| 09 | Reports         | `/reports`        | Month filter, P/L/A summary, attendance table, PDF bar  |
| 10 | Success         | `/success`        | Avatar + check badge + auto-return progress (5s)        |

A hidden dev menu at `/_dev` lists every screen for quick QA. It is the
default initial route — change it in [`lib/main.dart`](lib/main.dart) when
wiring the real entry flow.

## Design Tokens

Defined in `core/theme/` and surfaced via `Theme.of(context).extension<JbColors>()`
(shortcut: `context.jb`).

- **Typography** — Nunito (UI) + JetBrains Mono (numerics) via `google_fonts`
- **Radii** — sm 8 · md 14 · lg 18 · xl 22 · pill 99
- **Spacing** — 4 / 6 / 8 / 10 / 12 / 14 / 18 / 22 / 28
- **Light theme** — `bg #FBF8F1`, `primary #0F2545`, `accent #C8A431`
- **Dark theme** — `bg #0A1426`, gold becomes primary (`#E8C547`)
- All screens render in both themes (toggle `themeMode` in `lib/main.dart`)

## Icons

All ~28 icons are hand-recreated SVGs in `assets/icons/` with a soft-rounded,
1.8-stroke style and `currentColor` stroke so they respect theme tint. Loaded
via `flutter_svg` and accessed through `JbIcon(JbIcon.faceScan)` etc.
Material Icons and Cupertino Icons are **not** used in any UI surface.

## Running

```bash
flutter pub get
flutter run
```

App boots into `/_dev` for QA. Tap any row to preview a screen. To launch
straight into the production entry, swap `initialRoute` in `lib/main.dart`
to `AppRoutes.registration` (or wherever the real flow begins).

Target devices: iPhone 14 Pro & Pixel 7 viewport sizes.

## Dependencies

```yaml
flutter_svg: ^2
google_fonts: ^6
```

Nothing else. No state management library, no Dio/http, no camera plugins.

## Verifying

```bash
flutter analyze   # must be zero warnings
flutter test
```

## What's NOT here yet

- Domain & data layers (will be added with real logic)
- Real face-recognition / camera integration
- Persistent state (everything resets on hot reload)
- Network or storage adapters

Wire these in subsequent stages — UI surfaces should stay thin and re-bind to
real notifiers/services without restructuring the widget tree.
