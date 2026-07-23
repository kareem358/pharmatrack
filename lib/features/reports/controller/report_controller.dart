import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inventory/models/medicine.dart';
import '../../customers/db_helper.dart';

enum ReportTimeRange {
  daily('Daily Trend'),
  weekly('Weekly Trend'),
  monthly('Monthly Trend'),
  yearly('Yearly Trend');

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
  final double amount;
  final double percentage;
  CategoryRevenue(this.category, this.amount, this.percentage);
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
    return _fetchData(ReportTimeRange.daily);
  }

  Future<ReportState> _fetchData(ReportTimeRange range) async {
    final now = DateTime.now();
    DateTime start;
    DateTime prevStart;
    int daysInRange;
    String groupBy;

    switch (range) {
      case ReportTimeRange.daily:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        prevStart = start.subtract(const Duration(days: 7));
        daysInRange = 7;
        groupBy = 'day';
        break;
      case ReportTimeRange.weekly:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 27));
        prevStart = start.subtract(const Duration(days: 28));
        daysInRange = 28;
        groupBy = 'day';
        break;
      case ReportTimeRange.monthly:
        start = DateTime(now.year, now.month - 5, 1);
        prevStart = DateTime(now.year, now.month - 11, 1);
        daysInRange = 180;
        groupBy = 'month';
        break;
      case ReportTimeRange.yearly:
        start = DateTime(now.year, 1, 1);
        prevStart = DateTime(now.year - 1, 1, 1);
        daysInRange = 365;
        groupBy = 'month';
        break;
    }

    final sinceMs = start.millisecondsSinceEpoch;
    final prevSinceMs = prevStart.millisecondsSinceEpoch;

    // Current period data
    final summaryRow = await DBHelper.instance.getSalesSummary(sinceMs);
    final topRows = await DBHelper.instance.getTopSellingMedicines(sinceMs, limit: 10);
    final trendRows = await DBHelper.instance.getSalesTrend(sinceMs, groupBy);
    final catRows = await DBHelper.instance.getCategoryRevenue(sinceMs);

    // Previous period data for growth calculation
    final prevSummaryRow = await DBHelper.instance.getSalesSummary(prevSinceMs);
    
    final totalSales = (summaryRow['total_sales'] as num?)?.toDouble() ?? 0.0;
    final transactions = (summaryRow['transactions'] as int?) ?? 0;
    
    final totalSalesIncludingPrev = (prevSummaryRow['total_sales'] as num?)?.toDouble() ?? 0.0;
    final prevTotalSales = totalSalesIncludingPrev - totalSales;
    final salesGrowth = prevTotalSales > 0 ? ((totalSales - prevTotalSales) / prevTotalSales) * 100 : 0.0;

    final totalTransIncludingPrev = (prevSummaryRow['transactions'] as int?) ?? 0;
    final prevTransactions = totalTransIncludingPrev - transactions;
    final transGrowth = prevTransactions > 0 ? ((transactions - prevTransactions) / prevTransactions) * 100 : 0.0;

    final avgDaily = daysInRange > 0 ? totalSales / daysInRange : totalSales;
    final prevAvgDaily = daysInRange > 0 ? prevTotalSales / daysInRange : prevTotalSales;
    final avgDailyGrowth = prevAvgDaily > 0 ? ((avgDaily - prevAvgDaily) / prevAvgDaily) * 100 : 0.0;

    final avgTicket = transactions > 0 ? totalSales / transactions : 0.0;
    final prevAvgTicket = prevTransactions > 0 ? prevTotalSales / prevTransactions : 0.0;
    final avgTicketGrowth = prevAvgTicket > 0 ? ((avgTicket - prevAvgTicket) / prevAvgTicket) * 100 : 0.0;

    final summary = ReportSummary(
      totalSales: totalSales,
      salesGrowth: double.parse(salesGrowth.toStringAsFixed(1)),
      totalTransactions: transactions,
      transactionsGrowth: double.parse(transGrowth.toStringAsFixed(1)),
      avgDailySales: avgDaily,
      dailySalesGrowth: double.parse(avgDailyGrowth.toStringAsFixed(1)),
      avgTransaction: avgTicket,
      avgTransactionGrowth: double.parse(avgTicketGrowth.toStringAsFixed(1)),
    );

    final trend = trendRows.map((r) {
      final periodStr = r['period'] as String;
      DateTime date;
      if (groupBy == 'month') {
        final parts = periodStr.split('-');
        date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      } else {
        date = DateTime.parse(periodStr);
      }
      return SalesTrendPoint(
        date,
        (r['amount'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final totalCatRevenue = catRows.fold<double>(0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0.0));
    final categories = catRows.map((r) {
      final amount = (r['amount'] as num?)?.toDouble() ?? 0.0;
      return CategoryRevenue(
        r['category'] ?? 'Other',
        amount,
        totalCatRevenue > 0 ? (amount / totalCatRevenue) * 100 : 0.0,
      );
    }).toList();

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
      salesTrend: trend,
      categoryRevenue: categories,
      topMedicines: top,
    );
  }

  Future<void> setTimeRange(ReportTimeRange range) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData(range));
  }
}

final reportControllerProvider = AsyncNotifierProvider<ReportController, ReportState>(ReportController.new);
