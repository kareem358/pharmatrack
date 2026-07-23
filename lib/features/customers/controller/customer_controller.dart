import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db_helper.dart';

enum CustomerPeriod { daily, weekly, monthly, all }

class CustomerState {
  final List<Map<String, dynamic>> summaries;
  final CustomerPeriod period;
  final bool isLoading;
  final String? errorMessage;
  
  // Overall stats
  final int totalCustomers;
  final double overallRevenue;
  final double periodRevenue;
  final int totalActiveCustomers;

  const CustomerState({
    required this.summaries,
    required this.period,
    this.isLoading = false,
    this.errorMessage,
    this.totalCustomers = 0,
    this.overallRevenue = 0,
    this.periodRevenue = 0,
    this.totalActiveCustomers = 0,
  });

  CustomerState copyWith({
    List<Map<String, dynamic>>? summaries,
    CustomerPeriod? period,
    bool? isLoading,
    String? errorMessage,
    int? totalCustomers,
    double? overallRevenue,
    double? periodRevenue,
    int? totalActiveCustomers,
  }) {
    return CustomerState(
      summaries: summaries ?? this.summaries,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      overallRevenue: overallRevenue ?? this.overallRevenue,
      periodRevenue: periodRevenue ?? this.periodRevenue,
      totalActiveCustomers: totalActiveCustomers ?? this.totalActiveCustomers,
    );
  }
}

class CustomerController extends Notifier<CustomerState> {
  @override
  CustomerState build() {
    Future.microtask(() => refresh());
    
    return const CustomerState(
      summaries: [],
      period: CustomerPeriod.all,
      isLoading: true,
    );
  }

  Future<void> refresh() async {
    await _fetchData(state.period);
  }

  Future<void> _fetchData(CustomerPeriod period) async {
    state = state.copyWith(isLoading: true, errorMessage: null, period: period);
    
    try {
      // 1. Fetch All-Time summaries for the table
      final allSummaries = await DBHelper.instance.getCustomerSummaries('all');
      
      // 2. Fetch Period-specific data for revenue card
      final periodData = await DBHelper.instance.getCustomerSummaries(period.name);
      double pRevenue = 0;
      for (var row in periodData) {
        pRevenue += (row['total_spent'] ?? 0).toDouble();
      }

      // 3. Overall Stats
      int totalCust = allSummaries.length;
      double totalRev = 0;
      int activeCust = 0;
      
      for (var row in allSummaries) {
        double spent = (row['total_spent'] ?? 0).toDouble();
        totalRev += spent;
        if ((row['orders_count'] ?? 0) > 0) {
          activeCust++;
        }
      }

      state = state.copyWith(
        summaries: allSummaries,
        isLoading: false,
        totalCustomers: totalCust,
        overallRevenue: totalRev,
        periodRevenue: pRevenue,
        totalActiveCustomers: activeCust,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void setPeriod(CustomerPeriod period) {
    if (state.period == period && !state.isLoading) return;
    _fetchData(period);
  }

  Future<List<Map<String, dynamic>>> getDetailedHistory(int customerId) async {
    try {
      // Use ID for accurate individual history
      return await DBHelper.instance.getInvoicesForCustomer(customerId, 'all');
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllInvoices() async {
    try {
      return await DBHelper.instance.getInvoicesWithItems(0);
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteInvoice(int invoiceId) async {
    try {
      await DBHelper.instance.deleteInvoice(invoiceId);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete invoice: ${e.toString()}');
    }
  }
}

final customerControllerProvider = NotifierProvider<CustomerController, CustomerState>(CustomerController.new);
