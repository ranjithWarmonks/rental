import 'package:flutter/material.dart';
import 'package:rental/presentaion/auth/page/splash_screen.dart';
import 'package:rental/shared/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appThemeConfig,
      home: SplashScreen(),
    );
  }
}

