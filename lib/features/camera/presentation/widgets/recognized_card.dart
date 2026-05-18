import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_avatar.dart';
import '../../../../core/widgets/jb_icons.dart';

class RecognizedCard extends StatelessWidget {
  final String name;
  final String classCode;
  final String nis;
  final int hue;
  final String initials;
  final String time;
  final VoidCallback? onClockIn;
  final VoidCallback? onClockOut;
  final VoidCallback? onDismiss;

  const RecognizedCard({
    super.key,
    required this.name,
    required this.classCode,
    required this.nis,
    required this.hue,
    required this.initials,
    required this.time,
    this.onClockIn,
    this.onClockOut,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.jb;

    return Container(
      decoration: BoxDecoration(
        color: c.bgElev,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x22,
        AppSpacing.x18,
        AppSpacing.x22,
        AppSpacing.x18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfidencePill(),
          const SizedBox(height: AppSpacing.x14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JbAvatar(initials: initials, hue: hue, size: 56, fontSize: 18),
              const SizedBox(width: AppSpacing.x14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: c.textMute,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(text: '$classCode  ·  NIS '),
                          TextSpan(
                            text: nis,
                            style: TextStyle(
                              color: c.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x6),
                    Row(
                      children: [
                        JbIcon(JbIcon.clock, size: 14, color: c.success),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: TextStyle(
                            color: c.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x14),
          Text(
            AppStrings.recognizedPrompt,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textMute,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.x12),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  title: AppStrings.clockInBig,
                  subtitle: AppStrings.clockInSub,
                  background: c.primary,
                  foreground: c.onPrimary,
                  caret: JbIcon(JbIcon.chevronRight,
                      size: 18, color: c.onPrimary),
                  onTap: onClockIn,
                ),
              ),
              const SizedBox(width: AppSpacing.x12),
              Expanded(
                child: _ActionTile(
                  title: AppStrings.clockOutBig,
                  subtitle: AppStrings.clockOutSub,
                  background: c.bgSubtle,
                  foreground: c.text,
                  caret:
                      JbIcon(JbIcon.chevronLeft, size: 18, color: c.text),
                  onTap: onClockOut,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x14),
          Center(
            child: GestureDetector(
              onTap: onDismiss,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.notYouTap,
                      style: TextStyle(
                        color: c.textMute,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: AppStrings.tapToDismiss,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: AppStrings.autoCancels,
                      style: TextStyle(
                        color: c.textFaint,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
}

class _ConfidencePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12, vertical: AppSpacing.x6),
      decoration: BoxDecoration(
        color: c.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: c.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.faceRecognized,
            style: TextStyle(
              color: c.success,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color background;
  final Color foreground;
  final Widget caret;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.background,
    required this.foreground,
    required this.caret,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.x18, horizontal: AppSpacing.x14),
          child: Column(
            children: [
              caret,
              const SizedBox(height: AppSpacing.x10),
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
