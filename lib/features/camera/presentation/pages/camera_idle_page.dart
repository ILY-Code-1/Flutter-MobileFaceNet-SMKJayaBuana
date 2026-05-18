import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routing/app_router.dart';
import '../widgets/camera_background.dart';
import '../widgets/camera_top_bar.dart';
import '../widgets/face_scan_frame.dart';
import '../widgets/ready_status_pill.dart';

class CameraIdlePage extends StatelessWidget {
  const CameraIdlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1426),
        body: CameraBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    CameraTopBar(
                      onMenuTap: () => Navigator.pushNamed(
                          context, AppRoutes.passwordGate),
                    ),
                    const Spacer(),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppSpacing.x22),
                      child: Text(
                        AppStrings.lookAtCamera,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x22),
                      child: Text(
                        AppStrings.keepFaceInside,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x22),
                    const ReadyStatusPill(),
                    const SizedBox(height: AppSpacing.x28),
                  ],
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: FaceScanFrame(size: 240),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
