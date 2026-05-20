import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/app_settings.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/jb_avatar.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';

/// Arguments: {
///   'studentId': int,
///   'similarity': double,
///   'capturedPath': String? (optional path to the scan image to show)
/// }
class RecognizedDialogPage extends StatefulWidget {
  const RecognizedDialogPage({super.key});

  @override
  State<RecognizedDialogPage> createState() => _RecognizedDialogPageState();
}

class _RecognizedDialogPageState extends State<RecognizedDialogPage> {
  Student? _student;
  AppSettings? _settings;
  AttendanceRecord? _today;
  double _similarity = 0;
  String? _capturedPath;
  int _remaining = 10;
  Timer? _ticker;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    final id = args?['studentId'] as int?;
    _similarity = (args?['similarity'] as double?) ?? 0;
    _capturedPath = args?['capturedPath'] as String?;
    if (id == null) {
      Navigator.pop(context);
      return;
    }
    final student = await AppDatabase.instance.getStudent(id);
    final settings = await SettingsService.instance.load();
    final today =
        await AppDatabase.instance.getTodayAttendance(id, DateTime.now());
    if (!mounted) return;
    setState(() {
      _student = student;
      _settings = settings;
      _today = today;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        _ticker?.cancel();
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  bool get _canClockIn => _today == null || _today!.checkInTime == null;

  bool get _canClockOut {
    final t = _today;
    if (t == null || t.checkInTime == null) return false;
    if (t.checkOutTime != null) return false;
    return canCheckOut(now: DateTime.now(), clockOut: _settings!.clockOut);
  }

  bool get _allDone {
    final t = _today;
    return t != null && t.checkInTime != null && t.checkOutTime != null;
  }

  Future<void> _doClockIn() async {
    if (_busy || _settings == null || _student == null) return;
    setState(() => _busy = true);
    _ticker?.cancel();
    final now = DateTime.now();
    final status = statusForCheckIn(now: now, clockIn: _settings!.clockIn);
    await AppDatabase.instance.upsertCheckIn(
      studentId: _student!.id,
      now: now,
      status: status,
    );
    await _cleanupCaptureFile();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.success,
      arguments: {
        'studentId': _student!.id,
        'action': 'in',
        'time': now.toIso8601String(),
        'status': status.code,
      },
    );
  }

  Future<void> _doClockOut() async {
    if (_busy || _settings == null || _student == null) return;
    if (!canCheckOut(now: DateTime.now(), clockOut: _settings!.clockOut)) {
      _toast(AppStrings.tooEarlyClockOut);
      return;
    }
    setState(() => _busy = true);
    _ticker?.cancel();
    final now = DateTime.now();
    await AppDatabase.instance
        .updateCheckOut(studentId: _student!.id, now: now);
    await _cleanupCaptureFile();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.success,
      arguments: {
        'studentId': _student!.id,
        'action': 'out',
        'time': now.toIso8601String(),
      },
    );
  }

  Future<void> _cleanupCaptureFile() async {
    final p = _capturedPath;
    if (p == null) return;
    try {
      await File(p).delete();
    } catch (_) {}
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final s = _student;
    final settings = _settings;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1426),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1426),
                  Color(0xFF0D1830),
                  Color(0xFF11203D),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: _ScannedShot(path: _capturedPath),
                ),
              ),
            ),
          ),
          if (s == null || settings == null)
            const Center(
                child: CircularProgressIndicator(color: Colors.white))
          else
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x18),
                      padding: const EdgeInsets.all(AppSpacing.x18),
                      decoration: BoxDecoration(
                        color: c.bgElev,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: c.border, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          _RecognizedBadge(
                              confidence:
                                  (_similarity * 100).clamp(0, 100).round()),
                          const SizedBox(height: AppSpacing.x14),
                          Row(
                            children: [
                              _PhotoOrAvatar(student: s),
                              const SizedBox(width: AppSpacing.x12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name,
                                        style: TextStyle(
                                            color: c.text,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.className ?? '—'} · NIS ${s.nis}',
                                      style: TextStyle(
                                          color: c.textMute,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    _TodayLine(today: _today),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.x14),
                          if (_allDone)
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.x14),
                              decoration: BoxDecoration(
                                color: c.bgSubtle,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: c.success),
                                  const SizedBox(width: AppSpacing.x8),
                                  Expanded(
                                    child: Text(
                                      AppStrings.alreadyDoneToday,
                                      style: TextStyle(
                                          color: c.text,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            Text(AppStrings.recognizedPrompt,
                                style: TextStyle(
                                    color: c.textMute,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: AppSpacing.x12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionBigButton(
                                    enabled: _canClockIn && !_busy,
                                    primary: true,
                                    title: AppStrings.clockInBig,
                                    subtitle: AppStrings.clockInSub,
                                    icon: JbIcon.chevronRight,
                                    onTap: _doClockIn,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x10),
                                Expanded(
                                  child: _ActionBigButton(
                                    enabled: _canClockOut && !_busy,
                                    primary: false,
                                    title: AppStrings.clockOutBig,
                                    subtitle: AppStrings.clockOutSub,
                                    icon: JbIcon.chevronLeft,
                                    onTap: _doClockOut,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.x12),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppStrings.tapToDismiss,
                                    style: TextStyle(
                                        color: c.text,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12),
                                  ),
                                  TextSpan(
                                    text:
                                        '${AppStrings.autoCancels}${_remaining}s',
                                    style: TextStyle(
                                        color: c.textMute,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The still photo captured during the scan, shown framed in the camera area.
class _ScannedShot extends StatelessWidget {
  final String? path;
  const _ScannedShot({required this.path});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF5DD49A);
    final hasImage = path != null && File(path!).existsSync();
    return Container(
      width: 190,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: hasImage
            ? Image.file(File(path!), fit: BoxFit.cover)
            : Container(color: const Color(0xFF11203D)),
      ),
    );
  }
}

class _RecognizedBadge extends StatelessWidget {
  final int confidence;
  const _RecognizedBadge({required this.confidence});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
      decoration: BoxDecoration(
        color: c.success.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: c.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.x8),
          Text('${AppStrings.faceRecognized} · $confidence% CONFIDENCE',
              style: TextStyle(
                  color: c.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _PhotoOrAvatar extends StatelessWidget {
  final Student student;
  const _PhotoOrAvatar({required this.student});
  @override
  Widget build(BuildContext context) {
    final p = student.photoPath;
    if (p != null && File(p).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(File(p), width: 64, height: 64, fit: BoxFit.cover),
      );
    }
    return JbAvatar(
      initials: student.initials,
      hue: student.hue,
      size: 64,
      fontSize: 22,
    );
  }
}

class _TodayLine extends StatelessWidget {
  final AttendanceRecord? today;
  const _TodayLine({required this.today});
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    String text;
    if (today == null || today!.checkInTime == null) {
      text = 'Belum check-in hari ini.';
    } else if (today!.checkOutTime == null) {
      final inTime = _shorten(today!.checkInTime!);
      text = 'Sudah check-in pukul $inTime · belum check-out.';
    } else {
      final inTime = _shorten(today!.checkInTime!);
      final outTime = _shorten(today!.checkOutTime!);
      text = 'Check-in $inTime · Check-out $outTime';
    }
    return Text(text,
        style: TextStyle(
            color: c.textMute, fontSize: 12, fontWeight: FontWeight.w700));
  }

  String _shorten(String hhmmss) {
    final parts = hhmmss.split(':');
    if (parts.length < 2) return hhmmss;
    return '${parts[0]}:${parts[1]}';
  }
}

class _ActionBigButton extends StatelessWidget {
  final bool enabled;
  final bool primary;
  final String title;
  final String subtitle;
  final String icon;
  final VoidCallback onTap;
  const _ActionBigButton({
    required this.enabled,
    required this.primary,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    final bg = enabled
        ? (primary ? c.primary : c.bgSubtle)
        : c.bgSubtle.withValues(alpha: 0.5);
    final fg =
        enabled ? (primary ? c.onPrimary : c.text) : c.textFaint;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x14),
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              JbIcon(icon, size: 18, color: fg),
              const SizedBox(height: AppSpacing.x4),
              Text(title,
                  style: TextStyle(
                      color: fg, fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: fg.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
