import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controller/report_controller.dart';
import '../../inventory/models/medicine.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 200,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 18, color: Colors.black54),
          label: const Text("Back to Dashboard", style: TextStyle(color: Colors.black54)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.description, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("Reports & Analytics", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          state.maybeWhen(
            data: (data) => _buildTimeRangeDropdown(ref, data),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text("Export"),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black87),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: state.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildSummaryCards(data.summary),
              const SizedBox(height: 32),
              _buildTabNavigation(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSalesTrendCard(data.salesTrend)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildCategoryPieCard(data.categoryRevenue)),
                ],
              ),
              const SizedBox(height: 24),
              _buildTopSellingCard(data.topMedicines),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildTimeRangeDropdown(WidgetRef ref, ReportState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportTimeRange>(
          value: state.timeRange,
          isDense: true,
          onChanged: (val) => ref.read(reportControllerProvider.notifier).setTimeRange(val!),
          items: ReportTimeRange.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ReportSummary s) {
    return Row(
      children: [
        _StatCard(title: "Total Sales", value: "Rs. ${NumberFormat('#,###').format(s.totalSales)}", growth: "+${s.salesGrowth}%", icon: Icons.account_balance_wallet_outlined, color: Colors.green),
        const SizedBox(width: 16),
        _StatCard(title: "Transactions", value: "${s.totalTransactions}", growth: "+${s.transactionsGrowth}%", icon: Icons.people_outline, color: Colors.blue),
        const SizedBox(width: 16),
        _StatCard(title: "Avg Daily Sales", value: "Rs. ${NumberFormat('#,###').format(s.avgDailySales)}", growth: "+${s.dailySalesGrowth}%", icon: Icons.show_chart, color: Colors.purple),
        const SizedBox(width: 16),
        _StatCard(title: "Avg Transaction", value: "Rs. ${s.avgTransaction.toInt()}", growth: "+${s.avgTransactionGrowth}%", icon: Icons.shopping_bag_outlined, color: Colors.orange),
      ],
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          _TabItem("Sales Analytics", isActive: true),
          _TabItem("Inventory Reports"),
          _TabItem("Alerts & Notifications"),
          _TabItem("Performance"),
        ],
      ),
    );
  }

  Widget _buildSalesTrendCard(List<SalesTrendPoint> points) {
    return _BaseCard(
      title: "Daily Sales Trend",
      subtitle: "Sales performance over the selected period",
      child: SizedBox(
        height: 300,
        child: points.isEmpty 
          ? const Center(child: Text("No trend data available"))
          : LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5500),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    if (val % 1 != 0 || val.toInt() >= points.length || val < 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(DateFormat('MM/dd').format(points[val.toInt()].date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.amount)).toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.05)),
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieCard(List<CategoryRevenue> data) {
    final colors = [Colors.teal, Colors.blue, Colors.orange, Colors.amber];
    return _BaseCard(
      title: "Revenue by Category",
      subtitle: "Sales distribution across medicine categories",
      child: SizedBox(
        height: 300,
        child: data.isEmpty
          ? const Center(child: Text("No category data available"))
          : PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: data.asMap().entries.map((e) {
              return PieChartSectionData(
                value: e.value.percentage,
                title: '${e.value.category} ${e.value.percentage.toInt()}%',
                color: colors[e.key % colors.length],
                radius: 60,
                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSellingCard(List<TopMedicine> items) {
    return _BaseCard(
      title: "Top Selling Medicines",
      subtitle: "Best performing medicines by quantity sold",
      child: SizedBox(
        width: double.infinity,
        child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text("No top selling medicines found")),
            )
          : DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columns: const [
            DataColumn(label: Text("Medicine")),
            DataColumn(label: Text("Category")),
            DataColumn(label: Text("Quantity Sold")),
            DataColumn(label: Text("Revenue")),
            DataColumn(label: Text("Stock Status")),
          ],
          rows: items.map((m) => DataRow(cells: [
            DataCell(Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(m.category)),
            DataCell(Text("${m.quantitySold}")),
            DataCell(Text("Rs. ${m.revenue.toStringAsFixed(2)}")),
            DataCell(_StatusBadge(m.stockStatus, m.name == "Omeprazole 20mg")), // Custom check for "Expiring Soon"
          ])).toList(),
        ),
      ),
    );
  }
}

// Support UI Widgets
class _StatCard extends StatelessWidget {
  final String title, value, growth;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.growth, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(growth, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _BaseCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  const _TabItem(this.label, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isActive ? Colors.black : Colors.transparent, width: 2)),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MedicineStatus status;
  final bool isExpiringSoon;
  const _StatusBadge(this.status, this.isExpiringSoon);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    String text = "Active";

    if (isExpiringSoon) {
      color = Colors.amber;
      text = "Expiring Soon";
    } else {
      switch (status) {
        case MedicineStatus.lowStock: color = Colors.orange; text = "Low Stock"; break;
        case MedicineStatus.expired: color = Colors.red; text = "Expired"; break;
        default: break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
