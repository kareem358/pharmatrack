import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db_helper.dart';

enum CustomerPeriod { daily, weekly, monthly, all }

class CustomerState {
  final List<Map<String, dynamic>> summaries;
  final CustomerPeriod period;
  final bool isLoading;
  final String? errorMessage;

  CustomerState({
    required this.summaries,
    required this.period,
    this.isLoading = false,
    this.errorMessage,
  });

  CustomerState copyWith({
    List<Map<String, dynamic>>? summaries,
    CustomerPeriod? period,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerState(
      summaries: summaries ?? this.summaries,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Professional Notifier for Customer Management
class CustomerController extends Notifier<CustomerState> {
  @override
  CustomerState build() {
    // Initial state
    final initialState = CustomerState(
      summaries: [],
      period: CustomerPeriod.all,
      isLoading: true,
    );

    // Load data immediately
    _loadSummaries(initialState.period);

    return initialState;
  }

  Future<void> _loadSummaries(CustomerPeriod period) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await DBHelper.instance.getCustomerSummaries(period.name);
      state = state.copyWith(summaries: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: 'Failed to load customers: ${e.toString()}'
      );
    }
  }

  void loadSummaries() {
    _loadSummaries(state.period);
  }

  void setPeriod(CustomerPeriod period) {
    if (state.period == period) return;
    state = state.copyWith(period: period);
    _loadSummaries(period);
  }

  /// Fetches specific transaction history for a customer
  Future<List<Map<String, dynamic>>> getDetailedHistory(String phone) async {
    try {
      return await DBHelper.instance.getInvoicesForCustomer(phone, state.period.name);
    } catch (e) {
      return [];
    }
  }
}

final customerControllerProvider = NotifierProvider<CustomerController, CustomerState>(CustomerController.new);
