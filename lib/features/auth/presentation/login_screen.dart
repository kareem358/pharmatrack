import 'package:flutter/material.dart';
import 'package:pharmatrack/core/config/app_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.dashboard);
          },
          child: const Text('Go to Dashboard'),
        ),
      ),
    );
  }
}
