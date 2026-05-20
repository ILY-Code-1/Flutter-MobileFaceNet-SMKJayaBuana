import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_card.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../services/report_aggregator.dart';
import '../services/report_pdf.dart';
import '../widgets/student_detail_dialog.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<SchoolClass> _classes = [];
  int? _classFilterId;
  int? _yearFilter;
  int? _monthFilter;
  int? _dayFilter;

  bool _loading = true;
  bool _exporting = false;
  StudentSummaryList? _summary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _yearFilter = now.year;
    _monthFilter = now.month;
    _load();
  }

  String? get _datePrefix {
    if (_yearFilter == null) return null;
    final y = _yearFilter!.toString().padLeft(4, '0');
    if (_monthFilter == null) return y;
    final m = _monthFilter!.toString().padLeft(2, '0');
    if (_dayFilter == null) return '$y-$m';
    final d = _dayFilter!.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final classes = await AppDatabase.instance.listClasses();
    final rows = await AppDatabase.instance.queryAttendance(
      datePrefix: _datePrefix,
      classId: _classFilterId,
    );
    final summary = ReportAggregator.summarize(rows);
    if (!mounted) return;
    setState(() {
      _classes = classes;
      _summary = summary;
      _loading = false;
    });
  }

  String get _classFilterLabel {
    if (_classFilterId == null) return AppStrings.filterAllClasses;
    return _classes
        .firstWhere(
          (c) => c.id == _classFilterId,
          orElse: () =>
              SchoolClass(id: 0, name: '—', createdAt: DateTime.now()),
        )
        .name;
  }

  String _filterScopeLabel() {
    if (_yearFilter == null) return 'All time';
    if (_monthFilter == null) return '$_yearFilter';
    final monthName =
        DateFormat('MMMM').format(DateTime(_yearFilter!, _monthFilter!));
    if (_dayFilter == null) return '$monthName $_yearFilter';
    return '$_dayFilter $monthName $_yearFilter';
  }

  Future<void> _pickFilters() async {
    final c = context.jb;
    int? localYear = _yearFilter;
    int? localMonth = _monthFilter;
    int? localDay = _dayFilter;
    int? localClass = _classFilterId;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.bgElev,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateModal) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter reports',
                        style: TextStyle(
                            color: c.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: AppSpacing.x14),
                    _SectionLabel(label: 'Class', color: c.accent),
                    const SizedBox(height: AppSpacing.x8),
                    Wrap(
                      spacing: AppSpacing.x8,
                      runSpacing: AppSpacing.x8,
                      children: [
                        _Chip(
                          label: AppStrings.filterAllClasses,
                          selected: localClass == null,
                          onTap: () =>
                              setStateModal(() => localClass = null),
                        ),
                        for (final cls in _classes)
                          _Chip(
                            label: cls.name,
                            selected: localClass == cls.id,
                            onTap: () =>
                                setStateModal(() => localClass = cls.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x18),
                    _SectionLabel(label: 'Year', color: c.accent),
                    const SizedBox(height: AppSpacing.x8),
                    Wrap(
                      spacing: AppSpacing.x8,
                      runSpacing: AppSpacing.x8,
                      children: [
                        for (final y in _yearOptions())
                          _Chip(
                            label: '$y',
                            selected: localYear == y,
                            onTap: () => setStateModal(() => localYear = y),
                          ),
                        _Chip(
                          label: 'Any',
                          selected: localYear == null,
                          onTap: () => setStateModal(() {
                            localYear = null;
                            localMonth = null;
                            localDay = null;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x18),
                    _SectionLabel(label: 'Month', color: c.accent),
                    const SizedBox(height: AppSpacing.x8),
                    Wrap(
                      spacing: AppSpacing.x8,
                      runSpacing: AppSpacing.x8,
                      children: [
                        _Chip(
                          label: 'Any',
                          selected: localMonth == null,
                          onTap: () => setStateModal(() {
                            localMonth = null;
                            localDay = null;
                          }),
                        ),
                        for (int m = 1; m <= 12; m++)
                          _Chip(
                            label: DateFormat('MMM')
                                .format(DateTime(2025, m)),
                            selected: localMonth == m,
                            onTap: localYear == null
                                ? () {}
                                : () =>
                                    setStateModal(() => localMonth = m),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x18),
                    _SectionLabel(label: 'Day', color: c.accent),
                    const SizedBox(height: AppSpacing.x8),
                    Wrap(
                      spacing: AppSpacing.x6,
                      runSpacing: AppSpacing.x6,
                      children: [
                        _Chip(
                          label: 'Any',
                          selected: localDay == null,
                          onTap: () =>
                              setStateModal(() => localDay = null),
                        ),
                        for (int d = 1;
                            d <= _daysInMonth(localYear, localMonth);
                            d++)
                          _Chip(
                            label: '$d',
                            selected: localDay == d,
                            onTap: localMonth == null
                                ? () {}
                                : () => setStateModal(() => localDay = d),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x18),
                    JbButton(
                      label: 'Apply filters',
                      leading: const JbIcon(JbIcon.check, size: 18),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _yearFilter = localYear;
                          _monthFilter = localMonth;
                          _dayFilter = localDay;
                          _classFilterId = localClass;
                        });
                        _load();
                      },
                    ),
                    const SizedBox(height: AppSpacing.x10),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  List<int> _yearOptions() {
    final now = DateTime.now().year;
    return [now - 1, now, now + 1];
  }

  int _daysInMonth(int? y, int? m) {
    if (y == null || m == null) return 31;
    return DateTime(y, m + 1, 0).day;
  }

  Future<void> _exportPdf() async {
    if (_summary == null) return;
    setState(() => _exporting = true);
    try {
      await ReportPdf.exportAndShare(
        title:
            'Attendance · ${_classFilterLabel.toUpperCase()} · ${_filterScopeLabel()}',
        summary: _summary!,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _openDetail(StudentSummary s) async {
    final rows = await AppDatabase.instance.queryAttendance(
      datePrefix: _datePrefix,
      classId: _classFilterId,
    );
    final detail =
        rows.where((r) => r['student_id'] == s.studentId).toList();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => StudentDetailDialog(
        student: s,
        scopeLabel: _filterScopeLabel(),
        rows: detail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: JbIcon(JbIcon.chevronLeft, color: c.text),
        ),
        title: const Text(AppStrings.reports),
        actions: [
          IconButton(
            onPressed: _pickFilters,
            icon: JbIcon(JbIcon.filter, color: c.text),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.accent))
          : Column(
              children: [
                Expanded(
                  child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x18, AppSpacing.x10, AppSpacing.x18,
                  AppSpacing.x18),
              children: [
                Row(
                  children: [
                    Text(_classFilterLabel.toUpperCase(),
                        style: TextStyle(
                            color: c.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4)),
                  ],
                ),
                const SizedBox(height: AppSpacing.x6),
                Row(
                  children: [
                    Expanded(
                      child: Text(AppStrings.attendance,
                          style: TextStyle(
                              color: c.text,
                              fontSize: 28,
                              fontWeight: FontWeight.w900)),
                    ),
                    _ScopePill(
                        label: _filterScopeLabel(), onTap: _pickFilters),
                  ],
                ),
                const SizedBox(height: AppSpacing.x14),
                _RecapRow(summary: _summary!),
                const SizedBox(height: AppSpacing.x18),
                JbCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.x14,
                            vertical: AppSpacing.x10),
                        decoration: BoxDecoration(
                          color: c.bgSubtle,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.lg)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 4,
                                child: Text(AppStrings.colStudent,
                                    style: _headStyle(c))),
                            Expanded(
                                child: Text(AppStrings.colP,
                                    textAlign: TextAlign.center,
                                    style: _headStyle(c))),
                            Expanded(
                                child: Text(AppStrings.colL,
                                    textAlign: TextAlign.center,
                                    style: _headStyle(c))),
                            Expanded(
                                child: Text(AppStrings.colA,
                                    textAlign: TextAlign.center,
                                    style: _headStyle(c))),
                            Expanded(
                                flex: 2,
                                child: Text(AppStrings.colPct,
                                    textAlign: TextAlign.right,
                                    style: _headStyle(c))),
                          ],
                        ),
                      ),
                      if (_summary!.rows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.x22),
                          child: Text(
                            'No completed attendance found for this filter.',
                            style: TextStyle(
                                color: c.textMute,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        for (final row in _summary!.rows)
                          InkWell(
                            onTap: () => _openDetail(row),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.x14,
                                  vertical: AppSpacing.x12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: c.border, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(row.name,
                                        style: TextStyle(
                                            color: c.text,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14)),
                                  ),
                                  Expanded(
                                      child: Text('${row.present}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: c.success,
                                              fontWeight:
                                                  FontWeight.w800))),
                                  Expanded(
                                      child: Text('${row.late}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: c.warn,
                                              fontWeight:
                                                  FontWeight.w800))),
                                  Expanded(
                                      child: Text('${row.absent}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: c.danger,
                                              fontWeight:
                                                  FontWeight.w800))),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: c.success
                                              .withValues(alpha: 0.13),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          '${row.percentage}%',
                                          style: TextStyle(
                                              color: c.success,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                  ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.x18, 0,
                        AppSpacing.x18, AppSpacing.x14),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.x14),
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.exportLabel,
                                    style: TextStyle(
                                        color: c.onPrimary
                                            .withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.4)),
                                const SizedBox(height: 2),
                                Text(
                                  '${_filterScopeLabel()} · ${_summary?.rows.length ?? 0} students',
                                  style: TextStyle(
                                      color: c.onPrimary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: c.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              onTap: _exporting ? null : _exportPdf,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.x14,
                                    vertical: AppSpacing.x10),
                                child: Row(
                                  children: [
                                    if (_exporting)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF0B1A35)),
                                      )
                                    else
                                      JbIcon(JbIcon.download,
                                          size: 16, color: c.onAccent),
                                    const SizedBox(width: AppSpacing.x8),
                                    Text(AppStrings.exportPdf,
                                        style: TextStyle(
                                            color: c.onAccent,
                                            fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  TextStyle _headStyle(JbColors c) => TextStyle(
        color: c.textMute,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Material(
      color: selected ? c.primary : c.bgSubtle,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
          child: Text(label,
              style: TextStyle(
                  color: selected ? c.onPrimary : c.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ScopePill({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x12, vertical: AppSpacing.x8),
        decoration: BoxDecoration(
          color: c.bgElev,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JbIcon(JbIcon.calendar, size: 14, color: c.accent),
            const SizedBox(width: AppSpacing.x6),
            Text(label,
                style: TextStyle(
                    color: c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: AppSpacing.x4),
            JbIcon(JbIcon.chevronDown, size: 12, color: c.textMute),
          ],
        ),
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final StudentSummaryList summary;
  const _RecapRow({required this.summary});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final pct = summary.totalDays == 0
        ? 0
        : (((summary.totalPresent + summary.totalLate) /
                    summary.totalDays) *
                100)
            .round();
    return Row(
      children: [
        Expanded(
            child: _RecapCard(
                label: AppStrings.present,
                value: summary.totalPresent,
                accentColor: c.success,
                badge: '$pct%')),
        const SizedBox(width: AppSpacing.x10),
        Expanded(
            child: _RecapCard(
                label: AppStrings.late,
                value: summary.totalLate,
                accentColor: c.warn,
                badge: summary.totalDays == 0
                    ? '0%'
                    : '${(summary.totalLate / summary.totalDays * 100).round()}%')),
        const SizedBox(width: AppSpacing.x10),
        Expanded(
            child: _RecapCard(
                label: AppStrings.absent,
                value: summary.totalAbsent,
                accentColor: c.danger,
                badge: summary.totalDays == 0
                    ? '0%'
                    : '${(summary.totalAbsent / summary.totalDays * 100).round()}%')),
      ],
    );
  }
}

class _RecapCard extends StatelessWidget {
  final String label;
  final int value;
  final Color accentColor;
  final String badge;
  const _RecapCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.badge,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return JbCard(
      padding: const EdgeInsets.all(AppSpacing.x12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: c.textMute,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2)),
          const SizedBox(height: AppSpacing.x6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$value',
                  style: TextStyle(
                      color: c.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: AppSpacing.x6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(badge,
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
