import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/settings.dart';
import '../controller/settings_controller.dart';

// Import refactored tab widgets
import 'setting_widgets/store_settings_tab.dart';
import 'setting_widgets/user_management_tab.dart';
import 'setting_widgets/billing_settings_tab.dart';
import 'setting_widgets/stock_settings_tab.dart';
import 'setting_widgets/notifications_settings_tab.dart';
import 'setting_widgets/security_settings_tab.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentSettingsTabProvider);
    final storeSettings = ref.watch(storeSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Modern light grey background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildModernTabBar(ref, currentTab),
              const SizedBox(height: 24),
              _buildTabContent(currentTab, storeSettings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/dashboard'),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              'Manage your pharmacy and team settings',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTabBar(WidgetRef ref, SettingsTab currentTab) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: SettingsTab.values.map((tab) {
          final isActive = tab == currentTab;
          return GestureDetector(
            onTap: () => ref.read(currentSettingsTabProvider.notifier).setTab(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 18,
                    color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(SettingsTab currentTab, StoreSettings storeSettings) {
    switch (currentTab) {
      case SettingsTab.store:
        return StoreSettingsTab(store: storeSettings);
      case SettingsTab.users:
        return const UserManagementTab();
      case SettingsTab.billing:
        return const BillingSettingsTab();
      case SettingsTab.stock:
        return const StockSettingsTab();
      case SettingsTab.notifications:
        return const NotificationsSettingsTab();
      case SettingsTab.security:
        return const SecuritySettingsTab();
    }
  }
}
