import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Single source-of-truth wrapper around the SQLite database.
///
/// Schema (v3):
///   admin       — at most 1 row, stores the hashed admin PIN
///   classes     — list of school classes (name unique)
///   students    — enrolled students with face embedding (BLOB)
///   attendance  — per-student per-day check-in / check-out record, plus
///                 an `auto_checkout` flag (INTEGER NOT NULL DEFAULT 0)
///                 that audits rows whose `check_out_time` was filled by
///                 [AttendanceFinalizerService] instead of a real scan
///   settings    — generic key/value bag for active classes, school hours…
///
/// Migration history:
///   v2 dropped the unused `password_hash` column from `admin` and added
///   indexes on the hot foreign-key / date columns.
///   v3 added the `auto_checkout` column on `attendance` via a
///   non-destructive `ALTER TABLE` so existing v2 installs keep their
///   data; the migration ladder only rebuilds from scratch for pre-v2
///   (dev-stage) installs.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  static const _kDbName = 'smk_jaya_buana.db';
  static const _kDbVersion = 3;

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _kDbName);
    return openDatabase(
      path,
      version: _kDbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Pre-v2 (dev-stage) installs: rebuild from scratch.
          await _dropSchema(db);
          await _createSchema(db);
          return;
        }
        if (oldVersion < 3) {
          // v2 -> v3: add the auto_checkout flag without losing data.
          await db.execute(
            'ALTER TABLE attendance ADD COLUMN auto_checkout '
            'INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<void> _dropSchema(Database db) async {
    final batch = db.batch();
    for (final t in ['attendance', 'students', 'classes', 'settings', 'admin']) {
      batch.execute('DROP TABLE IF EXISTS $t');
    }
    await batch.commit(noResult: true);
  }

  Future<void> _createSchema(Database db) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE admin (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        username   TEXT NOT NULL,
        pin_hash   TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
    batch.execute('''
      CREATE TABLE classes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      );
    ''');
    batch.execute('''
      CREATE TABLE students (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL,
        nis        TEXT NOT NULL UNIQUE,
        class_id   INTEGER NOT NULL,
        photo_path TEXT,
        embedding  BLOB,
        is_draft   INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (class_id) REFERENCES classes(id)
      );
    ''');
    batch.execute('''
      CREATE TABLE attendance (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id     INTEGER NOT NULL,
        date           TEXT NOT NULL,
        check_in_time  TEXT,
        check_out_time TEXT,
        status         TEXT NOT NULL,
        auto_checkout  INTEGER NOT NULL DEFAULT 0,
        UNIQUE (student_id, date),
        FOREIGN KEY (student_id) REFERENCES students(id)
      );
    ''');
    batch.execute('''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    // Indexes for the hot lookups (class filter, daily attendance, reports).
    batch.execute('CREATE INDEX idx_students_class ON students(class_id);');
    batch.execute(
        'CREATE INDEX idx_attendance_student ON attendance(student_id);');
    batch.execute('CREATE INDEX idx_attendance_date ON attendance(date);');
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ---------------- Admin ----------------

  static String hashSecret(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  Future<bool> hasAdmin() async {
    final d = await db;
    final rows = await d.rawQuery('SELECT COUNT(*) AS c FROM admin');
    return ((rows.first['c'] as int?) ?? 0) > 0;
  }

  Future<AdminAccount?> getAdmin() async {
    final d = await db;
    final rows = await d.query('admin', limit: 1);
    if (rows.isEmpty) return null;
    return AdminAccount.fromRow(rows.first);
  }

  /// Creates (or replaces) the single admin account. Only the PIN is stored.
  Future<void> createAdmin({
    required String username,
    required String pin,
  }) async {
    final d = await db;
    await d.delete('admin');
    await d.insert('admin', {
      'username': username,
      'pin_hash': hashSecret(pin),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> verifyPin(String pin) async {
    final admin = await getAdmin();
    if (admin == null) return false;
    return admin.pinHash == hashSecret(pin);
  }

  // ---------------- Classes ----------------

  Future<List<SchoolClass>> listClasses() async {
    final d = await db;
    final rows = await d.query('classes', orderBy: 'name ASC');
    return rows.map(SchoolClass.fromRow).toList();
  }

  Future<int> insertClass(String name) async {
    final d = await db;
    return d.insert('classes', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateClass(int id, String name) async {
    final d = await db;
    await d.update('classes', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> deleteClass(int id) async {
    final d = await db;
    final inUse = await d.rawQuery(
        'SELECT COUNT(*) AS c FROM students WHERE class_id = ?', [id]);
    final used = ((inUse.first['c'] as int?) ?? 0) > 0;
    if (used) return false;
    await d.delete('classes', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<Map<int, int>> studentCountByClass() async {
    final d = await db;
    final rows = await d.rawQuery(
        'SELECT class_id, COUNT(*) AS c FROM students WHERE is_draft = 0 GROUP BY class_id');
    return {
      for (final r in rows) r['class_id'] as int: r['c'] as int,
    };
  }

  // ---------------- Students ----------------

  Future<List<Student>> listStudents({
    int? classId,
    String? query,
    List<int>? inClassIds,
    bool includeDrafts = true,
  }) async {
    final d = await db;
    final where = <String>[];
    final args = <Object?>[];
    if (classId != null) {
      where.add('s.class_id = ?');
      args.add(classId);
    }
    if (inClassIds != null) {
      if (inClassIds.isEmpty) return const [];
      where.add(
          's.class_id IN (${List.filled(inClassIds.length, '?').join(',')})');
      args.addAll(inClassIds);
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('(LOWER(s.name) LIKE ? OR LOWER(s.nis) LIKE ?)');
      final q = '%${query.trim().toLowerCase()}%';
      args
        ..add(q)
        ..add(q);
    }
    if (!includeDrafts) {
      where.add('s.is_draft = 0');
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final rows = await d.rawQuery('''
      SELECT s.*, c.name AS class_name
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      $whereClause
      ORDER BY s.name COLLATE NOCASE ASC
    ''', args);
    return rows.map(Student.fromRow).toList();
  }

  Future<Student?> getStudent(int id) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT s.*, c.name AS class_name
      FROM students s LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.id = ? LIMIT 1
    ''', [id]);
    if (rows.isEmpty) return null;
    return Student.fromRow(rows.first);
  }

  Future<int> insertStudent({
    required String name,
    required String nis,
    required int classId,
    String? photoPath,
    List<double>? embedding,
    required bool isDraft,
  }) async {
    final d = await db;
    return d.insert('students', {
      'name': name,
      'nis': nis,
      'class_id': classId,
      'photo_path': photoPath,
      'embedding': embedding == null ? null : vectorToBytes(embedding),
      'is_draft': isDraft ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateStudent({
    required int id,
    required String name,
    required String nis,
    required int classId,
    String? photoPath,
    List<double>? embedding,
    required bool isDraft,
  }) async {
    final d = await db;
    final values = <String, Object?>{
      'name': name,
      'nis': nis,
      'class_id': classId,
      'is_draft': isDraft ? 1 : 0,
    };
    if (photoPath != null) values['photo_path'] = photoPath;
    if (embedding != null) values['embedding'] = vectorToBytes(embedding);
    await d.update('students', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStudent(int id) async {
    final d = await db;
    await d.delete('attendance', where: 'student_id = ?', whereArgs: [id]);
    await d.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- Attendance ----------------

  Future<AttendanceRecord?> getTodayAttendance(
      int studentId, DateTime day) async {
    final d = await db;
    final iso = _ymd(day);
    final rows = await d.query('attendance',
        where: 'student_id = ? AND date = ?', whereArgs: [studentId, iso]);
    if (rows.isEmpty) return null;
    return AttendanceRecord.fromRow(rows.first);
  }

  Future<int> upsertCheckIn({
    required int studentId,
    required DateTime now,
    required AttendanceStatus status,
  }) async {
    final d = await db;
    final iso = _ymd(now);
    final time = _hms(now);
    final existing = await d.query('attendance',
        where: 'student_id = ? AND date = ?', whereArgs: [studentId, iso]);
    if (existing.isEmpty) {
      return d.insert('attendance', {
        'student_id': studentId,
        'date': iso,
        'check_in_time': time,
        'check_out_time': null,
        'status': status.code,
      });
    } else {
      final id = existing.first['id'] as int;
      await d.update(
          'attendance',
          {
            'check_in_time': time,
            'status': status.code,
          },
          where: 'id = ?',
          whereArgs: [id]);
      return id;
    }
  }

  Future<void> updateCheckOut({
    required int studentId,
    required DateTime now,
  }) async {
    final d = await db;
    final iso = _ymd(now);
    final time = _hms(now);
    final existing = await d.query('attendance',
        where: 'student_id = ? AND date = ?', whereArgs: [studentId, iso]);
    if (existing.isEmpty) return;
    final id = existing.first['id'] as int;
    await d.update('attendance', {'check_out_time': time},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Inserts an "absent" placeholder for a student on a given day.
  /// Idempotent: relies on the UNIQUE(student_id, date) constraint to skip
  /// rows that already exist for that pair.
  Future<int> insertAbsentRecord({
    required int studentId,
    required DateTime day,
  }) async {
    final d = await db;
    final iso = _ymd(day);
    return d.insert(
      'attendance',
      {
        'student_id': studentId,
        'date': iso,
        'check_in_time': null,
        'check_out_time': null,
        'status': AttendanceStatus.absent.code,
        'auto_checkout': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Fills `check_out_time` on a student/day row that has a check-in but
  /// never received a manual check-out, and flips `auto_checkout` to 1.
  /// Idempotent: the WHERE clause makes this a no-op once the row is
  /// already finalized (either manually or by a previous run).
  Future<int> autoFinalizeCheckout({
    required int studentId,
    required DateTime day,
    required String time,
  }) async {
    final d = await db;
    final iso = _ymd(day);
    return d.update(
      'attendance',
      {'check_out_time': time, 'auto_checkout': 1},
      where:
          'student_id = ? AND date = ? AND check_in_time IS NOT NULL AND check_out_time IS NULL',
      whereArgs: [studentId, iso],
    );
  }

  /// Returns attendance rows joined with student/class info, filtered by an
  /// optional date prefix (e.g. "2026", "2026-05", "2026-05-19").
  ///
  /// Defaults to `onlyCompleted: false` so that absent rows (no check-in)
  /// and rows finalized by the auto-checkout routine both reach the report
  /// pipeline. Set it to `true` only for legacy "complete attendance only"
  /// views.
  Future<List<Map<String, Object?>>> queryAttendance({
    String? datePrefix,
    int? classId,
    bool onlyCompleted = false,
  }) async {
    final d = await db;
    final where = <String>[];
    final args = <Object?>[];
    if (datePrefix != null && datePrefix.isNotEmpty) {
      where.add('a.date LIKE ?');
      args.add('$datePrefix%');
    }
    if (classId != null) {
      where.add('s.class_id = ?');
      args.add(classId);
    }
    if (onlyCompleted) {
      where.add('a.check_out_time IS NOT NULL');
    }
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    return d.rawQuery('''
      SELECT a.*, s.name AS student_name, s.nis AS nis,
             s.class_id AS class_id, c.name AS class_name
      FROM attendance a
      JOIN students s ON s.id = a.student_id
      LEFT JOIN classes c ON c.id = s.class_id
      $whereClause
      ORDER BY a.date DESC, s.name COLLATE NOCASE ASC
    ''', args);
  }

  // ---------------- Settings ----------------

  Future<AppSettingsMap> loadSettings() async {
    final d = await db;
    final rows = await d.query('settings');
    return AppSettingsMap({
      for (final r in rows) r['key'] as String: r['value'] as String,
    });
  }

  Future<void> setSetting(String key, String value) async {
    final d = await db;
    await d.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> setSettings(Map<String, String> values) async {
    final d = await db;
    final batch = d.batch();
    values.forEach((k, v) {
      batch.insert('settings', {'key': k, 'value': v},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  // ---------------- Helpers ----------------

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _hms(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

  /// Wipe all rows. Used by the seeder & "reset device" actions.
  Future<void> wipe() async {
    final d = await db;
    await d.transaction((tx) async {
      await tx.delete('attendance');
      await tx.delete('students');
      await tx.delete('classes');
      await tx.delete('settings');
      await tx.delete('admin');
    });
  }

  // ---------------- Backup ----------------

  /// Produces a portable plain-SQL dump (schema + data) of the whole
  /// database. The result can be saved as a `.sql` file and replayed
  /// against an empty SQLite database to restore the install — used by the
  /// "Contact developer" backup flow.
  Future<String> exportSqlDump() async {
    final d = await db;
    final out = StringBuffer()
      ..writeln('-- SQLite backup · Absensi SMK Jaya Buana')
      ..writeln('-- Generated at ${DateTime.now().toIso8601String()}')
      ..writeln('PRAGMA foreign_keys=OFF;')
      ..writeln('BEGIN TRANSACTION;');

    final tables = await d.rawQuery(
      "SELECT name, sql FROM sqlite_master "
      "WHERE type='table' AND name NOT LIKE 'sqlite_%' "
      "AND name <> 'android_metadata' ORDER BY name",
    );
    for (final t in tables) {
      final table = t['name'] as String;
      final createSql = t['sql'] as String?;
      out
        ..writeln()
        ..writeln('DROP TABLE IF EXISTS $table;');
      if (createSql != null) out.writeln('$createSql;');
      final rows = await d.query(table);
      for (final row in rows) {
        final cols = row.keys.toList();
        final vals = cols.map((c) => _sqlLiteral(row[c])).join(', ');
        out.writeln(
            'INSERT INTO $table (${cols.join(', ')}) VALUES ($vals);');
      }
    }

    final indexes = await d.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL",
    );
    if (indexes.isNotEmpty) out.writeln();
    for (final idx in indexes) {
      out.writeln('${idx['sql']};');
    }

    out
      ..writeln()
      ..writeln('COMMIT;');
    return out.toString();
  }

  /// Renders a single column value as a SQL literal for [exportSqlDump].
  static String _sqlLiteral(Object? value) {
    if (value == null) return 'NULL';
    if (value is int || value is double) return '$value';
    if (value is Uint8List) {
      return "X'${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}'";
    }
    if (value is List<int>) {
      return "X'${value.map((b) => (b & 0xff).toRadixString(16).padLeft(2, '0')).join()}'";
    }
    return "'${value.toString().replaceAll("'", "''")}'";
  }
}
