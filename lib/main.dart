import 'package:flutter/material.dart';
import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';

void main() {
  runApp(const PharmaTrackApp());
}

class PharmaTrackApp extends StatelessWidget {
  const PharmaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // 👈 Apply global theme
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
    );
  }
}



