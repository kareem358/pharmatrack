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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 900;
          
          return Row(
            children: [
              NavigationRail(
                extended: !isSmallScreen,
                minExtendedWidth: 220,
                backgroundColor: Colors.white,
                selectedIconTheme: const IconThemeData(color: AppColors.primary),
                selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                unselectedIconTheme: const IconThemeData(color: Colors.grey),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.medication_rounded), label: Text('Inventory')),
                  NavigationRailDestination(icon: Icon(Icons.point_of_sale_rounded), label: Text('POS')),
                  NavigationRailDestination(icon: Icon(Icons.people_alt_rounded), label: Text('Customers')),
                  NavigationRailDestination(icon: Icon(Icons.analytics_rounded), label: Text('Reports')),
                  NavigationRailDestination(icon: Icon(Icons.settings_suggest_rounded), label: Text('Settings')),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => ref.read(dashboardIndexProvider.notifier).setIndex(index),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.track_changes_rounded, color: Colors.blue, size: 28),
                      if (!isSmallScreen) ...[
                        const SizedBox(width: 8),
                        Text("PharmaTrack", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900])),
                      ],
                    ],
                  ),
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: Column(
                  children: [
                    _buildTopHeader(context, ref, selectedIndex, titles[selectedIndex], isSmallScreen),
                    Expanded(
                      child: screens[selectedIndex], 
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, WidgetRef ref, int currentIndex, String title, bool isSmall) {
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blue, size: 18),
              onPressed: () => ref.read(dashboardIndexProvider.notifier).setIndex(0),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title, 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (!isSmall) ...[
            Text("Welcome, Admin", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(width: 20),
          ],
          const Icon(Icons.notifications_active_outlined, size: 24, color: Color(0xFF4B5563)),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: isSmall ? const Text("") : const Text("Logout"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade100),
              padding: isSmall ? const EdgeInsets.all(8) : const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: isSmall ? Size.zero : null,
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        int statCrossAxisCount = 4;
        double statAspectRatio = 2.4;
        
        int actionCrossAxisCount = 2;
        double actionAspectRatio = 1.8;

        if (constraints.maxWidth < 700) {
          statCrossAxisCount = 1;
          statAspectRatio = 4.0;
          actionCrossAxisCount = 1;
          actionAspectRatio = 2.2;
        } else if (constraints.maxWidth < 1100) {
          statCrossAxisCount = 2;
          statAspectRatio = 2.8;
          actionCrossAxisCount = 2;
          actionAspectRatio = 1.6;
        }

        return SingleChildScrollView( 
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statCrossAxisCount,
                childAspectRatio: statAspectRatio,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _statCard("Today's Sales", "Rs. 45,230", Icons.account_balance_wallet_rounded, "+12.5%", Colors.blue),
                  _statCard("Low Stock Items", "23", Icons.inventory_rounded, "-5%", Colors.red),
                  _statCard("Total Medicines", "1,234", Icons.medical_services_rounded, "+8%", Colors.green),
                  _statCard("Monthly Revenue", "Rs. 1.25M", Icons.trending_up_rounded, "+15%", Colors.deepPurple),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "Quick Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: actionCrossAxisCount,
                childAspectRatio: actionAspectRatio,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: [
                  _actionCard(ref, 1, "Inventory", "Manage stock levels, add new medicines, and track batch expiries.", Icons.inventory_2_outlined, Colors.blue),
                  _actionCard(ref, 2, "Sales (POS)", "Create new transactions, generate professional Rs. invoices, and handle payments.", Icons.point_of_sale_rounded, Colors.green),
                  _actionCard(ref, 3, "Customer Portal", "Maintain customer records, track credit (Udhaar), and purchase history.", Icons.people_outline_rounded, Colors.orange),
                  _actionCard(ref, 4, "Business Reports", "Analyze daily sales performance, tax summaries, and financial analytics.", Icons.bar_chart_rounded, Colors.purple),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.north_east_rounded, size: 12, color: trend.startsWith('+') ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trend.startsWith('+') ? Colors.green : Colors.red)),
              const SizedBox(width: 4),
              Text("vs last month", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(WidgetRef ref, int index, String title, String desc, IconData icon, Color color) {
    return InkWell(
      onTap: () => ref.read(dashboardIndexProvider.notifier).setIndex(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                desc, 
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5), 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text("Manage Now", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, color: color, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
