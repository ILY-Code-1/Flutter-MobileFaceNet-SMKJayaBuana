import 'package:flutter/material.dart';

import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../services/report_aggregator.dart';

class StudentDetailDialog extends StatelessWidget {
  final StudentSummary student;
  final String scopeLabel;
  final List<Map<String, Object?>> rows;
  const StudentDetailDialog({
    super.key,
    required this.student,
    required this.scopeLabel,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Dialog(
      backgroundColor: c.bgElev,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                '${student.nis} · ${student.className ?? '—'} · $scopeLabel',
                style: TextStyle(
                    color: c.textMute,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.x14),
              Wrap(
                spacing: AppSpacing.x6,
                runSpacing: AppSpacing.x6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Pill(label: 'Hadir', value: student.present, color: c.success),
                  _Pill(label: 'Terlambat', value: student.late, color: c.warn),
                  _Pill(label: 'Absen', value: student.absent, color: c.danger),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.bgSubtle,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('${student.percentage}%',
                        style: TextStyle(
                            color: c.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x14),
              Divider(color: c.border, height: 1),
              Expanded(
                child: rows.isEmpty
                    ? Center(
                        child: Text('No records in this scope.',
                            style:
                                TextStyle(color: c.textMute, fontSize: 13)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: rows.length,
                        separatorBuilder: (_, _) =>
                            Divider(color: c.border, height: 1),
                        itemBuilder: (_, i) {
                          final r = rows[i];
                          final status = AttendanceStatusX.fromCode(
                              (r['status'] as String?) ?? 'absent');
                          final color = status == AttendanceStatus.present
                              ? c.success
                              : status == AttendanceStatus.late
                                  ? c.warn
                                  : c.danger;
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(r['date'] as String? ?? '—',
                                style: TextStyle(
                                    color: c.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13)),
                            subtitle: Text(
                              'In: ${r['check_in_time'] ?? '—'} · Out: ${r['check_out_time'] ?? '—'}',
                              style: TextStyle(
                                  color: c.textMute,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(status.label,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900)),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.x10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close',
                      style: TextStyle(
                          color: c.primary, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Pill({
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text('$label $value',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
