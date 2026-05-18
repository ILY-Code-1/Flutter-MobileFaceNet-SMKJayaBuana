import 'package:flutter/material.dart';

enum StudentStatus { present, late, absent }

class MockStudent {
  final String name;
  final String nis;
  final int hue;
  final String lastSeen;
  final StudentStatus status;
  final String initials;

  const MockStudent({
    required this.name,
    required this.nis,
    required this.hue,
    required this.lastSeen,
    required this.status,
    required this.initials,
  });
}

class MockReportRow {
  final String name;
  final int present;
  final int late;
  final int absent;
  final int percent;

  const MockReportRow({
    required this.name,
    required this.present,
    required this.late,
    required this.absent,
    required this.percent,
  });
}

class MockData {
  MockData._();

  static const List<MockStudent> students = [
    MockStudent(
      name: 'Andini Pratiwi',
      nis: '24·RPL·A·01',
      hue: 18,
      lastSeen: '07:02',
      status: StudentStatus.present,
      initials: 'AP',
    ),
    MockStudent(
      name: 'Bagus Setiawan',
      nis: '24·RPL·A·02',
      hue: 42,
      lastSeen: '07:08',
      status: StudentStatus.present,
      initials: 'BS',
    ),
    MockStudent(
      name: 'Chika Maharani',
      nis: '24·RPL·A·03',
      hue: 145,
      lastSeen: '07:11',
      status: StudentStatus.present,
      initials: 'CM',
    ),
    MockStudent(
      name: 'Dimas Kurniawan',
      nis: '24·RPL·A·04',
      hue: 205,
      lastSeen: '—',
      status: StudentStatus.absent,
      initials: 'DK',
    ),
    MockStudent(
      name: 'Elsa Wijayanti',
      nis: '24·RPL·A·05',
      hue: 175,
      lastSeen: '07:14',
      status: StudentStatus.present,
      initials: 'EW',
    ),
    MockStudent(
      name: 'Fariz Ramadhan',
      nis: '24·RPL·A·06',
      hue: 295,
      lastSeen: '07:42',
      status: StudentStatus.late,
      initials: 'FR',
    ),
    MockStudent(
      name: 'Gita Lestari',
      nis: '24·RPL·A·07',
      hue: 28,
      lastSeen: '07:01',
      status: StudentStatus.present,
      initials: 'GL',
    ),
    MockStudent(
      name: 'Haikal Pranoto',
      nis: '24·RPL·A·08',
      hue: 220,
      lastSeen: '07:05',
      status: StudentStatus.present,
      initials: 'HP',
    ),
    MockStudent(
      name: 'Indira Salsabila',
      nis: '24·RPL·A·09',
      hue: 320,
      lastSeen: '07:18',
      status: StudentStatus.present,
      initials: 'IS',
    ),
    MockStudent(
      name: 'Joko Anwari',
      nis: '24·RPL·A·10',
      hue: 95,
      lastSeen: '—',
      status: StudentStatus.absent,
      initials: 'JA',
    ),
  ];

  static const List<MockReportRow> reportRows = [
    MockReportRow(name: 'Andini Pratiwi', present: 19, late: 1, absent: 0, percent: 95),
    MockReportRow(name: 'Bagus Setiawan', present: 18, late: 2, absent: 0, percent: 90),
    MockReportRow(name: 'Chika Maharani', present: 20, late: 0, absent: 0, percent: 100),
    MockReportRow(name: 'Dimas Kurniawan', present: 14, late: 1, absent: 5, percent: 70),
    MockReportRow(name: 'Elsa Wijayanti', present: 19, late: 0, absent: 1, percent: 95),
    MockReportRow(name: 'Fariz Ramadhan', present: 16, late: 4, absent: 0, percent: 80),
    MockReportRow(name: 'Gita Lestari', present: 20, late: 0, absent: 0, percent: 100),
  ];

  static const int totalPresent = 562;
  static const int totalLate = 24;
  static const int totalAbsent = 14;
  static const int totalAttendancePct = 94;
  static const int totalEnrolled = 142;
  static const int totalFacesInClass = 32;
  static const int checkedInToday = 26;
}

/// Quick OKLCH-ish gradient pair derived from a hue value.
/// Approximates `linear-gradient(oklch(0.78 0.06 H) → oklch(0.62 0.08 H+30))`
/// without a colour-space dependency.
class HueGradient {
  static List<Color> fromHue(int hue) {
    final c1 = HSLColor.fromAHSL(1.0, hue.toDouble() % 360, 0.42, 0.74).toColor();
    final c2 = HSLColor.fromAHSL(1.0, (hue + 30).toDouble() % 360, 0.46, 0.58).toColor();
    return [c1, c2];
  }
}
