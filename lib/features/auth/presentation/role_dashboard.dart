import 'package:flutter/material.dart';
import 'package:pharmatrack/core/config/app_router.dart';

class RoleDashboard extends StatelessWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.inventory),
            child: const Text('Go to Inventory'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.pos),
            child: const Text('Go to POS'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.customers),
            child: const Text('Go to Customers'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.reports),
            child: const Text('Go to Reports'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.settingsRoute),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}


/*
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
*/
