import 'dart:math' as math;

import 'app_database.dart';
import 'app_settings.dart';
import 'models.dart';

/// One-shot seeder used on first launch (after the admin registers) or via
/// the dev menu.  Populates dummy classes, students (with dummy embeddings),
/// and a couple of historic attendance days so the rest of the app has
/// something to show.
class DbSeeder {
  DbSeeder._();

  static const List<String> dummyClassNames = [
    'X · RPL · A',
    'X · TKR · A',
    'XI · RPL · A',
    'XI · MM · A',
    'XII · AKL · B',
    'XII · Animation',
  ];

  static const List<Map<String, dynamic>> dummyStudents = [
    {'name': 'Andini Pratiwi', 'nis': '2401001', 'class': 'XI · RPL · A'},
    {'name': 'Bagus Setiawan', 'nis': '2401002', 'class': 'XI · RPL · A'},
    {'name': 'Chika Maharani', 'nis': '2401003', 'class': 'XI · RPL · A'},
    {'name': 'Dimas Kurniawan', 'nis': '2401004', 'class': 'XI · RPL · A'},
    {'name': 'Elsa Wijayanti', 'nis': '2401005', 'class': 'XI · RPL · A'},
    {'name': 'Fariz Ramadhan', 'nis': '2401006', 'class': 'XI · RPL · A'},
    {'name': 'Gita Lestari', 'nis': '2401007', 'class': 'XI · MM · A'},
    {'name': 'Haikal Pranoto', 'nis': '2401008', 'class': 'XI · MM · A'},
    {'name': 'Indira Salsabila', 'nis': '2401009', 'class': 'X · RPL · A'},
    {'name': 'Joko Anwari', 'nis': '2401010', 'class': 'X · RPL · A'},
    {'name': 'Kirana Putri', 'nis': '2401011', 'class': 'X · TKR · A'},
    {'name': 'Luthfi Saputra', 'nis': '2401012', 'class': 'XII · AKL · B'},
  ];

  static Future<bool> hasAnyData() async {
    final classes = await AppDatabase.instance.listClasses();
    return classes.isNotEmpty;
  }

  /// Seeds default classes + students + a tiny attendance history.  Safe to
  /// call repeatedly — it only seeds if the DB is empty.
  static Future<void> seedIfEmpty() async {
    if (await hasAnyData()) return;
    await seedForce();
  }

  static Future<void> seedForce() async {
    final db = AppDatabase.instance;

    // ----- classes -----
    final classIds = <String, int>{};
    for (final name in dummyClassNames) {
      classIds[name] = await db.insertClass(name);
    }

    // ----- students -----
    final random = math.Random(42);
    final studentIds = <String, int>{};
    for (final s in dummyStudents) {
      final cid = classIds[s['class']]!;
      final emb = _randomNormalizedVector(192, random);
      final id = await db.insertStudent(
        name: s['name'] as String,
        nis: s['nis'] as String,
        classId: cid,
        embedding: emb,
        isDraft: false,
      );
      studentIds[s['nis'] as String] = id;
    }

    // ----- attendance: last 5 weekdays for the first 7 students -----
    final today = DateTime.now();
    int dayOffset = 1;
    int filled = 0;
    while (filled < 5 && dayOffset < 12) {
      final day = today.subtract(Duration(days: dayOffset));
      if (day.weekday >= DateTime.saturday) {
        dayOffset++;
        continue;
      }
      int idx = 0;
      for (final s in dummyStudents.take(7)) {
        final sid = studentIds[s['nis'] as String]!;
        idx++;
        if (idx == 4 && filled == 0) continue; // someone absent
        final lateMin = idx == 6 ? 42 : 0;
        final checkIn = DateTime(day.year, day.month, day.day, 7, lateMin);
        final checkOut = DateTime(day.year, day.month, day.day, 15, 35);
        await db.upsertCheckIn(
          studentId: sid,
          now: checkIn,
          status: lateMin >= 60
              ? AttendanceStatus.late
              : (lateMin > 0
                  ? AttendanceStatus.late
                  : AttendanceStatus.present),
        );
        await db.updateCheckOut(studentId: sid, now: checkOut);
      }
      filled++;
      dayOffset++;
    }

    // ----- settings: enable all classes by default -----
    final current = await SettingsService.instance.load();
    final newSettings = current.copyWith(
      activeClassIds: classIds.values.toList(),
    );
    await SettingsService.instance.save(newSettings);
  }

  static List<double> _randomNormalizedVector(int n, math.Random r) {
    final v = List<double>.generate(n, (_) => r.nextDouble() * 2 - 1);
    double sum = 0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = math.sqrt(sum);
    return [for (final x in v) x / norm];
  }
}
