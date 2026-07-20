import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'firebase_options.dart';
import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Desktop (Windows/Linux/macOS)
  if (Platform.isWindows || Platform.isLinux) {

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: PharmaTrackApp(),
    ),
  );
}

class PharmaTrackApp extends StatelessWidget {
  const PharmaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PharmaTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.dashboard,
    );
  }
}

