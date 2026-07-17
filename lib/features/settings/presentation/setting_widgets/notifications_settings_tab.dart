import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/settings_controller.dart';

class NotificationsSettingsTab extends ConsumerWidget {
  const NotificationsSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure how and when you receive notifications across all channels',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 32),

          // Notification Channels Section
          _buildSectionHeader('Notification Channels'),
          const SizedBox(height: 16),
          _buildToggleRow(
            label: 'Email notifications',
            description: 'Receive updates and alerts via your registered email',
            value: settings.emailNotifications,
            onChanged: (v) => notifier.updateEmailNotifications(v),
          ),
          _buildToggleRow(
            label: 'SMS notifications',
            description: 'Get critical alerts sent directly to your phone',
            value: settings.smsNotifications,
            onChanged: (v) => notifier.updateSmsNotifications(v),
          ),
          _buildToggleRow(
            label: 'Push notifications',
            description: 'Real-time alerts on your mobile device or browser',
            value: settings.pushNotifications,
            onChanged: (v) => notifier.updatePushNotifications(v),
          ),

          const SizedBox(height: 32),

          // Report Frequency Section
          _buildSectionHeader('Report Frequency'),
          const SizedBox(height: 16),
          _buildToggleRow(
            label: 'Daily sales reports',
            description: 'A summary of your pharmacy\'s daily performance',
            value: settings.dailySalesReports,
            onChanged: (v) => notifier.updateDailySalesReports(v),
          ),
          _buildToggleRow(
            label: 'Weekly summary reports',
            description: 'Comprehensive weekly analytics and inventory insights',
            value: settings.weeklySummaryReports,
            onChanged: (v) => notifier.updateWeeklySummaryReports(v),
          ),

          const SizedBox(height: 40),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 24),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text('Notification preferences saved'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    width: 420,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF111827),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Notification Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF111827),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
