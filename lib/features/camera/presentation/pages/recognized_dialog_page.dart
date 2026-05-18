import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/mock_data.dart';
import '../../../../routing/app_router.dart';
import '../widgets/camera_background.dart';
import '../widgets/face_scan_frame.dart';
import '../widgets/recognized_card.dart';

class RecognizedDialogPage extends StatelessWidget {
  const RecognizedDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final student = MockData.students[2]; // Chika Maharani

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1426),
        body: CameraBackground(
          child: SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FaceScanFrame(
                      size: 220,
                      color: Color(0xFF5DD49A),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RecognizedCard(
                    name: student.name,
                    classCode: 'XI · RPL · A',
                    nis: '2401007',
                    hue: student.hue,
                    initials: student.initials,
                    time: '07:14 · on time',
                    onClockIn: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.success),
                    onClockOut: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.success),
                    onDismiss: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.camera),
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
