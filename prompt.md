Flutter UI Slicing — SMK Jaya Buana Attendance App
You are an expert Flutter developer. Slice the attached HTML/UI design into a Flutter mobile app following clean architecture best practices. UI-only / dummy data at this stage — no business logic, no API calls, no state management library (no GetX, no Bloc, no Riverpod). Just StatelessWidget/StatefulWidget with hardcoded mock data and basic setState where strictly needed for visual transitions (e.g. password obscure toggle, tab selection).

1. Project Scope
   This is a face-recognition student attendance app for SMK Jaya Buana. The app has 10 screens forming one linear flow:

Registration — first-time admin signup (username, password, confirm password, strength meter)
Camera Idle — full-bleed camera viewport with face-scan frame, menu button top-right
Password Gate — bottom sheet with numeric keypad to unlock admin menu
Menu — full-screen menu with greeting + 3 tiles (Students, Reports, Settings) + sign-out
Settings — class grade picker (X/XI/XII), free-text class name, school hours dropdowns (clock-in/clock-out), late tolerance dropdown, device prefs
Students — searchable list of enrolled students with avatar, name, NIS, status pill (in/late/absent), FAB "Enroll face"
Add Student — 3-angle face capture (front/left/right) + full name + NIS, Submit button
Recognized — recognized face card with name, NIS, class, confidence + two big buttons Clock-in / Clock-out (no auto-submit), 8s timeout
Reports — month filter, P/L/A summary cards, attendance table, floating PDF export bar
Success — recognized avatar with check badge, arrival time, "On time" status, auto-return progress bar
All UI text is in English.

2. Architecture
   Use feature-first clean architecture with these layers per feature:

lib/
core/
theme/
app_theme.dart # ThemeData light & dark
app_colors.dart # Color constants
app_typography.dart # TextStyles
app_spacing.dart # Spacing & radius tokens
constants/
app_strings.dart # All English copy
app_assets.dart # Asset paths
widgets/
jb_button.dart # Primary / ghost / gold variants
jb_text_field.dart # Field with label, icon, suffix
jb_chip.dart # Filter & selection chips
jb_avatar.dart # Gradient initials avatar
jb_status_pill.dart # in/late/absent pill
jb_card.dart # Elevated card wrapper
jb_icons.dart # Custom SVG icons (use flutter_svg)
jb_face_frame.dart # Camera scan frame with gold brackets
jb_dot.dart
utils/
mock_data.dart # All dummy data (students, reports, etc)
features/
registration/
presentation/
pages/registration_page.dart
widgets/password_strength_bar.dart
camera/
presentation/
pages/camera_idle_page.dart
pages/password_gate_page.dart # bottom sheet route
pages/recognized_dialog_page.dart
pages/success_page.dart
widgets/
camera_top_bar.dart
face_scan_frame.dart
ready_status_pill.dart
recognized_card.dart
numeric_keypad.dart
menu/
presentation/
pages/menu_page.dart
widgets/menu_tile.dart
settings/
presentation/
pages/settings_page.dart
widgets/
grade_picker.dart
schedule_picker_row.dart
tolerance_dropdown.dart
students/
presentation/
pages/students_page.dart
pages/add_student_page.dart
widgets/
student_list_tile.dart
face_capture_slot.dart
reports/
presentation/
pages/reports_page.dart
widgets/
month_filter_chip.dart
summary_card.dart
attendance_table.dart
export_floating_bar.dart
routing/
app_router.dart # Named routes only, no go_router yet
main.dart # MaterialApp with theme + initial route
Domain & data layers are intentionally omitted — this slicing is pure presentation. Add them later when wiring real logic.

3. Design Tokens
   Extract these tokens into core/theme/:

Light theme

bg #FBF8F1 · bgElev #FFFFFF · bgSubtle #F2EDE0
border #E6DFCB · borderStrong #D6CDB4
text #0B1A35 · textMute #5A6584 · textFaint #9AA3BD
primary #0F2545 · onPrimary #FBF8F1
accent (gold) #C8A431 · onAccent #0B1A35
success #1F7A4A · warn #B8732C · danger #B0344A
Dark theme

bg #0A1426 · bgElev #13203B · bgSubtle #0F1A30
border #1F2E4D · borderStrong #2C3E63
text #F4EFE0 · textMute #9CA8C4 · textFaint #6B7794
primary #E8C547 (gold becomes primary in dark) · onPrimary #0A1426
accent #D4AF37 · success #5DD49A · warn #E8A35C · danger #E87A8E
Typography — use google_fonts: ^6.x

Nunito for all UI (weights 600/700/800/900)
JetBrains Mono for timestamps, NIS, percentages, large numeric displays
Radii — sm 8, md 14, lg 18, xl 22, pill 99

Spacing — 4/6/8/10/12/14/18/22/28 scale

4. Custom Icons
   The HTML has ~25 custom rounded SVG icons (face-scan, menu, report, settings, student, clock, calendar, download, plus, search, eye, eye-off, check, chevron-left/right/down, lock, user, camera-flip, flash, close, sparkle, filter, logout, bell, trash).

Do NOT use the Material Icons set or cupertino_icons. Recreate them as SVG strings in assets/icons/ and load via flutter_svg. Or, if simpler, build them with CustomPainter — but stay faithful to the soft, rounded, 1.8-stroke style shown in the HTML. Generic-feeling icons are a fail-state.

5. Mock Data Layout (in core/utils/mock_data.dart)
   class MockStudent {
   final String name, nis;
   final int hue;
   final String lastSeen;
   final StudentStatus status; // present | late | absent
   }

class MockReportRow {
final String name;
final int present, late, absent;
final int percent;
}
Provide ~10 dummy students and ~7 report rows matching the names in the HTML (Andini Pratiwi, Bagus Setiawan, Chika Maharani, Dimas Kurniawan, Elsa Wijayanti, Fariz Ramadhan, Gita Lestari…).

6. Routing
   Use plain Navigator.pushNamed with named routes in routing/app_router.dart. Routes: /registration, /camera, /password-gate (as modal bottom sheet), /menu, /settings, /students, /add-student, /recognized (modal), /success, /reports.

Add a hidden DevNavigator scaffold at /\_dev that lists all 10 screens for quick QA during development.

7. Avatars
   Implement JbAvatar widget that takes initials + hue and renders a LinearGradient from oklch(0.78 0.06 hue) to oklch(0.62 0.08 hue+30) — convert OKLCH to RGB at compile-time (use a small lookup table or precomputed Color constants in mock_data).

8. Camera Screen Notes
   Don't integrate a real camera. The camera screens just show a dark gradient background + subtle grid pattern + the gold scan frame overlay. Implement the grid with CustomPaint or a tileable SVG asset.

9. Pubspec
   Required packages only:

flutter_svg: ^2.x
google_fonts: ^6.x
Nothing else.

10. Quality Bar
    All widgets const where possible
    No print, no commented-out code, no TODOs in pushed code
    All copy lives in AppStrings (no hardcoded strings in widgets)
    Theme accessed via Theme.of(context).extension<JbColors>() — define a ThemeExtension<JbColors> so all the custom tokens (success, warn, accent, etc.) flow through cleanly
    Each screen must render correctly in both light and dark theme
    Use SafeArea properly; respect notch/status bar
    Target iPhone 14 Pro & Pixel 7 viewport sizes — visuals should match the HTML mocks pixel-for-pixel on those sizes
    Use Material 3 (useMaterial3: true)
11. Deliverables
    Full lib/ tree per the structure above
    pubspec.yaml
    assets/icons/\*.svg (all custom icons)
    A README.md at project root listing screens + routes + how to run + screenshot expectations
    After scaffolding, run flutter analyze and ensure zero warnings
12. What NOT to do
    ❌ No GetX, Bloc, Provider, Riverpod, or any state mgmt library
    ❌ No domain/data/repository folders yet
    ❌ No API calls, Dio, http
    ❌ No real face recognition / camera plugin
    ❌ No Material Icons.\* — use custom SVGs
    ❌ No Container(decoration: BoxDecoration(color:...)) for tokens — use theme
    ❌ No emoji in UI (the "👋" in the HTML success screen → replace with JbIcon.sparkle)
    Start with core/ then routing/ then each feature folder one at a time. After each feature, show me the screenshot and confirm before moving on.

I'll attach the standalone HTML design file separately — use it as the visual source of truth.

Paste prompt itu ke Claude Code, attach file SMK Jaya Buana Attendance — Standalone.html-nya, dan ia akan scaffold semua-nya bertahap.
