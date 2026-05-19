import '../data/models.dart';

/// Parses an "HH:mm" string into a `DateTime` anchored to `day`.
DateTime parseTimeOfDay(String hhmm, DateTime day) {
  final parts = hhmm.split(':');
  final h = int.tryParse(parts.elementAt(0)) ?? 0;
  final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return DateTime(day.year, day.month, day.day, h, m);
}

/// Decide the attendance status at the moment of a check-in.
///
/// Rules from the spec (point 5):
///  - Check-in at or before clockIn → present
///  - Between clockIn and clockOut → late (after the clockIn hour passes by 1h)
///  - Strictly: if `now < clockIn + 1h` → present, else → late.
///
/// We treat "1 hour" as the tolerance window the user described:
/// "jika siswa check in dibawah jam 7 - sampai sebelum jam 8 artinya hadir,
///  jika diatas jam 8 pagi maka terlambat".
AttendanceStatus statusForCheckIn({
  required DateTime now,
  required String clockIn,
}) {
  final clockInDt = parseTimeOfDay(clockIn, now);
  final lateThreshold = clockInDt.add(const Duration(hours: 1));
  if (now.isBefore(lateThreshold)) return AttendanceStatus.present;
  return AttendanceStatus.late;
}

/// True when [now] is at-or-after the configured clock-out time.
bool canCheckOut({required DateTime now, required String clockOut}) {
  final co = parseTimeOfDay(clockOut, now);
  return !now.isBefore(co);
}

/// True when the day has passed the [lastCheckOut] cut-off and any
/// record without a check_out_time should be considered absent.
bool isPastLastCheckOut(
    {required DateTime now, required String lastCheckOut}) {
  final lc = parseTimeOfDay(lastCheckOut, now);
  return now.isAfter(lc);
}

String formatHm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String formatHms(DateTime d) =>
    '${formatHm(d)}:${d.second.toString().padLeft(2, '0')}';

String formatYmd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
String monthName(int m) => _monthNames[m];
