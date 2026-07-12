import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmatrack/core/constants/app_colors.dar.dart';
import 'package:pharmatrack/features/inventory/presentation/inventory_screen.dart';
import 'package:pharmatrack/features/pos/presentation/pos_screen.dart';
import 'package:pharmatrack/features/customers/presentation/customers_screen.dart';
import 'package:pharmatrack/features/reports/presentation/reports_screen.dart';
import 'package:pharmatrack/features/settings/presentation/settings_screen.dart';

/// Modern Notifier to manage the dashboard's active index
class DashboardIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final dashboardIndexProvider = NotifierProvider<DashboardIndexNotifier, int>(DashboardIndexNotifier.new);

class RoleDashboard extends ConsumerWidget {
  const RoleDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(dashboardIndexProvider);

    final List<String> titles = [
      "Dashboard Overview",
      "Medicine Inventory",
      "Point of Sale",
      "Customer Management",
      "Business Reports",
      "System Settings",
    ];

    final List<Widget> screens = [
      const _DashboardHome(),
      const InventoryScreen(),
      const PosScreen(),
      const CustomersScreen(),
      const ReportScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 220,
            backgroundColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.medication), label: Text('Inventory')),
              NavigationRailDestination(icon: Icon(Icons.point_of_sale), label: Text('POS')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Customers')),
              NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Reports')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => ref.read(dashboardIndexProvider.notifier).setIndex(index),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.link, color: Colors.blue, size: 28),
                  const SizedBox(width: 8),
                  Text("PharmaPOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(context, ref, selectedIndex, titles[selectedIndex]),
                Expanded(
                  child: screens[selectedIndex], 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, WidgetRef ref, int currentIndex, String title) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          if (currentIndex != 0) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () => ref.read(dashboardIndexProvider.notifier).setIndex(0),
            ),
            const SizedBox(width: 8),
          ],
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text("Welcome, admin@gmail.com", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_none_outlined, size: 28),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends ConsumerWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView( 
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              _statCard("Today's Sales", "₹45,230", Icons.attach_money, "+12%", Colors.blue),
              _statCard("Low Stock Items", "23", Icons.warning_amber_rounded, "-5%", Colors.red),
              _statCard("Total Medicines", "1,234", Icons.inventory_2, "+8%", Colors.green),
              _statCard("Monthly Revenue", "₹12.5L", Icons.trending_up, "+15%", Colors.deepPurple),
            ],
          ),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _actionCard(ref, 1, "Medicine Management", "Manage inventory, add medicines, track stock", Icons.medication, Colors.blue, "1,234 items"),
              _actionCard(ref, 2, "POS & Billing", "Process sales, generate bills, print invoices", Icons.shopping_cart, Colors.green, "₹45,230 Today"),
              _actionCard(ref, 4, "Reports", "Daily/Monthly reports, low stock alerts", Icons.analytics, Colors.purple, "12 Reports"),
              _actionCard(ref, 0, "Notifications", "Alerts, expiry notifications, system updates", Icons.notifications, Colors.orange, "5 New"),
              _actionCard(ref, 5, "Settings", "Store settings, user management, billing config", Icons.settings, Colors.grey, "Configure"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, String trend, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600])),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(WidgetRef ref, int index, String title, String desc, IconData icon, Color color, String badge) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => ref.read(dashboardIndexProvider.notifier).setIndex(index),
                child: Text("Open $title"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
