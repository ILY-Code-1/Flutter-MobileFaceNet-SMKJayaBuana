import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/jb_icons.dart';
import '../../../../routing/app_router.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  static const Duration _autoReturn = Duration(seconds: 5);
  late final AnimationController _controller;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _autoReturn)..forward();
    _navTimer = Timer(_autoReturn, () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.camera);
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = MockData.students[2]; // Chika Maharani
    final firstName = student.name.split(' ').first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F3A2E),
        body: Stack(
          children: [
            const Positioned.fill(child: _SuccessBackground()),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _AvatarWithRings(student: student),
                  const SizedBox(height: AppSpacing.x18),
                  Text(
                    AppStrings.clockedInSuccess,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x10),
                  _WelcomeLine(firstName: firstName),
                  const SizedBox(height: AppSpacing.x22),
                  const _ArrivalStatusCard(),
                  const SizedBox(height: AppSpacing.x22),
                  _SuccessSubtext(),
                  const Spacer(flex: 3),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, _) => SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (_controller.value * 1000).round(),
                        child: Container(color: AppColors.darkPrimary),
                      ),
                      Expanded(
                        flex: (1000 - _controller.value * 1000).round(),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBackground extends StatelessWidget {
  const _SuccessBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            Color(0xFF1F6B52),
            Color(0xFF0F3A2E),
            Color(0xFF071F1A),
          ],
        ),
      ),
      child: CustomPaint(painter: _ParticlePainter()),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(7);
    final p = Paint();
    for (int i = 0; i < 30; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 2.2 + 1.0;
      final alpha = rand.nextDouble() * 0.4 + 0.15;
      p.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}

class _AvatarWithRings extends StatelessWidget {
  final MockStudent student;
  const _AvatarWithRings({required this.student});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _Ring(diameter: 200, color: AppColors.darkPrimary.withValues(alpha: 0.18)),
          _Ring(diameter: 160, color: AppColors.darkPrimary.withValues(alpha: 0.4), dashed: true),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7AC9A8), Color(0xFF3D8C72)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  student.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                right: -6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.darkSuccess,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF0F3A2E), width: 3),
                  ),
                  alignment: Alignment.center,
                  child: const JbIcon(JbIcon.check,
                      size: 16, color: Color(0xFF0F3A2E)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double diameter;
  final Color color;
  final bool dashed;

  const _Ring({
    required this.diameter,
    required this.color,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(painter: _RingPainter(color: color, dashed: dashed)),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final bool dashed;

  _RingPainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final r = size.width / 2;
    final centre = Offset(r, r);
    if (!dashed) {
      canvas.drawCircle(centre, r - 1, p);
      return;
    }
    const segments = 64;
    for (int i = 0; i < segments; i += 2) {
      final a1 = (i / segments) * 2 * math.pi;
      final a2 = ((i + 1) / segments) * 2 * math.pi;
      final p1 = Offset(centre.dx + (r - 1) * math.cos(a1),
          centre.dy + (r - 1) * math.sin(a1));
      final p2 = Offset(centre.dx + (r - 1) * math.cos(a2),
          centre.dy + (r - 1) * math.sin(a2));
      canvas.drawLine(p1, p2, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.dashed != dashed;
}

class _WelcomeLine extends StatelessWidget {
  final String firstName;
  const _WelcomeLine({required this.firstName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.welcomeName,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          firstName,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: AppColors.darkPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 6),
        const JbIcon(JbIcon.sparkle, size: 22, color: AppColors.darkPrimary),
      ],
    );
  }
}

class _ArrivalStatusCard extends StatelessWidget {
  const _ArrivalStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x28),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x22, vertical: AppSpacing.x14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.arrival,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '07:14',
                      style: AppTypography.mono(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'AM',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: Colors.white.withValues(alpha: 0.12),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x14),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.status,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.darkSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      AppStrings.onTime,
                      style: TextStyle(
                        color: AppColors.darkSuccess,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessSubtext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x28),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: AppStrings.successSub,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const TextSpan(
              text: AppStrings.successCountdown,
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
