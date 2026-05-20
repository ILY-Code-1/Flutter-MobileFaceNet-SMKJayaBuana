import 'dart:convert';
import 'dart:typed_data';

class AdminAccount {
  final int id;
  final String username;
  final String pinHash;
  final DateTime createdAt;

  const AdminAccount({
    required this.id,
    required this.username,
    required this.pinHash,
    required this.createdAt,
  });

  factory AdminAccount.fromRow(Map<String, Object?> row) => AdminAccount(
        id: row['id'] as int,
        username: row['username'] as String,
        pinHash: row['pin_hash'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

class SchoolClass {
  final int id;
  final String name;
  final DateTime createdAt;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory SchoolClass.fromRow(Map<String, Object?> row) => SchoolClass(
        id: row['id'] as int,
        name: row['name'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
}

class Student {
  final int id;
  final String name;
  final String nis;
  final int classId;
  final String? className;
  final String? photoPath;
  final List<double>? embedding;
  final bool isDraft;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.name,
    required this.nis,
    required this.classId,
    this.className,
    this.photoPath,
    this.embedding,
    required this.isDraft,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  int get hue {
    int h = 0;
    for (final code in name.codeUnits) {
      h = (h * 31 + code) & 0x7fffffff;
    }
    return h % 360;
  }

  factory Student.fromRow(Map<String, Object?> row) {
    List<double>? emb;
    final raw = row['embedding'];
    if (raw is Uint8List && raw.isNotEmpty) {
      emb = _bytesToVector(raw);
    } else if (raw is List<int> && raw.isNotEmpty) {
      emb = _bytesToVector(Uint8List.fromList(raw));
    }
    return Student(
      id: row['id'] as int,
      name: row['name'] as String,
      nis: row['nis'] as String,
      classId: row['class_id'] as int,
      className: row['class_name'] as String?,
      photoPath: row['photo_path'] as String?,
      embedding: emb,
      isDraft: (row['is_draft'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}

Uint8List vectorToBytes(List<double> v) {
  final bytes = Float32List.fromList(v);
  return bytes.buffer.asUint8List();
}

List<double> _bytesToVector(Uint8List bytes) {
  // SQLite returns BLOBs as a Uint8List whose offsetInBytes is not necessarily
  // a multiple of 4. Float32List.view() rejects unaligned offsets, so we copy
  // into a fresh buffer that starts at offset 0 before reinterpreting.
  final aligned = Uint8List.fromList(bytes);
  final f = Float32List.view(aligned.buffer, 0, aligned.lengthInBytes ~/ 4);
  return List<double>.from(f);
}

enum AttendanceStatus { present, late, absent }

extension AttendanceStatusX on AttendanceStatus {
  String get code {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.absent:
        return 'absent';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Hadir';
      case AttendanceStatus.late:
        return 'Terlambat';
      case AttendanceStatus.absent:
        return 'Absen';
    }
  }

  static AttendanceStatus fromCode(String code) {
    switch (code) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class AttendanceRecord {
  final int id;
  final int studentId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.status,
  });

  factory AttendanceRecord.fromRow(Map<String, Object?> row) =>
      AttendanceRecord(
        id: row['id'] as int,
        studentId: row['student_id'] as int,
        date: row['date'] as String,
        checkInTime: row['check_in_time'] as String?,
        checkOutTime: row['check_out_time'] as String?,
        status: AttendanceStatusX.fromCode(
            (row['status'] as String?) ?? 'absent'),
      );

  Map<String, Object?> toRow() => {
        'student_id': studentId,
        'date': date,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'status': status.code,
      };
}

class AppSettingsMap {
  final Map<String, String> _data;
  AppSettingsMap(this._data);

  String? operator [](String key) => _data[key];

  String get(String key, String fallback) => _data[key] ?? fallback;

  List<int> getIntList(String key) {
    final s = _data[key];
    if (s == null || s.isEmpty) return const [];
    return s
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  Map<String, String> asMap() => Map.unmodifiable(_data);
}

String jsonEncodeMap(Map<String, Object?> m) => jsonEncode(m);
