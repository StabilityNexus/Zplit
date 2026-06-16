import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const ZplitApp());
}

class ZplitApp extends StatelessWidget {
  const ZplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
