import 'package:flutter/material.dart';

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Role Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Role Dashboard'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inventory');
              },
              child: const Text('Go to Inventory'),
            ),
          ],
        ),
      ),
    );
  }
}
