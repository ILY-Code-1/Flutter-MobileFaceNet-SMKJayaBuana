import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_avatar.dart';
import '../../../../routing/app_router.dart';

/// Arguments: {
///   'studentId': int,
///   'action': 'in' | 'out',
///   'time': ISO-8601 string,
///   'status': 'present' | 'late' (optional; only for 'in'),
/// }
class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  Student? _student;
  String _action = 'in';
  DateTime? _time;
  AttendanceStatus _status = AttendanceStatus.present;
  int _remaining = 5;
  Timer? _ticker;

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
    _action = (args?['action'] as String?) ?? 'in';
    final ts = args?['time'] as String?;
    if (ts != null) _time = DateTime.tryParse(ts);
    final st = args?['status'] as String?;
    if (st != null) _status = AttendanceStatusX.fromCode(st);
    if (id != null) {
      _student = await AppDatabase.instance.getStudent(id);
    }
    if (!mounted) return;
    setState(() {});
    _startCountdown();
  }

  void _startCountdown() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        _ticker?.cancel();
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.camera, (r) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isIn = _action == 'in';
    final bgTop = isIn ? const Color(0xFF073B2F) : const Color(0xFF1F2A52);
    final bgBottom = isIn ? const Color(0xFF0C0D24) : const Color(0xFF0A1426);
    final headline =
        isIn ? AppStrings.clockedInSuccess : AppStrings.clockedOutSuccess;
    final firstName = _student?.name.split(' ').first ?? 'student';
    final timeLabel = _time == null
        ? '--:--'
        : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: bgBottom,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBottom],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_student != null)
                    _AvatarRing(student: _student!)
                  else
                    const SizedBox(width: 120, height: 120),
                  const SizedBox(height: AppSpacing.x18),
                  Text(
                    headline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE8C547),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 2,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(
                            text: isIn
                                ? AppStrings.welcomeName
                                : AppStrings.goodbyeName),
                        TextSpan(
                          text: '$firstName ',
                          style: const TextStyle(
                            color: Color(0xFFE8C547),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(text: '👋'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x22,
                        vertical: AppSpacing.x14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppSpacing.x14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIn ? AppStrings.arrival : AppStrings.departure,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.x22),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        const SizedBox(width: AppSpacing.x22),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.status,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _statusColor(_status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.x6),
                                Text(
                                  _statusLabel(_status, isIn),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x22),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x22),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: AppStrings.successSub),
                          TextSpan(
                            text: '${_remaining}s',
                            style: const TextStyle(
                              color: Color(0xFFE8C547),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return const Color(0xFF5DD49A);
      case AttendanceStatus.late:
        return const Color(0xFFE8A35C);
      case AttendanceStatus.absent:
        return const Color(0xFFE87A8E);
    }
  }

  String _statusLabel(AttendanceStatus s, bool isIn) {
    if (!isIn) return 'Checked out';
    switch (s) {
      case AttendanceStatus.present:
        return AppStrings.onTime;
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }
}

class _AvatarRing extends StatelessWidget {
  final Student student;
  const _AvatarRing({required this.student});

  @override
  Widget build(BuildContext context) {
    final photo = student.photoPath;
    Widget child;
    if (photo != null && File(photo).existsSync()) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.file(File(photo),
            width: 110, height: 110, fit: BoxFit.cover),
      );
    } else {
      child = JbAvatar(
        initials: student.initials,
        hue: student.hue,
        size: 110,
        fontSize: 36,
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE8C547).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE8C547).withValues(alpha: 0.8),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child,
        const Positioned(
          right: 28,
          bottom: 28,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF1F7A4A),
            child: Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}
