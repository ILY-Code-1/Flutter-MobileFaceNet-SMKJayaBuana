/// Per-student rollup of an attendance query.
class StudentSummary {
  final int studentId;
  final String name;
  final String nis;
  final String? className;
  final int present;
  final int late;
  final int absent;

  const StudentSummary({
    required this.studentId,
    required this.name,
    required this.nis,
    required this.className,
    required this.present,
    required this.late,
    required this.absent,
  });

  int get total => present + late + absent;
  int get percentage =>
      total == 0 ? 0 : (((present + late) / total) * 100).round();
}

class StudentSummaryList {
  final List<StudentSummary> rows;
  final int totalPresent;
  final int totalLate;
  final int totalAbsent;

  const StudentSummaryList({
    required this.rows,
    required this.totalPresent,
    required this.totalLate,
    required this.totalAbsent,
  });

  int get totalDays => totalPresent + totalLate + totalAbsent;
}

class ReportAggregator {
  ReportAggregator._();

  static StudentSummaryList summarize(List<Map<String, Object?>> rows) {
    final byStudent = <int, _Acc>{};
    for (final r in rows) {
      final id = r['student_id'] as int;
      final acc = byStudent.putIfAbsent(
        id,
        () => _Acc(
          name: r['student_name'] as String? ?? '—',
          nis: r['nis'] as String? ?? '—',
          className: r['class_name'] as String?,
        ),
      );
      final status = (r['status'] as String?) ?? 'absent';
      switch (status) {
        case 'present':
          acc.present++;
          break;
        case 'late':
          acc.late++;
          break;
        case 'absent':
        default:
          acc.absent++;
      }
    }
    final list = byStudent.entries
        .map((e) => StudentSummary(
              studentId: e.key,
              name: e.value.name,
              nis: e.value.nis,
              className: e.value.className,
              present: e.value.present,
              late: e.value.late,
              absent: e.value.absent,
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    int p = 0, l = 0, a = 0;
    for (final s in list) {
      p += s.present;
      l += s.late;
      a += s.absent;
    }
    return StudentSummaryList(
      rows: list,
      totalPresent: p,
      totalLate: l,
      totalAbsent: a,
    );
  }
}

class _Acc {
  final String name;
  final String nis;
  final String? className;
  int present = 0;
  int late = 0;
  int absent = 0;
  _Acc({
    required this.name,
    required this.nis,
    required this.className,
  });
}
