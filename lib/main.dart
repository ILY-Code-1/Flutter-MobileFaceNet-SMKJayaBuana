import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_strings.dart';
import 'core/data/app_database.dart';
import 'core/data/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SettingsService.instance.ensureDefaults();
  final hasAdmin = await AppDatabase.instance.hasAdmin();

  runApp(JayaBuanaApp(
    initialRoute: hasAdmin ? AppRoutes.camera : AppRoutes.registration,
  ));
}

class JayaBuanaApp extends StatelessWidget {
  final String initialRoute;
  const JayaBuanaApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerate,
      // Build the initial stack with exactly ONE route. Without this, a
      // multi-segment initialRoute like "/camera" makes Flutter also push
      // the "/" route underneath it (which falls through to RegistrationPage),
      // so popUntil(isFirst) would land on registration instead of the camera.
      onGenerateInitialRoutes: (name) =>
          [AppRouter.onGenerate(RouteSettings(name: name))],
      navigatorObservers: [appRouteObserver],
    );
  }
}
