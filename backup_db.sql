-- ============================================================================
-- backup_db.sql  ·  Absensi SMK Jaya Buana
-- ----------------------------------------------------------------------------
-- Reference schema (v2) + dummy data for the SQLite database used by the app.
--
-- The live database is created at runtime by `lib/core/data/app_database.dart`
-- and stored in the device's application-documents directory as
-- `smk_jaya_buana.db`. This file is a human-readable replica you can load
-- straight into the sqlite3 CLI:
--
--   sqlite3 smk_jaya_buana.db < backup_db.sql
--
-- SCHEMA v2 CHANGES (refactor):
--   * `admin` no longer stores a password — only the 6-digit PIN hash.
--   * Added indexes on the hot foreign-key / date columns.
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ============================================================================
-- SCHEMA
-- ============================================================================

DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS admin;

-- One row only. Authenticated by a 6-digit PIN (sha256 hashed).
CREATE TABLE admin (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    username   TEXT NOT NULL,
    pin_hash   TEXT NOT NULL,         -- sha256(pin) hex
    created_at TEXT NOT NULL
);

-- School classes. `name` is unique; a class in use cannot be deleted.
CREATE TABLE classes (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL
);

-- Enrolled students. `embedding` is a 192 × float32 little-endian blob.
CREATE TABLE students (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL,
    nis        TEXT NOT NULL UNIQUE,
    class_id   INTEGER NOT NULL,
    photo_path TEXT,
    embedding  BLOB,
    is_draft   INTEGER NOT NULL DEFAULT 0,   -- 1 = draft (dimmed in the list)
    created_at TEXT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

-- One row per student per day. Only rows with a check_out_time are
-- considered "completed" and counted in the reports.
CREATE TABLE attendance (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id     INTEGER NOT NULL,
    date           TEXT NOT NULL,            -- YYYY-MM-DD
    check_in_time  TEXT,                     -- HH:mm:ss
    check_out_time TEXT,                     -- HH:mm:ss
    status         TEXT NOT NULL,            -- 'present' | 'late' | 'absent'
    UNIQUE (student_id, date),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- Generic key/value bag for terminal configuration.
CREATE TABLE settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Indexes for the hot lookups (class filter, daily attendance, reports).
CREATE INDEX idx_students_class    ON students(class_id);
CREATE INDEX idx_attendance_student ON attendance(student_id);
CREATE INDEX idx_attendance_date    ON attendance(date);

-- ============================================================================
-- DUMMY DATA
-- ============================================================================

-- Admin — default PIN "135790" (sha256). No password is stored anymore.
INSERT INTO admin (id, username, pin_hash, created_at) VALUES
    (1, 'admin_smk',
        '8d969eef6ecad3c29a3a629280e686c31ca91ba6e15f6f1f6e0b6a3d4f3f9a7f',
        '2026-05-20T08:00:00');
-- NOTE: the hash above is illustrative. The app always re-hashes whatever PIN
-- the admin enters on the registration screen, so this row is only a
-- placeholder for documentation — register inside the app to set a real PIN.

INSERT INTO classes (id, name, created_at) VALUES
    (1, 'X · RPL · A',     '2026-05-20T08:00:01'),
    (2, 'X · TKR · A',     '2026-05-20T08:00:02'),
    (3, 'XI · RPL · A',    '2026-05-20T08:00:03'),
    (4, 'XI · MM · A',     '2026-05-20T08:00:04'),
    (5, 'XII · AKL · B',   '2026-05-20T08:00:05'),
    (6, 'XII · Animation', '2026-05-20T08:00:06');

INSERT INTO students (id, name, nis, class_id, photo_path, embedding, is_draft, created_at) VALUES
    (1,  'Andini Pratiwi',   '2401001', 3, NULL, NULL, 0, '2026-05-20T08:01:00'),
    (2,  'Bagus Setiawan',   '2401002', 3, NULL, NULL, 0, '2026-05-20T08:01:01'),
    (3,  'Chika Maharani',   '2401003', 3, NULL, NULL, 0, '2026-05-20T08:01:02'),
    (4,  'Dimas Kurniawan',  '2401004', 3, NULL, NULL, 0, '2026-05-20T08:01:03'),
    (5,  'Elsa Wijayanti',   '2401005', 3, NULL, NULL, 0, '2026-05-20T08:01:04'),
    (6,  'Fariz Ramadhan',   '2401006', 3, NULL, NULL, 0, '2026-05-20T08:01:05'),
    (7,  'Gita Lestari',     '2401007', 4, NULL, NULL, 0, '2026-05-20T08:01:06'),
    (8,  'Haikal Pranoto',   '2401008', 4, NULL, NULL, 0, '2026-05-20T08:01:07'),
    (9,  'Indira Salsabila', '2401009', 1, NULL, NULL, 0, '2026-05-20T08:01:08'),
    (10, 'Joko Anwari',      '2401010', 1, NULL, NULL, 0, '2026-05-20T08:01:09'),
    (11, 'Kirana Putri',     '2401011', 2, NULL, NULL, 0, '2026-05-20T08:01:10'),
    (12, 'Luthfi Saputra',   '2401012', 5, NULL, NULL, 0, '2026-05-20T08:01:11');

-- Completed attendance for three sample weekdays. The real seeder
-- (lib/core/data/seed.dart) fills every weekday of the current month so the
-- Reports screen always has data; the rows below are a representative slice.
INSERT INTO attendance (student_id, date, check_in_time, check_out_time, status) VALUES
    (1, '2026-05-18', '07:00:00', '15:35:00', 'present'),
    (2, '2026-05-18', '07:02:00', '15:35:00', 'present'),
    (3, '2026-05-18', '07:04:00', '15:35:00', 'present'),
    (5, '2026-05-18', '07:08:00', '15:35:00', 'present'),
    (6, '2026-05-18', '07:42:00', '15:35:00', 'late'),
    (7, '2026-05-18', '07:01:00', '15:35:00', 'present'),
    (8, '2026-05-18', '07:06:00', '15:35:00', 'present'),

    (1, '2026-05-19', '07:00:00', '15:35:00', 'present'),
    (2, '2026-05-19', '07:02:00', '15:35:00', 'present'),
    (3, '2026-05-19', '07:04:00', '15:35:00', 'present'),
    (4, '2026-05-19', '07:05:00', '15:35:00', 'present'),
    (5, '2026-05-19', '07:08:00', '15:35:00', 'present'),
    (6, '2026-05-19', '07:43:00', '15:35:00', 'late'),
    (7, '2026-05-19', '07:01:00', '15:35:00', 'present'),
    (8, '2026-05-19', '07:06:00', '15:35:00', 'present'),

    (1, '2026-05-20', '07:00:00', '15:35:00', 'present'),
    (2, '2026-05-20', '07:02:00', '15:35:00', 'present'),
    (3, '2026-05-20', '07:04:00', '15:35:00', 'present'),
    (4, '2026-05-20', '07:05:00', '15:35:00', 'present'),
    (5, '2026-05-20', '07:08:00', '15:35:00', 'present'),
    (6, '2026-05-20', '07:42:00', '15:35:00', 'late'),
    (7, '2026-05-20', '07:01:00', '15:35:00', 'present'),
    (8, '2026-05-20', '07:06:00', '15:35:00', 'present');

INSERT INTO settings (key, value) VALUES
    ('active_class_ids',    '1,2,3,4,5,6'),
    ('clock_in_time',       '07:00'),
    ('clock_out_time',      '15:30'),
    ('last_check_out_time', '18:00'),
    ('device_name',         'Terminal 1 · Lab Building'),
    ('sound_on_scan',       'soft_chime');

-- ============================================================================
-- Notes
-- ----------------------------------------------------------------------------
-- 1. `students.embedding` is a 192-element little-endian float32 array
--    (768 bytes). The dummy rows leave it NULL because binary data is awkward
--    in plain SQL; the app fills it via the "Process embed" enrolment action.
--
-- 2. Only completed rows (check_out_time IS NOT NULL) are aggregated into the
--    Reports screen and the exported PDF.
--
-- 3. The `last_check_out_time` setting (default 18:00) is the cut-off after
--    which a student who never checked out is treated as absent for the day.
--
-- 4. Status rule on check-in: scanned before clock-in + 1 hour -> present,
--    later -> late.
-- ============================================================================
