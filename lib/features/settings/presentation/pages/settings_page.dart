import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/data/models.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_card.dart';
import '../../../../core/widgets/jb_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<SchoolClass> _classes = [];
  Map<int, int> _studentCountByClass = {};
  AppSettings? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final classes = await AppDatabase.instance.listClasses();
    final counts = await AppDatabase.instance.studentCountByClass();
    final settings = await SettingsService.instance.load();
    final detected = await DeviceInfoService.instance.readDeviceName();
    AppSettings effective = settings;
    if (settings.deviceName == AppSettings.defaults['device_name']) {
      effective = settings.copyWith(deviceName: detected);
      await SettingsService.instance.save(effective);
    }
    if (!mounted) return;
    setState(() {
      _classes = classes;
      _studentCountByClass = counts;
      _settings = effective;
      _loading = false;
    });
  }

  Future<void> _toggleClass(SchoolClass cls) async {
    final s = _settings!;
    final ids = List<int>.from(s.activeClassIds);
    if (ids.contains(cls.id)) {
      ids.remove(cls.id);
    } else {
      ids.add(cls.id);
    }
    final updated = s.copyWith(activeClassIds: ids);
    await SettingsService.instance.save(updated);
    setState(() => _settings = updated);
  }

  Future<void> _addClass() async {
    final name = await _promptClassName(context, '');
    if (name == null || name.trim().isEmpty) return;
    try {
      await AppDatabase.instance.insertClass(name.trim());
    } catch (e) {
      _toast('Failed: $e (class name must be unique)');
      return;
    }
    await _load();
  }

  Future<void> _editClass(SchoolClass cls) async {
    final name =
        await _promptClassName(context, cls.name, title: AppStrings.editClass);
    if (name == null || name.trim().isEmpty || name.trim() == cls.name) return;
    try {
      await AppDatabase.instance.updateClass(cls.id, name.trim());
    } catch (e) {
      _toast('Failed: $e');
      return;
    }
    await _load();
  }

  Future<void> _deleteClass(SchoolClass cls) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.jb;
        return AlertDialog(
          backgroundColor: c.bgElev,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(AppStrings.deleteClass, style: TextStyle(color: c.text)),
          content: Text(
            'Delete "${cls.name}"? This only works if no student uses this class.',
            style: TextStyle(color: c.textMute, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel,
                  style: TextStyle(color: c.textMute)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete', style: TextStyle(color: c.danger)),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    final deleted = await AppDatabase.instance.deleteClass(cls.id);
    if (!deleted) {
      _toast('Cannot delete: class is in use by students.');
      return;
    }
    final s = _settings!;
    if (s.activeClassIds.contains(cls.id)) {
      final updated = s.copyWith(
          activeClassIds:
              s.activeClassIds.where((id) => id != cls.id).toList());
      await SettingsService.instance.save(updated);
    }
    await _load();
  }

  Future<String?> _promptClassName(BuildContext ctx, String initial,
      {String title = AppStrings.addClass}) async {
    final controller = TextEditingController(text: initial);
    final c = ctx.jb;
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: c.bgElev,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(title, style: TextStyle(color: c.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.classNameHint,
                style:
                    TextStyle(color: c.textMute, fontSize: 13, height: 1.4)),
            const SizedBox(height: AppSpacing.x12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'XII · RPL · B',
                hintStyle: TextStyle(color: c.textFaint),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(AppStrings.cancel, style: TextStyle(color: c.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Save',
                style:
                    TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickClockTime(String label, String current,
      void Function(String hhmm) onPicked) async {
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 7,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
      helpText: label,
    );
    if (picked == null) return;
    final h = picked.hour.toString().padLeft(2, '0');
    final m = picked.minute.toString().padLeft(2, '0');
    onPicked('$h:$m');
  }

  Future<void> _saveSettings(AppSettings s) async {
    await SettingsService.instance.save(s);
    setState(() => _settings = s);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    if (_loading || _settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.settings)),
        body: Center(child: CircularProgressIndicator(color: c.accent)),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: JbIcon(JbIcon.chevronLeft, color: c.text),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x18, 0, AppSpacing.x18, AppSpacing.x28),
        children: [
          _SectionLabel(label: AppStrings.sectionClasses),
          const SizedBox(height: AppSpacing.x8),
          Text(AppStrings.sectionClassesQ,
              style: TextStyle(
                  color: c.text, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.x6),
          Text(AppStrings.sectionClassesHint,
              style: TextStyle(
                  color: c.textMute,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.x14),
          _ClassGrid(
            classes: _classes,
            studentCounts: _studentCountByClass,
            activeIds: _settings!.activeClassIds.toSet(),
            onTap: _toggleClass,
            onEdit: _editClass,
            onDelete: _deleteClass,
          ),
          const SizedBox(height: AppSpacing.x12),
          JbButton.ghost(
            label: AppStrings.addClass,
            leading: const JbIcon(JbIcon.plus, size: 18),
            onPressed: _addClass,
          ),
          const SizedBox(height: AppSpacing.x28),
          _SectionLabel(label: AppStrings.sectionSchedule),
          const SizedBox(height: AppSpacing.x8),
          Text(AppStrings.schoolHours,
              style: TextStyle(
                  color: c.text, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.x14),
          JbCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TimeTile(
                        label: AppStrings.clockIn,
                        value: _settings!.clockIn,
                        onTap: () => _pickClockTime(
                            AppStrings.clockIn,
                            _settings!.clockIn,
                            (v) => _saveSettings(
                                _settings!.copyWith(clockIn: v))),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x12),
                    Expanded(
                      child: _TimeTile(
                        label: AppStrings.clockOut,
                        value: _settings!.clockOut,
                        onTap: () => _pickClockTime(
                            AppStrings.clockOut,
                            _settings!.clockOut,
                            (v) => _saveSettings(
                                _settings!.copyWith(clockOut: v))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x12),
                _TimeTile(
                  label: AppStrings.lastCheckOut,
                  value: _settings!.lastCheckOut,
                  onTap: () => _pickClockTime(
                      AppStrings.lastCheckOut,
                      _settings!.lastCheckOut,
                      (v) =>
                          _saveSettings(_settings!.copyWith(lastCheckOut: v))),
                ),
                const SizedBox(height: AppSpacing.x12),
                Text(AppStrings.schoolHoursHint,
                    style: TextStyle(
                        color: c.textMute,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x28),
          _SectionLabel(label: AppStrings.sectionDevice),
          const SizedBox(height: AppSpacing.x14),
          JbCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _KeyValueRow(
                  k: AppStrings.deviceName,
                  v: _settings!.deviceName,
                  onTap: () async {
                    final v = await _promptText(context,
                        _settings!.deviceName, AppStrings.deviceName);
                    if (v == null) return;
                    _saveSettings(_settings!.copyWith(deviceName: v));
                  },
                ),
                Divider(color: c.border, height: 1),
                _KeyValueRow(
                  k: AppStrings.soundOnScan,
                  v: kSoundOptions[_settings!.soundOnScan] ?? 'Soft chime',
                  onTap: () async {
                    final v =
                        await _pickSound(context, _settings!.soundOnScan);
                    if (v == null) return;
                    _saveSettings(_settings!.copyWith(soundOnScan: v));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptText(
      BuildContext ctx, String initial, String title) async {
    final controller = TextEditingController(text: initial);
    final c = ctx.jb;
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: c.bgElev,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(title, style: TextStyle(color: c.text)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(AppStrings.cancel, style: TextStyle(color: c.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Save',
                style:
                    TextStyle(color: c.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<String?> _pickSound(BuildContext ctx, String current) async {
    final c = ctx.jb;
    return showDialog<String>(
      context: ctx,
      builder: (_) => SimpleDialog(
        backgroundColor: c.bgElev,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(AppStrings.soundOnScan, style: TextStyle(color: c.text)),
        children: [
          for (final e in kSoundOptions.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Row(
                children: [
                  Icon(
                    e.key == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: e.key == current ? c.primary : c.textMute,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.x10),
                  Text(e.value,
                      style: TextStyle(
                          color: c.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Text(
      label,
      style: TextStyle(
          color: c.accent,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
          fontSize: 12),
    );
  }
}

class _ClassGrid extends StatelessWidget {
  final List<SchoolClass> classes;
  final Map<int, int> studentCounts;
  final Set<int> activeIds;
  final void Function(SchoolClass) onTap;
  final void Function(SchoolClass) onEdit;
  final void Function(SchoolClass) onDelete;
  const _ClassGrid({
    required this.classes,
    required this.studentCounts,
    required this.activeIds,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    if (classes.isEmpty) {
      return JbCard(
        child: Text(
          'No classes yet. Add the first one below.',
          style: TextStyle(color: c.textMute, height: 1.4),
        ),
      );
    }
    final cardWidth = (MediaQuery.of(context).size.width -
            AppSpacing.x18 * 2 -
            AppSpacing.x12) /
        2;
    return Wrap(
      spacing: AppSpacing.x12,
      runSpacing: AppSpacing.x12,
      children: [
        for (final cls in classes)
          SizedBox(
            width: cardWidth,
            child: _ClassCard(
              cls: cls,
              active: activeIds.contains(cls.id),
              studentCount: studentCounts[cls.id] ?? 0,
              onTap: () => onTap(cls),
              onEdit: () => onEdit(cls),
              onDelete: () => onDelete(cls),
            ),
          ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final SchoolClass cls;
  final bool active;
  final int studentCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ClassCard({
    required this.cls,
    required this.active,
    required this.studentCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final bg = active ? c.primary : c.bgElev;
    final fg = active ? c.onPrimary : c.text;
    final muted =
        active ? c.onPrimary.withValues(alpha: 0.7) : c.textMute;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: active ? Colors.transparent : c.border,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cls.name,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (active)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: JbIcon(JbIcon.check,
                          size: 14, color: c.onAccent),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.x8),
              Text(
                '$studentCount student${studentCount == 1 ? '' : 's'}',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.x10),
              Row(
                children: [
                  _MicroButton(
                    icon: JbIcon.eye,
                    label: 'Edit',
                    color: muted,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: AppSpacing.x8),
                  _MicroButton(
                    icon: JbIcon.trash,
                    label: 'Delete',
                    color: muted,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MicroButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.x6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JbIcon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.x14),
        decoration: BoxDecoration(
          color: c.bgSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: c.border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: c.textMute,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4)),
            const SizedBox(height: AppSpacing.x6),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        color: c.text,
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: AppSpacing.x6),
                JbIcon(JbIcon.chevronDown, size: 14, color: c.textMute),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String k;
  final String v;
  final VoidCallback? onTap;
  const _KeyValueRow({
    required this.k,
    required this.v,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.x14, horizontal: AppSpacing.x14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(k,
                  style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
            Expanded(
              flex: 3,
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: c.textMute,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: AppSpacing.x6),
            JbIcon(JbIcon.chevronRight, size: 14, color: c.textMute),
          ],
        ),
      ),
    );
  }
}
