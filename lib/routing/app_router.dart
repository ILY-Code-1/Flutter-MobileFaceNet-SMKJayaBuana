import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/jb_card.dart';
import '../core/widgets/jb_icons.dart';
import '../features/camera/presentation/pages/camera_idle_page.dart';
import '../features/camera/presentation/pages/password_gate_page.dart';
import '../features/camera/presentation/pages/recognized_dialog_page.dart';
import '../features/camera/presentation/pages/success_page.dart';
import '../features/menu/presentation/pages/menu_page.dart';
import '../features/registration/presentation/pages/registration_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/students/presentation/pages/add_student_page.dart';
import '../features/students/presentation/pages/students_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String registration = '/registration';
  static const String camera = '/camera';
  static const String passwordGate = '/password-gate';
  static const String menu = '/menu';
  static const String settings = '/settings';
  static const String students = '/students';
  static const String addStudent = '/add-student';
  static const String recognized = '/recognized';
  static const String success = '/success';
  static const String reports = '/reports';
  static const String dev = '/_dev';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dev:
        return MaterialPageRoute(builder: (_) => const DevNavigatorPage());
      case AppRoutes.registration:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case AppRoutes.camera:
        return MaterialPageRoute(builder: (_) => const CameraIdlePage());
      case AppRoutes.passwordGate:
        return ModalBottomSheetRoute<void>(
          builder: (_) => const PasswordGateSheet(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          modalBarrierColor: Colors.black.withValues(alpha: 0.35),
        );
      case AppRoutes.menu:
        return MaterialPageRoute(builder: (_) => const MenuPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.students:
        return MaterialPageRoute(builder: (_) => const StudentsPage());
      case AppRoutes.addStudent:
        return MaterialPageRoute(builder: (_) => const AddStudentPage());
      case AppRoutes.recognized:
        return MaterialPageRoute(builder: (_) => const RecognizedDialogPage());
      case AppRoutes.success:
        return MaterialPageRoute(builder: (_) => const SuccessPage());
      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      default:
        return MaterialPageRoute(builder: (_) => const DevNavigatorPage());
    }
  }
}

/// Hidden dev menu listing every screen for QA.
class DevNavigatorPage extends StatelessWidget {
  const DevNavigatorPage({super.key});

  static const List<_DevEntry> _entries = [
    _DevEntry('01 · Registration', AppRoutes.registration),
    _DevEntry('02 · Camera Idle', AppRoutes.camera),
    _DevEntry('03 · Password Gate', AppRoutes.passwordGate),
    _DevEntry('04 · Menu', AppRoutes.menu),
    _DevEntry('05 · Settings', AppRoutes.settings),
    _DevEntry('06 · Students', AppRoutes.students),
    _DevEntry('07 · Add Student', AppRoutes.addStudent),
    _DevEntry('08 · Recognized', AppRoutes.recognized),
    _DevEntry('09 · Reports', AppRoutes.reports),
    _DevEntry('10 · Success', AppRoutes.success),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.jb;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: const Text(AppStrings.devNav),
        backgroundColor: c.bg,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.x18),
          itemCount: _entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x10),
          itemBuilder: (context, i) {
            final e = _entries[i];
            return JbCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x18, vertical: AppSpacing.x14),
              onTap: () => Navigator.pushNamed(context, e.route),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.label,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  JbIcon(JbIcon.chevronRight, color: c.textMute, size: 18),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DevEntry {
  final String label;
  final String route;
  const _DevEntry(this.label, this.route);
}
