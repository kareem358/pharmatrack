import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/models/medicine.dart';
import '../../customers/db_helper.dart';

enum ReportTimeRange {
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  thisMonth('This Month'),
  thisYear('This Year');

  final String label;
  const ReportTimeRange(this.label);
}

class ReportSummary {
  final double totalSales;
  final double salesGrowth;
  final int totalTransactions;
  final double transactionsGrowth;
  final double avgDailySales;
  final double dailySalesGrowth;
  final double avgTransaction;
  final double avgTransactionGrowth;

  ReportSummary({
    required this.totalSales,
    required this.salesGrowth,
    required this.totalTransactions,
    required this.transactionsGrowth,
    required this.avgDailySales,
    required this.dailySalesGrowth,
    required this.avgTransaction,
    required this.avgTransactionGrowth,
  });
}

class SalesTrendPoint {
  final DateTime date;
  final double amount;
  SalesTrendPoint(this.date, this.amount);
}

class CategoryRevenue {
  final String category;
  final double percentage;
  CategoryRevenue(this.category, this.percentage);
}

class TopMedicine {
  final String name;
  final String category;
  final int quantitySold;
  final double revenue;
  final MedicineStatus stockStatus;

  TopMedicine({
    required this.name,
    required this.category,
    required this.quantitySold,
    required this.revenue,
    required this.stockStatus,
  });
}

class ReportState {
  final ReportTimeRange timeRange;
  final ReportSummary summary;
  final List<SalesTrendPoint> salesTrend;
  final List<CategoryRevenue> categoryRevenue;
  final List<TopMedicine> topMedicines;

  ReportState({
    required this.timeRange,
    required this.summary,
    required this.salesTrend,
    required this.categoryRevenue,
    required this.topMedicines,
  });

  ReportState copyWith({
    ReportTimeRange? timeRange,
    ReportSummary? summary,
    List<SalesTrendPoint>? salesTrend,
    List<CategoryRevenue>? categoryRevenue,
    List<TopMedicine>? topMedicines,
  }) {
    return ReportState(
      timeRange: timeRange ?? this.timeRange,
      summary: summary ?? this.summary,
      salesTrend: salesTrend ?? this.salesTrend,
      categoryRevenue: categoryRevenue ?? this.categoryRevenue,
      topMedicines: topMedicines ?? this.topMedicines,
    );
  }
}

class ReportController extends AsyncNotifier<ReportState> {
  @override
  Future<ReportState> build() async {
    return _fetchData(ReportTimeRange.last7Days);
  }

  Future<ReportState> _fetchData(ReportTimeRange range) async {
    final now = DateTime.now();
    DateTime start;
    switch (range) {
      case ReportTimeRange.last7Days:
        start = now.subtract(const Duration(days: 7));
        break;
      case ReportTimeRange.last30Days:
        start = now.subtract(const Duration(days: 30));
        break;
      case ReportTimeRange.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportTimeRange.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
    }

    final sinceMs = start.millisecondsSinceEpoch;
    final summaryRow = await DBHelper.instance.getSalesSummary(sinceMs);
    final topRows = await DBHelper.instance.getTopSellingMedicines(sinceMs, limit: 10);

    final totalSales = (summaryRow['total_sales'] as num?)?.toDouble() ?? 0.0;
    final transactions = (summaryRow['transactions'] as int?) ?? 0;

    final summary = ReportSummary(
      totalSales: totalSales,
      salesGrowth: 0,
      totalTransactions: transactions,
      transactionsGrowth: 0,
      avgDailySales: 0,
      dailySalesGrowth: 0,
      avgTransaction: transactions > 0 ? totalSales / transactions : 0.0,
      avgTransactionGrowth: 0,
    );

    final top = topRows.map((r) {
      final stock = (r['stock'] as int?) ?? 0;
      final reorder = (r['reorder_level'] as int?) ?? 0;
      MedicineStatus status = MedicineStatus.active;
      if (stock <= reorder) status = MedicineStatus.lowStock;
      if (stock == 0) status = MedicineStatus.discontinued;
      return TopMedicine(
        name: r['name'] ?? '',
        category: r['category'] ?? '',
        quantitySold: (r['quantity_sold'] as int?) ?? 0,
        revenue: (r['revenue'] as num?)?.toDouble() ?? 0.0,
        stockStatus: status,
      );
    }).toList();

    return ReportState(
      timeRange: range,
      summary: summary,
      salesTrend: [],
      categoryRevenue: [],
      topMedicines: top,
    );
  }

  Future<void> setTimeRange(ReportTimeRange range) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData(range));
  }
}

final reportControllerProvider = AsyncNotifierProvider<ReportController, ReportState>(ReportController.new);
