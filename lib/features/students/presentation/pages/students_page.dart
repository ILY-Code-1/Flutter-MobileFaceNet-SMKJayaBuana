import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_avatar.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_text_field.dart';
import '../../../../routing/app_router.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _search = TextEditingController();
  List<SchoolClass> _classes = [];
  List<Student> _students = [];
  int? _classFilterId; // null = all
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(_reload);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final classes = await AppDatabase.instance.listClasses();
    final students = await AppDatabase.instance.listStudents(
      classId: _classFilterId,
      query: _search.text,
    );
    if (!mounted) return;
    setState(() {
      _classes = classes;
      _students = students;
      _loading = false;
    });
  }

  Future<void> _reload() async {
    final students = await AppDatabase.instance.listStudents(
      classId: _classFilterId,
      query: _search.text,
    );
    if (!mounted) return;
    setState(() => _students = students);
  }

  Future<void> _openFilter() async {
    final picked = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Theme.of(context).extension<JbColors>()!.bgElev,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        final c = ctx.jb;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter by class',
                    style: TextStyle(
                        color: c.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.x14),
                Wrap(
                  spacing: AppSpacing.x8,
                  runSpacing: AppSpacing.x8,
                  children: [
                    _FilterChip(
                      label: AppStrings.filterAllClasses,
                      selected: _classFilterId == null,
                      onTap: () => Navigator.pop(ctx, null),
                    ),
                    for (final cls in _classes)
                      _FilterChip(
                        label: cls.name,
                        selected: _classFilterId == cls.id,
                        onTap: () => Navigator.pop(ctx, cls.id),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x14),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _classFilterId = picked);
    _reload();
  }

  String get _classFilterLabel {
    if (_classFilterId == null) return AppStrings.filterAllClasses;
    final cls = _classes.firstWhere(
        (c) => c.id == _classFilterId,
        orElse: () => SchoolClass(
            id: 0, name: '—', createdAt: DateTime.now()));
    return cls.name;
  }

  Future<void> _openAddStudent({int? studentId}) async {
    final ok = await Navigator.pushNamed(
      context,
      AppRoutes.addStudent,
      arguments: {'studentId': studentId},
    );
    if (ok == true) _load();
  }

  Future<void> _deleteStudent(Student s) async {
    final c = context.jb;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.bgElev,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete student?', style: TextStyle(color: c.text)),
        content: Text(
          'This will remove ${s.name} and all of their attendance records.',
          style: TextStyle(color: c.textMute, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(AppStrings.cancel, style: TextStyle(color: c.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: c.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AppDatabase.instance.deleteStudent(s.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text(AppStrings.students),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: JbIcon(JbIcon.chevronLeft, color: c.text),
        ),
        actions: [
          IconButton(
            onPressed: _openFilter,
            icon: JbIcon(JbIcon.filter, color: c.text),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        onPressed: () => _openAddStudent(),
        icon: JbIcon(JbIcon.plus, size: 18, color: c.onPrimary),
        label: const Text(AppStrings.enrollFace,
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.accent))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x18, 0, AppSpacing.x18, AppSpacing.x8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Class · ',
                                    style: TextStyle(
                                      color: c.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _classFilterLabel.toUpperCase(),
                                    style: TextStyle(
                                      color: c.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: c.text,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                          children: [
                            TextSpan(text: '${_students.length} '),
                            const TextSpan(
                                text: AppStrings.studentsHeading,
                                style: TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x14),
                      JbTextField(
                        hintText: AppStrings.searchHint,
                        leadingIcon: const JbIcon(JbIcon.search),
                        controller: _search,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? _EmptyView(
                          message: _search.text.isEmpty
                              ? 'No students yet — tap "Enroll face" to add one.'
                              : 'No matches found.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.x18, 0, AppSpacing.x18, 80),
                          itemCount: _students.length,
                          separatorBuilder: (_, _) =>
                              Divider(color: c.border, height: 1),
                          itemBuilder: (_, i) {
                            final s = _students[i];
                            return _StudentRow(
                              student: s,
                              onTap: () => _openAddStudent(studentId: s.id),
                              onDelete: () => _deleteStudent(s),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x14, vertical: AppSpacing.x8),
          child: Text(
            label,
            style: TextStyle(
                color: selected ? c.onPrimary : c.text,
                fontWeight: FontWeight.w800,
                fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _StudentRow({
    required this.student,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final isDraft = student.isDraft;
    return Opacity(
      opacity: isDraft ? 0.5 : 1.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.x12),
          child: Row(
            children: [
              _AvatarOrPhoto(student: student),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            student.name,
                            style: TextStyle(
                              color: c.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDraft) ...[
                          const SizedBox(width: AppSpacing.x6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.warn.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text('DRAFT',
                                style: TextStyle(
                                    color: c.warn,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.nis} · ${student.className ?? '—'}',
                      style: TextStyle(
                        color: c.textMute,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: JbIcon(JbIcon.trash, size: 18, color: c.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOrPhoto extends StatelessWidget {
  final Student student;
  const _AvatarOrPhoto({required this.student});

  @override
  Widget build(BuildContext context) {
    final photo = student.photoPath;
    if (photo != null && File(photo).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(photo),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }
    return JbAvatar(
      initials: student.initials,
      hue: student.hue,
      size: 44,
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            JbIcon(JbIcon.student, size: 40, color: c.textFaint),
            const SizedBox(height: AppSpacing.x12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: c.textMute,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
