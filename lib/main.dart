import 'package:flutter/material.dart';
import 'package:rental/presentaion/auth/page/splash_screen.dart';
import 'package:rental/shared/theme/app_theme.dart';

import 'package:rental/shared/localization/app_language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLanguageController().initLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController(),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.appThemeConfig,
          locale: Locale(AppLanguageController().currentLanguageCode),
          home: const SplashScreen(),
        );
      },
    );
  }
}

