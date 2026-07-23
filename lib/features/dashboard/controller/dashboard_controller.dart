import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/db_helper.dart';
import '../models/top_selling_medicine.dart';

class DashboardStats {
  final double todaySales;
  final double todayGrowth;
  final int lowStockCount;
  final int lowStockGrowth;
  final int totalMedicines;
  final double totalMedicinesGrowth;
  final double monthlyRevenue;
  final double monthlyGrowth;

  DashboardStats({
    required this.todaySales,
    required this.todayGrowth,
    required this.lowStockCount,
    required this.lowStockGrowth,
    required this.totalMedicines,
    required this.totalMedicinesGrowth,
    required this.monthlyRevenue,
    required this.monthlyGrowth,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
  
  // Previous periods for growth calculation
  final yesterdayStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)).millisecondsSinceEpoch;
  final lastMonthStart = DateTime(now.year, now.month - 1, 1).millisecondsSinceEpoch;

  // Fetch real data from DB
  final todaySummary = await DBHelper.instance.getSalesSummary(todayStart);
  final yesterdaySummary = await DBHelper.instance.getSalesSummary(yesterdayStart);
  final monthlySummary = await DBHelper.instance.getSalesSummary(monthStart);
  final lastMonthSummary = await DBHelper.instance.getSalesSummary(lastMonthStart);
  
  final medicines = await DBHelper.instance.getMedicines();
  
  int lowStock = 0;
  for (var med in medicines) {
    final stock = (med['stock'] as int?) ?? 0;
    final reorder = (med['reorder_level'] as int?) ?? 0;
    if (stock <= reorder) lowStock++;
  }

  // Calculate growths (simplistic)
  double todaySales = (todaySummary['total_sales'] as num?)?.toDouble() ?? 0.0;
  double yesterdaySales = ((yesterdaySummary['total_sales'] as num?)?.toDouble() ?? 0.0) - todaySales;
  double todayGrowth = yesterdaySales > 0 ? ((todaySales - yesterdaySales) / yesterdaySales) * 100 : 0.0;

  double monthlyRevenue = (monthlySummary['total_sales'] as num?)?.toDouble() ?? 0.0;
  double lastMonthTotal = (lastMonthSummary['total_sales'] as num?)?.toDouble() ?? 0.0;
  double lastMonthRevenue = lastMonthTotal - monthlyRevenue;
  double monthlyGrowth = lastMonthRevenue > 0 ? ((monthlyRevenue - lastMonthRevenue) / lastMonthRevenue) * 100 : 0.0;

  return DashboardStats(
    todaySales: todaySales,
    todayGrowth: double.parse(todayGrowth.toStringAsFixed(1)),
    lowStockCount: lowStock,
    lowStockGrowth: 0, // Could be calculated with history
    totalMedicines: medicines.length,
    totalMedicinesGrowth: 0,
    monthlyRevenue: monthlyRevenue,
    monthlyGrowth: double.parse(monthlyGrowth.toStringAsFixed(1)),
  );
});

final topSellingMedicinesProvider = FutureProvider<List<TopSellingMedicine>>((ref) async {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1).millisecondsSinceEpoch;
  final rows = await DBHelper.instance.getTopSellingMedicines(monthStart, limit: 5);
  
  return rows.map((r) {
    final stock = (r['stock'] as int?) ?? 0;
    final reorder = (r['reorder_level'] as int?) ?? 0;
    StockStatus status = StockStatus.active;
    if (stock <= 0) status = StockStatus.expired; // Or outOfStock
    else if (stock <= reorder) status = StockStatus.lowStock;
    
    return TopSellingMedicine(
      id: r['id'].toString(),
      name: r['name'] ?? '',
      category: r['category'] ?? '',
      quantitySold: (r['quantity_sold'] as int?) ?? 0,
      revenue: (r['revenue'] as num?)?.toDouble() ?? 0.0,
      stockStatus: status,
    );
  }).toList();
});
