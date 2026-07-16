import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/settings_controller.dart';

class SecuritySettingsTab extends ConsumerWidget {
  const SecuritySettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(securitySettingsProvider);
    final notifier = ref.read(securitySettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Description Header
        const Text(
          'Security & Backup',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage security settings, backups, and system maintenance',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 32),

        // Main Sections Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Policy Card
            Expanded(
              child: _buildSectionCard(
                title: 'Password Policy',
                icon: Icons.vpn_key_outlined,
                children: [
                  _buildToggleRow(
                    label: 'Require strong passwords',
                    value: settings.requireStrongPassword,
                    onChanged: (v) => notifier.updateRequireStrongPassword(v),
                  ),
                  _buildToggleRow(
                    label: 'Force password change every 90 days',
                    value: settings.forcePasswordChange,
                    onChanged: (v) => notifier.updateForcePasswordChange(v),
                  ),
                  _buildToggleRow(
                    label: 'Two-factor authentication',
                    value: settings.twoFactorAuth,
                    onChanged: (v) => notifier.updateTwoFactorAuth(v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Data Backup Card
            Expanded(
              child: _buildSectionCard(
                title: 'Data Backup',
                icon: Icons.cloud_upload_outlined,
                children: [
                  _buildToggleRow(
                    label: 'Auto backup daily',
                    value: settings.autoBackupDaily,
                    onChanged: (v) => notifier.updateAutoBackupDaily(v),
                  ),
                  _buildToggleRow(
                    label: 'Cloud backup enabled',
                    value: settings.cloudBackupEnabled,
                    onChanged: (v) => notifier.updateCloudBackupEnabled(v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement backup download logic
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download Backup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF374151),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // System Information Card
        _buildSectionCard(
          title: 'System Information',
          icon: Icons.info_outline_rounded,
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 4,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInfoTile('Version', 'PharmaPOS v2.1.0'),
                _buildInfoTile('Last Backup', 'January 21, 2024 - 02:00 AM'),
                _buildInfoTile('Database Size', '45.2 MB'),
                _buildInfoTile('Uptime', '15 days, 8 hours'),
              ],
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Global Save Button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Security settings updated successfully'),
                  behavior: SnackBarBehavior.floating,
                  width: 400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF111827),
                ),
              );
            },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Security Settings'),
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF374151)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.8,
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
