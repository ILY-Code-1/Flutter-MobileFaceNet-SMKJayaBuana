import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/constants/app_strings.dart';
import 'report_aggregator.dart';

class ReportPdf {
  ReportPdf._();

  static const _navy = PdfColor.fromInt(0xFF0F2545);
  static const _gold = PdfColor.fromInt(0xFFC8A431);
  static const _green = PdfColor.fromInt(0xFF1F7A4A);
  static const _orange = PdfColor.fromInt(0xFFB8732C);
  static const _red = PdfColor.fromInt(0xFFB0344A);
  static const _muted = PdfColor.fromInt(0xFF5A6584);
  static const _line = PdfColor.fromInt(0xFFE6DFCB);
  static const _headBg = PdfColor.fromInt(0xFFF2EDE0);
  static const _ink = PdfColor.fromInt(0xFF0B1A35);

  /// Build the PDF and open the platform share / print dialog.
  ///
  /// Layout:
  ///  - Page 1 (may spill to more pages): recap + summary table per student.
  ///  - One fresh page per student: detailed daily check-in / check-out list.
  static Future<void> exportAndShare({
    required String title,
    required StudentSummaryList summary,
    required List<Map<String, Object?>> rows,
  }) async {
    final doc = pw.Document();

    // Group attendance rows per student, sorted by date ascending.
    final byStudent = <int, List<Map<String, Object?>>>{};
    for (final r in rows) {
      final id = r['student_id'] as int;
      (byStudent[id] ??= []).add(r);
    }
    for (final list in byStudent.values) {
      list.sort((a, b) =>
          (a['date'] as String? ?? '').compareTo(b['date'] as String? ?? ''));
    }

    // ---- Summary page(s) ----
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 44),
        footer: _footer,
        build: (context) => [
          _header(title, 'Attendance Report'),
          pw.SizedBox(height: 18),
          pw.Row(
            children: [
              _recap('PRESENT', summary.totalPresent, _green),
              pw.SizedBox(width: 8),
              _recap('LATE', summary.totalLate, _orange),
              pw.SizedBox(width: 8),
              _recap('ABSENT', summary.totalAbsent, _red),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Summary per Student',
            style: pw.TextStyle(
                color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
          pw.SizedBox(height: 8),
          _summaryTable(summary),
          pw.SizedBox(height: 14),
          pw.Text(
            'Only completed (checked-out) attendance is included. '
            'Per-student daily check-in / check-out details follow on the next pages.',
            style: const pw.TextStyle(color: _muted, fontSize: 9),
          ),
        ],
      ),
    );

    // ---- One page per student: daily detail ----
    for (final s in summary.rows) {
      final detail = byStudent[s.studentId] ?? const <Map<String, Object?>>[];
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 44),
          footer: _footer,
          build: (context) => [
            _header(title, 'Attendance Detail'),
            pw.SizedBox(height: 16),
            _studentBanner(s),
            pw.SizedBox(height: 14),
            pw.Text(
              'Daily Records',
              style: pw.TextStyle(
                  color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 8),
            if (detail.isEmpty)
              pw.Text(
                'No completed attendance records in this period.',
                style: const pw.TextStyle(color: _muted, fontSize: 10),
              )
            else
              _detailTable(detail),
          ],
        ),
      );
    }

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'attendance_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // ---------------- shared building blocks ----------------

  static pw.Widget _header(String title, String heading) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                AppStrings.schoolFullName,
                style: pw.TextStyle(
                  color: _gold,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                heading,
                style: pw.TextStyle(
                  color: _navy,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                title,
                style: const pw.TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            DateTime.now().toIso8601String().substring(0, 10),
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Absensi SMK Jaya Buana  ·  Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(color: _muted, fontSize: 8),
      ),
    );
  }

  static pw.Widget _summaryTable(StudentSummaryList summary) {
    return pw.Table(
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(color: _line),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
        5: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headBg),
          children: [
            _th('Student'),
            _th('NIS / Class'),
            _th('P', align: pw.TextAlign.center),
            _th('L', align: pw.TextAlign.center),
            _th('A', align: pw.TextAlign.center),
            _th('Attendance %', align: pw.TextAlign.right),
          ],
        ),
        for (final s in summary.rows)
          pw.TableRow(
            children: [
              _td(s.name, bold: true),
              _td('${s.nis} · ${s.className ?? '—'}'),
              _td('${s.present}',
                  color: _green, align: pw.TextAlign.center, bold: true),
              _td('${s.late}',
                  color: _orange, align: pw.TextAlign.center, bold: true),
              _td('${s.absent}',
                  color: _red, align: pw.TextAlign.center, bold: true),
              _td('${s.percentage}%',
                  align: pw.TextAlign.right, bold: true),
            ],
          ),
      ],
    );
  }

  static pw.Widget _studentBanner(StudentSummary s) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _headBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            s.name,
            style: pw.TextStyle(
                color: _navy, fontWeight: pw.FontWeight.bold, fontSize: 15),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'NIS ${s.nis}  ·  ${s.className ?? '—'}',
            style: const pw.TextStyle(color: _muted, fontSize: 10),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _chip('Present ${s.present}', _green),
              pw.SizedBox(width: 6),
              _chip('Late ${s.late}', _orange),
              pw.SizedBox(width: 6),
              _chip('Absent ${s.absent}', _red),
              pw.SizedBox(width: 6),
              _chip('Attendance ${s.percentage}%', _navy),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _chip(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _detailTable(List<Map<String, Object?>> detail) {
    return pw.Table(
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(color: _line),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.8),
        1: pw.FlexColumnWidth(2.2),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
        4: pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headBg),
          children: [
            _th('No', align: pw.TextAlign.center),
            _th('Date'),
            _th('Check-in', align: pw.TextAlign.center),
            _th('Check-out', align: pw.TextAlign.center),
            _th('Status', align: pw.TextAlign.center),
          ],
        ),
        for (int i = 0; i < detail.length; i++) _detailRow(i + 1, detail[i]),
      ],
    );
  }

  static pw.TableRow _detailRow(int no, Map<String, Object?> r) {
    final code = (r['status'] as String?) ?? 'absent';
    final color = code == 'present'
        ? _green
        : code == 'late'
            ? _orange
            : _red;
    final label = code == 'present'
        ? 'Hadir'
        : code == 'late'
            ? 'Terlambat'
            : 'Absen';
    return pw.TableRow(
      children: [
        _td('$no', align: pw.TextAlign.center),
        _td(r['date'] as String? ?? '—'),
        _td(_hm(r['check_in_time'] as String?), align: pw.TextAlign.center),
        _td(_hm(r['check_out_time'] as String?), align: pw.TextAlign.center),
        _td(label, color: color, align: pw.TextAlign.center, bold: true),
      ],
    );
  }

  /// Trim an "HH:mm:ss" string down to "HH:mm"; returns "—" when empty.
  static String _hm(String? hms) {
    if (hms == null || hms.isEmpty) return '—';
    final parts = hms.split(':');
    if (parts.length < 2) return hms;
    return '${parts[0]}:${parts[1]}';
  }

  static pw.Widget _recap(String label, int value, PdfColor accent) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _line),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 9,
                color: _muted,
                letterSpacing: 1.2,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '$value',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _th(String s, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        s,
        textAlign: align ?? pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static pw.Widget _td(String s,
      {PdfColor? color, pw.TextAlign? align, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        s,
        textAlign: align ?? pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          color: color ?? _ink,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
