import '../data/app_database.dart';
import '../data/app_settings.dart';
import '../utils/time_utils.dart';

/// Walks every past weekday and applies the two attendance fix-up rules:
///
///   - If no `attendance` row exists for `(student, day)` → insert an
///     `absent` placeholder so the day shows up in reports.
///   - If a row has `check_in_time` but no `check_out_time` and the day is
///     past the `last_check_out` cut-off → fill `check_out_time` with the
///     configured `last_check_out` value and set `auto_checkout = 1`. The
///     original status (`present` / `late`) is preserved.
///
/// Idempotent: re-running on already-finalized days is a no-op. The
/// UNIQUE(student_id, date) constraint blocks duplicate inserts and the
/// WHERE clause on the auto check-out update skips rows that are already
/// complete.
class AttendanceFinalizerService {
  AttendanceFinalizerService._();
  static final AttendanceFinalizerService instance =
      AttendanceFinalizerService._();

  /// Holds the in-flight finalize future, if any. When `main.dart` kicks
  /// off finalize with `unawaited(...)` and the user immediately opens
  /// Reports (which awaits `finalizePastDays`), both call sites await the
  /// same Future — the work runs only once.
  Future<void>? _currentRun;

  /// Public entry point. Returns the already-running finalize if there is
  /// one; otherwise starts a fresh run and tracks it so concurrent callers
  /// can dedupe. The `_currentRun` slot is always cleared at the end
  /// (success or failure) via try/finally.
  Future<void> finalizePastDays() async {
    final inflight = _currentRun;
    if (inflight != null) return inflight;
    final run = _runFinalize();
    _currentRun = run;
    try {
      await run;
    } finally {
      _currentRun = null;
    }
  }

  Future<void> _runFinalize() async {
    final dbWrapper = AppDatabase.instance;
    final settings = await SettingsService.instance.load();
    final now = DateTime.now();
    final today = _dayOf(now);

    // Today is only finalized after the last-check-out cut-off has passed,
    // so students still scanning out at the end of the day are not yet
    // overwritten by the auto-finalize routine.
    final includeToday = isPastLastCheckOut(
      now: now,
      lastCheckOut: settings.lastCheckOut,
    );
    final endDay = includeToday
        ? today
        : today.subtract(const Duration(days: 1));

    final students = await dbWrapper.listStudents(includeDrafts: false);
    final eligible =
        students.where((s) => s.embedding != null).toList(growable: false);
    if (eligible.isEmpty) return;

    // Earliest enrolment day in the cohort sets the lower bound for the
    // backfill window — we do not invent absences for days before a
    // student was even registered.
    DateTime startDay = _dayOf(eligible.first.createdAt);
    for (final s in eligible) {
      final d = _dayOf(s.createdAt);
      if (d.isBefore(startDay)) startDay = d;
    }
    if (startDay.isAfter(endDay)) return;

    final lastCheckOutHms = '${settings.lastCheckOut}:00';
    final raw = await dbWrapper.db;

    for (var day = startDay;
        !day.isAfter(endDay);
        day = day.add(const Duration(days: 1))) {
      // Skip Saturday + Sunday (no school).
      if (day.weekday == DateTime.saturday ||
          day.weekday == DateTime.sunday) {
        continue;
      }

      // One query per day instead of one per (student, day): cheap on
      // SQLite, but still saves orders of magnitude on larger cohorts.
      final iso = formatYmd(day);
      final dayRows = await raw.query(
        'attendance',
        columns: ['student_id', 'check_in_time', 'check_out_time'],
        where: 'date = ?',
        whereArgs: [iso],
      );
      final byStudent = <int, Map<String, Object?>>{
        for (final r in dayRows) r['student_id'] as int: r,
      };

      for (final s in eligible) {
        if (day.isBefore(_dayOf(s.createdAt))) continue;
        final row = byStudent[s.id];
        if (row == null) {
          await dbWrapper.insertAbsentRecord(studentId: s.id, day: day);
        } else if (row['check_in_time'] != null &&
            row['check_out_time'] == null) {
          await dbWrapper.autoFinalizeCheckout(
            studentId: s.id,
            day: day,
            time: lastCheckOutHms,
          );
        }
        // Other cases: row is already complete or already explicitly
        // absent — nothing to do.
      }
    }
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
