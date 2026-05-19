import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/models.dart';
import '../../../../core/services/face_recognition_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_button.dart';
import '../../../../core/widgets/jb_card.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../core/widgets/jb_text_field.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _name = TextEditingController();
  final _nis = TextEditingController();

  Student? _editing;
  List<SchoolClass> _classes = [];
  int? _classId;
  String? _photoPath;
  List<double>? _embedding;
  String? _embedNote;
  bool _processing = false;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    final id = args?['studentId'] as int?;
    final classes = await AppDatabase.instance.listClasses();
    Student? existing;
    if (id != null) {
      existing = await AppDatabase.instance.getStudent(id);
      if (existing != null) {
        _name.text = existing.name;
        _nis.text = existing.nis;
        _classId = existing.classId;
        _photoPath = existing.photoPath;
        _embedding = existing.embedding;
        if (_embedding != null) {
          _embedNote = AppStrings.embedDone;
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _classes = classes;
      _classId ??= classes.isEmpty ? null : classes.first.id;
      _editing = existing;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _nis.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.jb.bgElev,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        final c = ctx.jb;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                leading: JbIcon(JbIcon.eye, color: c.text),
                title: Text('From gallery',
                    style: TextStyle(
                        color: c.text, fontWeight: FontWeight.w800)),
              ),
              ListTile(
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
                leading: JbIcon(JbIcon.cameraFlip, color: c.text),
                title: Text('Take a photo',
                    style: TextStyle(
                        color: c.text, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: AppSpacing.x10),
            ],
          ),
        );
      },
    );
    if (src == null) return;
    final img =
        await picker.pickImage(source: src, maxWidth: 1024, imageQuality: 92);
    if (img == null) return;

    // copy to app documents so the path is stable
    final dir = await getApplicationDocumentsDirectory();
    final faces = Directory(p.join(dir.path, 'faces'));
    if (!await faces.exists()) await faces.create(recursive: true);
    final dest = p.join(faces.path,
        'student_${DateTime.now().microsecondsSinceEpoch}.jpg');
    await File(img.path).copy(dest);
    if (!mounted) return;
    setState(() {
      _photoPath = dest;
      _embedding = null; // photo changed → embedding invalid
      _embedNote = null;
    });
  }

  Future<void> _processEmbed() async {
    if (_photoPath == null) return;
    setState(() {
      _processing = true;
      _embedNote = null;
    });
    final emb =
        await FaceRecognitionService.instance.embedFromFile(_photoPath!);
    if (!mounted) return;
    setState(() {
      _processing = false;
      _embedding = emb;
      _embedNote =
          emb == null ? AppStrings.noFaceFound : AppStrings.embedDone;
    });
  }

  Future<void> _save({required bool draft}) async {
    if (_name.text.trim().isEmpty || _nis.text.trim().isEmpty) {
      _toast('Name and NIS are required.');
      return;
    }
    if (_classId == null) {
      _toast('Pick a class first.');
      return;
    }
    if (!draft && _embedding == null) {
      _toast('Process the embedding before submitting.');
      return;
    }
    setState(() => _saving = true);
    try {
      if (_editing == null) {
        await AppDatabase.instance.insertStudent(
          name: _name.text.trim(),
          nis: _nis.text.trim(),
          classId: _classId!,
          photoPath: _photoPath,
          embedding: _embedding,
          isDraft: draft,
        );
      } else {
        await AppDatabase.instance.updateStudent(
          id: _editing!.id,
          name: _name.text.trim(),
          nis: _nis.text.trim(),
          classId: _classId!,
          photoPath: _photoPath,
          embedding: _embedding,
          isDraft: draft,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _toast('Failed to save: $e');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.enrollNewFace)),
        body: Center(child: CircularProgressIndicator(color: c.accent)),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: JbIcon(JbIcon.close, color: c.text),
        ),
        title: Text(_editing == null
            ? AppStrings.enrollNewFace
            : AppStrings.editStudent),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.x18, AppSpacing.x10, AppSpacing.x18, AppSpacing.x10),
        children: [
          Text(AppStrings.stepLabel,
              style: TextStyle(
                  color: c.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4)),
          const SizedBox(height: AppSpacing.x10),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineLarge?.copyWith(
                color: c.text,
                fontSize: 26,
              ),
              children: [
                const TextSpan(text: AppStrings.captureHeadline),
                TextSpan(
                  text: AppStrings.captureHeadlineEm,
                  style: theme.textTheme.headlineLarge?.copyWith(
                      color: c.text,
                      fontStyle: FontStyle.italic,
                      fontSize: 26),
                ),
                const TextSpan(text: AppStrings.captureHeadlineTail),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
          Text(AppStrings.captureSub,
              style: TextStyle(
                  color: c.textMute, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.x18),
          _PhotoSlot(
            photoPath: _photoPath,
            onTap: _pickPhoto,
          ),
          const SizedBox(height: AppSpacing.x12),
          Row(
            children: [
              Expanded(
                child: JbButton.ghost(
                  label: _photoPath == null
                      ? AppStrings.uploadPhoto
                      : AppStrings.replacePhoto,
                  leading: const JbIcon(JbIcon.plus, size: 18),
                  onPressed: _pickPhoto,
                ),
              ),
              const SizedBox(width: AppSpacing.x10),
              Expanded(
                child: JbButton.gold(
                  label: _processing
                      ? '…processing'
                      : (_embedding == null
                          ? AppStrings.processEmbed
                          : AppStrings.reprocessEmbed),
                  leading: _processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF0B1A35)),
                        )
                      : const JbIcon(JbIcon.sparkle, size: 18),
                  onPressed: _photoPath == null || _processing
                      ? null
                      : _processEmbed,
                ),
              ),
            ],
          ),
          if (_embedNote != null) ...[
            const SizedBox(height: AppSpacing.x10),
            Row(
              children: [
                Icon(
                  _embedding == null ? Icons.error_outline : Icons.check_circle,
                  color: _embedding == null ? c.danger : c.success,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.x8),
                Text(
                  _embedNote!,
                  style: TextStyle(
                    color: _embedding == null ? c.danger : c.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.x18),
          JbTextField(
            label: AppStrings.fullName,
            hintText: 'Chika Maharani',
            leadingIcon: const JbIcon(JbIcon.user),
            controller: _name,
          ),
          const SizedBox(height: AppSpacing.x14),
          JbTextField(
            label: AppStrings.nis,
            hintText: '2401007',
            leadingIcon: const JbIcon(JbIcon.eye),
            controller: _nis,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: AppSpacing.x14),
          _ClassDropdown(
            classes: _classes,
            value: _classId,
            onChanged: (v) => setState(() => _classId = v),
          ),
          const SizedBox(height: AppSpacing.x28),
          Row(
            children: [
              Expanded(
                child: JbButton.ghost(
                  label: AppStrings.saveDraft,
                  onPressed: _saving ? null : () => _save(draft: true),
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                flex: 2,
                child: JbButton(
                  label: AppStrings.submit,
                  leading: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const JbIcon(JbIcon.check, size: 18),
                  onPressed: _saving ? null : () => _save(draft: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x18),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;
  const _PhotoSlot({required this.photoPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: JbCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: photoPath == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      JbIcon(JbIcon.faceScan, size: 36, color: c.textFaint),
                      const SizedBox(height: AppSpacing.x10),
                      Text('Tap to upload pas-foto',
                          style: TextStyle(
                              color: c.textMute,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.file(File(photoPath!), fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}

class _ClassDropdown extends StatelessWidget {
  final List<SchoolClass> classes;
  final int? value;
  final ValueChanged<int?> onChanged;
  const _ClassDropdown({
    required this.classes,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.classDropdownLabel,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: c.textMute,
                letterSpacing: 1.4)),
        const SizedBox(height: AppSpacing.x8),
        Container(
          decoration: BoxDecoration(
            color: c.bgElev,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              hint: Text('Pick a class…',
                  style: TextStyle(
                      color: c.textFaint, fontWeight: FontWeight.w700)),
              items: [
                for (final cls in classes)
                  DropdownMenuItem(
                    value: cls.id,
                    child: Text(
                      cls.name,
                      style: TextStyle(
                          color: c.text, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
