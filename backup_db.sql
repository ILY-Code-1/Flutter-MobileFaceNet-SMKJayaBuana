-- ============================================================================
-- backup_db.sql
-- ----------------------------------------------------------------------------
-- Reference schema + dummy data for the Absensi SMK Jaya Buana SQLite database.
--
-- This file is generated to make it easy for any developer to understand the
-- data model used by the app. The actual database lives in the device's
-- application documents directory under the name `smk_jaya_buana.db` and is
-- created at runtime by `lib/core/data/app_database.dart`.
--
-- You can load this file straight into the sqlite3 CLI to get a working
-- replica:
--
--   sqlite3 smk_jaya_buana.db < backup_db.sql
--
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

CREATE TABLE admin (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT NOT NULL,
    password_hash TEXT NOT NULL,    -- sha256(password) hex
    pin_hash      TEXT NOT NULL,    -- sha256(pin) hex
    created_at    TEXT NOT NULL
);

CREATE TABLE classes (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL
);

CREATE TABLE students (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    nis         TEXT NOT NULL UNIQUE,
    class_id    INTEGER NOT NULL,
    photo_path  TEXT,
    embedding   BLOB,              -- 192 × float32 little-endian = 768 bytes
    is_draft    INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

CREATE TABLE attendance (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id      INTEGER NOT NULL,
    date            TEXT NOT NULL,        -- YYYY-MM-DD
    check_in_time   TEXT,                 -- HH:mm:ss
    check_out_time  TEXT,                 -- HH:mm:ss
    status          TEXT NOT NULL,        -- 'present' | 'late' | 'absent'
    UNIQUE (student_id, date),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

CREATE TABLE settings (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- ============================================================================
-- DUMMY DATA
-- ============================================================================

-- Admin (default credentials — replace before going live).
--   Password: "admin123" → sha256
--   PIN:      "1234"     → sha256
INSERT INTO admin (id, username, password_hash, pin_hash, created_at)
VALUES (1,
        'admin_smk',
        '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
        '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
        '2026-05-19T08:00:00');

INSERT INTO classes (id, name, created_at) VALUES
    (1, 'X · RPL · A',     '2026-05-19T08:00:01'),
    (2, 'X · TKR · A',     '2026-05-19T08:00:02'),
    (3, 'XI · RPL · A',    '2026-05-19T08:00:03'),
    (4, 'XI · MM · A',     '2026-05-19T08:00:04'),
    (5, 'XII · AKL · B',   '2026-05-19T08:00:05'),
    (6, 'XII · Animation', '2026-05-19T08:00:06');

INSERT INTO students (id, name, nis, class_id, photo_path, embedding, is_draft, created_at) VALUES
    (1,  'Andini Pratiwi',   '2401001', 3, NULL, NULL, 0, '2026-05-19T08:01:00'),
    (2,  'Bagus Setiawan',   '2401002', 3, NULL, NULL, 0, '2026-05-19T08:01:01'),
    (3,  'Chika Maharani',   '2401003', 3, NULL, NULL, 0, '2026-05-19T08:01:02'),
    (4,  'Dimas Kurniawan',  '2401004', 3, NULL, NULL, 0, '2026-05-19T08:01:03'),
    (5,  'Elsa Wijayanti',   '2401005', 3, NULL, NULL, 0, '2026-05-19T08:01:04'),
    (6,  'Fariz Ramadhan',   '2401006', 3, NULL, NULL, 0, '2026-05-19T08:01:05'),
    (7,  'Gita Lestari',     '2401007', 4, NULL, NULL, 0, '2026-05-19T08:01:06'),
    (8,  'Haikal Pranoto',   '2401008', 4, NULL, NULL, 0, '2026-05-19T08:01:07'),
    (9,  'Indira Salsabila', '2401009', 1, NULL, NULL, 0, '2026-05-19T08:01:08'),
    (10, 'Joko Anwari',      '2401010', 1, NULL, NULL, 0, '2026-05-19T08:01:09'),
    (11, 'Kirana Putri',     '2401011', 2, NULL, NULL, 0, '2026-05-19T08:01:10'),
    (12, 'Luthfi Saputra',   '2401012', 5, NULL, NULL, 0, '2026-05-19T08:01:11');

-- Five sample weekdays of completed attendance for the first 7 students.
-- One absent record (Dimas on the first day) and one late record (Fariz, after 07:42).
INSERT INTO attendance (student_id, date, check_in_time, check_out_time, status) VALUES
    (1, '2026-05-12', '07:00:23', '15:35:11', 'present'),
    (2, '2026-05-12', '07:02:11', '15:35:18', 'present'),
    (3, '2026-05-12', '07:04:55', '15:35:32', 'present'),
    (5, '2026-05-12', '07:09:01', '15:36:11', 'present'),
    (6, '2026-05-12', '07:42:00', '15:35:50', 'late'),
    (7, '2026-05-12', '07:01:13', '15:35:01', 'present'),

    (1, '2026-05-13', '07:00:12', '15:34:55', 'present'),
    (2, '2026-05-13', '07:02:00', '15:35:01', 'present'),
    (3, '2026-05-13', '07:04:32', '15:35:25', 'present'),
    (4, '2026-05-13', '07:05:00', '15:35:50', 'present'),
    (5, '2026-05-13', '07:08:50', '15:36:01', 'present'),
    (6, '2026-05-13', '07:43:11', '15:35:50', 'late'),
    (7, '2026-05-13', '07:01:50', '15:35:00', 'present'),

    (1, '2026-05-14', '07:00:35', '15:35:00', 'present'),
    (2, '2026-05-14', '07:02:21', '15:35:10', 'present'),
    (3, '2026-05-14', '07:04:11', '15:35:22', 'present'),
    (4, '2026-05-14', '07:05:55', '15:35:11', 'present'),
    (5, '2026-05-14', '07:09:00', '15:36:11', 'present'),
    (6, '2026-05-14', '07:41:50', '15:35:55', 'late'),
    (7, '2026-05-14', '07:01:30', '15:35:00', 'present'),

    (1, '2026-05-15', '07:00:18', '15:35:01', 'present'),
    (2, '2026-05-15', '07:02:00', '15:35:09', 'present'),
    (3, '2026-05-15', '07:04:12', '15:35:21', 'present'),
    (4, '2026-05-15', '07:05:42', '15:35:18', 'present'),
    (5, '2026-05-15', '07:08:30', '15:36:01', 'present'),
    (6, '2026-05-15', '07:42:10', '15:35:50', 'late'),
    (7, '2026-05-15', '07:01:11', '15:35:00', 'present'),

    (1, '2026-05-16', '07:00:00', '15:35:00', 'present'),
    (2, '2026-05-16', '07:02:00', '15:35:00', 'present'),
    (3, '2026-05-16', '07:04:00', '15:35:00', 'present'),
    (4, '2026-05-16', '07:05:00', '15:35:00', 'present'),
    (5, '2026-05-16', '07:09:00', '15:35:00', 'present'),
    (6, '2026-05-16', '07:42:00', '15:35:00', 'late'),
    (7, '2026-05-16', '07:01:00', '15:35:00', 'present');

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
--    (768 bytes). The dummy rows above leave it NULL because text SQL is
--    awkward for binary; the app fills it via the enrolment screen.
--
-- 2. `attendance.status` is only "present" or "late" when check-in happened.
--    An attendance row with `check_out_time IS NULL` is not yet counted in the
--    reports — only completed records (both timestamps present) appear in the
--    aggregations, per the spec.
--
-- 3. The `last_check_out_time` setting (default 18:00) is the cut-off at which
--    incomplete rows for the day are considered absent.
--
-- ============================================================================
