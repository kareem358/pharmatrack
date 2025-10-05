
import 'package:flutter/material.dart';
import 'core/config/app_router.dart';

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
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'core/config/app_router.dart';


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
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.login,
    );
  }
}



*/

