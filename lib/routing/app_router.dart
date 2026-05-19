import 'package:flutter/material.dart';

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
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
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
        return MaterialPageRoute(
          builder: (_) => const AddStudentPage(),
          settings: settings,
        );
      case AppRoutes.recognized:
        return MaterialPageRoute(
          builder: (_) => const RecognizedDialogPage(),
          settings: settings,
        );
      case AppRoutes.success:
        return MaterialPageRoute(
          builder: (_) => const SuccessPage(),
          settings: settings,
        );
      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      default:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
    }
  }
}
