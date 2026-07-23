import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../inventory/controller/inventory_controller.dart';
import '../../inventory/models/medicine.dart';
import '../models/pos_models.dart';

// Search query provider
final posSearchQueryProvider = StateProvider<String>((ref) => '');

// Available medicines provider - now reactive to inventory changes
// Filters out medicines that are expired, discontinued, or out of stock
final availableMedicinesProvider = Provider<AsyncValue<List<PosItem>>>((ref) {
  final inventoryState = ref.watch(medicineListProvider);
  
  return inventoryState.whenData((medicines) {
    return medicines
        .where((m) => m.computedStatus != MedicineStatus.expired && 
                     m.computedStatus != MedicineStatus.discontinued &&
                     m.stock > 0)
        .map((m) => PosItem(
      id: m.id,
      name: m.name,
      manufacturer: m.manufacturer,
      stock: m.stock,
      price: m.price,
      batchNumber: m.batchNumber ?? '',
      expiryDate: m.expiryDate,
    )).toList();
  });
});

// Filtered medicines based on search
final filteredMedicinesProvider = Provider<AsyncValue<List<PosItem>>>((ref) {
  final medicinesAsync = ref.watch(availableMedicinesProvider);
  final searchQuery = ref.watch(posSearchQueryProvider);

  return medicinesAsync.whenData((medicines) {
    if (searchQuery.isEmpty) return medicines;
    return medicines
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            m.manufacturer.toLowerCase().contains(searchQuery.toLowerCase()) ||
            m.batchNumber.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  });
});

// Cart summary provider
final cartProvider = StateNotifierProvider<CartNotifier, CartSummary>((ref) {
  return CartNotifier();
});

// Customer data provider
final customerProvider = StateNotifierProvider<CustomerNotifier, Customer>((ref) {
  return CustomerNotifier();
});

class CartNotifier extends StateNotifier<CartSummary> {
  CartNotifier()
      : super(CartSummary(
          items: [],
          customer: const Customer(),
        ));

  void addItem(PosItem medicine) {
    final existingIndex =
        state.items.indexWhere((item) => item.id == medicine.id);

    if (existingIndex >= 0) {
      final updatedItem = state.items[existingIndex];
      if (updatedItem.quantity < updatedItem.stock) {
        final updated = updatedItem.copyWith(quantity: updatedItem.quantity + 1);
        final newItems = [...state.items];
        newItems[existingIndex] = updated;
        state = state.copyWith(items: newItems);
      }
    } else {
      state = state.copyWith(items: [...state.items, medicine]);
    }
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }

    final itemIndex = state.items.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      final item = state.items[itemIndex];
      if (quantity <= item.stock) {
        final updated = item.copyWith(quantity: quantity);
        final newItems = [...state.items];
        newItems[itemIndex] = updated;
        state = state.copyWith(items: newItems);
      }
    }
  }

  void clearCart() {
    state = CartSummary(
      items: [],
      customer: const Customer(),
    );
  }

  void updateCustomer(Customer customer) {
    state = state.copyWith(customer: customer);
  }
}

class CustomerNotifier extends StateNotifier<Customer> {
  CustomerNotifier() : super(const Customer());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void clear() {
    state = const Customer();
  }
}
