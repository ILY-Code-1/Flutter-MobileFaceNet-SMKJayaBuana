import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/jb_icons.dart';

class CameraTopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const CameraTopBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x18,
        AppSpacing.x10,
        AppSpacing.x14,
        AppSpacing.x10,
      ),
      child: Row(
        children: [
          const JbLogo(size: 32),
          const SizedBox(width: AppSpacing.x10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.classLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          _MenuButton(onTap: onMenuTap),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: JbIcon(JbIcon.menu, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
