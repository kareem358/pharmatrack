import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/customer_controller.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, state),
            const SizedBox(height: 32),
            _buildStatsOverview(state),
            const SizedBox(height: 32),
            Expanded(
              child: _buildCustomerTable(context, ref, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, CustomerState state) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track customer purchase history and billing insights',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showGeneralHistory(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.receipt_long_outlined, size: 20),
          label: const Text('General History', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
        _buildPeriodPicker(ref, state),
      ],
    );
  }

  Widget _buildPeriodPicker(WidgetRef ref, CustomerState state) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: CustomerPeriod.values.map((p) {
          final isSelected = state.period == p;
          return GestureDetector(
            onTap: () => ref.read(customerControllerProvider.notifier).setPeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Text(
                p.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF111827) : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsOverview(CustomerState state) {
    return Row(
      children: [
        _buildStatCard('Total Customers', '${state.totalCustomers}', Icons.people_outline, Colors.blue),
        const SizedBox(width: 24),
        _buildStatCard('${state.period.name.toUpperCase()} Revenue', 'Rs. ${NumberFormat('#,###').format(state.periodRevenue)}', Icons.payments_outlined, Colors.green),
        const SizedBox(width: 24),
        _buildStatCard('Total Active', '${state.totalActiveCustomers}', Icons.trending_up, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTable(BuildContext context, WidgetRef ref, CustomerState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.summaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No customer activity found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
            columns: const [
              DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Orders (ALL)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Spent (ALL)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: state.summaries.map((c) {
              return DataRow(cells: [
                DataCell(Text(c['name'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(c['phone'] ?? '-')),
                DataCell(Text('${c['orders_count'] ?? 0}')),
                DataCell(Text('Rs. ${NumberFormat('#,###.##').format(c['total_spent'] ?? 0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                DataCell(
                  TextButton.icon(
                    onPressed: () => _showCustomerHistory(context, ref, c['id'], c['name'] ?? 'Guest', c['phone'] ?? ''),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('Full History'),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showGeneralHistory(BuildContext context, WidgetRef ref) async {
    final history = await ref.read(customerControllerProvider.notifier).getAllInvoices();
    if (!context.mounted) return;
    _showHistoryDialog(context, ref, 'General History', 'Listing all transactions across all customers', history);
  }

  void _showCustomerHistory(BuildContext context, WidgetRef ref, int customerId, String name, String phone) async {
    final history = await ref.read(customerControllerProvider.notifier).getDetailedHistory(customerId);
    if (!context.mounted) return;
    _showHistoryDialog(context, ref, name, 'Complete purchase history for ${phone.isEmpty ? "Guest" : phone}', history);
  }

  void _showHistoryDialog(BuildContext context, WidgetRef ref, String title, String subtitle, List<Map<String, dynamic>> history) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 32),
                Flexible(
                  child: history.isEmpty
                      ? const Center(child: Text('No orders found'))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: history.length,
                          separatorBuilder: (context, index) => const Divider(height: 32),
                          itemBuilder: (context, index) {
                            final inv = history[index]['invoice'] as Map<String, dynamic>;
                            final items = history[index]['items'] as List<Map<String, dynamic>>;
                            final date = DateTime.fromMillisecondsSinceEpoch(inv['created_at'] as int);
                            final orderNum = history.length - index;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Order #$orderNum',
                                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('Invoice #${inv['invoice_number']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(DateFormat.yMMMd().add_jm().format(date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () => _confirmDeleteInvoice(context, ref, inv['id']),
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Delete Invoice',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Text('${item['quantity']}x ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                          Expanded(child: Text(item['name'] ?? '')),
                                          Text('Rs. ${NumberFormat('#,###.##').format(item['total'] ?? 0)}'),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Total: Rs. ${NumberFormat('#,###.##').format(inv['total'] ?? 0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteInvoice(BuildContext context, WidgetRef ref, int invoiceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice? This will restore the stock for all items in this order and remove the record permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close confirmation
              Navigator.pop(context); // Close history dialog
              await ref.read(customerControllerProvider.notifier).deleteInvoice(invoiceId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice deleted and stock restored')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
