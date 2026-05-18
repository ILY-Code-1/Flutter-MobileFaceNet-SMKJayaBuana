import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const JayaBuanaApp());
}

class JayaBuanaApp extends StatelessWidget {
  const JayaBuanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.dev,
      onGenerateRoute: AppRouter.onGenerate,
    );
  }
}
