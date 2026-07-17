import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/settings_controller.dart';

class StockSettingsTab extends ConsumerWidget {
  const StockSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(stockSettingsProvider);
    final notifier = ref.read(stockSettingsProvider.notifier);

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
          // Header
          const Text(
            'Stock Management Rules',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Configure inventory rules, alerts, and automation settings',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 32),

          // Inputs Row
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  label: 'Default Minimum Stock Level',
                  value: settings.minStockLevel,
                  onChanged: (v) => notifier.updateMinStockLevel(int.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildNumberInput(
                  label: 'Expiry Alert Days',
                  value: settings.expiryAlertDays,
                  onChanged: (v) => notifier.updateExpiryAlertDays(int.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Automation Settings Section
          const Text(
            'Automation Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleRow(
            label: 'Auto-reorder when stock is low',
            value: settings.autoReorder,
            onChanged: (v) => notifier.updateAutoReorder(v),
          ),
          _buildToggleRow(
            label: 'Send low stock alerts',
            value: settings.lowStockAlerts,
            onChanged: (v) => notifier.updateLowStockAlerts(v),
          ),

          const SizedBox(height: 40),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Stock settings updated successfully'),
                    behavior: SnackBarBehavior.floating,
                    width: 400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: const Color(0xFF111827),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save Stock Settings'),
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

  Widget _buildNumberInput({
    required String label,
    required int value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.unfold_more_rounded, size: 20, color: Colors.grey.shade400),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
