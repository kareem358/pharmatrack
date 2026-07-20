
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../customers/db_helper.dart';
import '../models/pos_models.dart';

// Search query provider
final posSearchQueryProvider = StateProvider<String>((ref) => '');

// Available medicines provider (from DB)
final availableMedicinesProvider = FutureProvider<List<PosItem>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  final rows = await DBHelper.instance.getMedicines();
  if (rows.isEmpty) {
    // fallback to mock
    return _mockMedicines();
  }
  return rows.map((r) {
    return PosItem(
      id: r['id'].toString(),
      name: r['name'] ?? '',
      manufacturer: r['manufacturer'] ?? '',
      stock: (r['stock'] as int?) ?? 0,
      price: (r['price'] as num?)?.toDouble() ?? 0.0,
      batchNumber: r['batch_number'] ?? '',
      expiryDate: r['expiry_date'] != null ? DateTime.fromMillisecondsSinceEpoch(r['expiry_date'] as int) : DateTime.now(),
    );
  }).toList();
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
      customer: const Customer(), // Reset customer when clearing cart
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

List<PosItem> _mockMedicines() {
  return [
    PosItem(
      id: '1',
      name: 'Paracetamol 500mg',
      manufacturer: 'ABC Pharma',
      stock: 50,
      price: 3.00,
      batchNumber: 'BATCH001',
      expiryDate: DateTime(2025, 12, 31),
    ),
    PosItem(
      id: '2',
      name: 'Amoxicillin 250mg',
      manufacturer: 'XYZ Labs',
      stock: 30,
      price: 10.00,
      batchNumber: 'BATCH002',
      expiryDate: DateTime(2025, 8, 15),
    ),
    PosItem(
      id: '3',
      name: 'Omeprazole 20mg',
      manufacturer: 'GHI Pharma',
      stock: 75,
      price: 6.50,
      batchNumber: 'BATCH003',
      expiryDate: DateTime(2025, 10, 20),
    ),
    PosItem(
      id: '4',
      name: 'Metformin 500mg',
      manufacturer: 'JKL Pharma',
      stock: 100,
      price: 4.00,
      batchNumber: 'BATCH004',
      expiryDate: DateTime(2026, 3, 15),
    ),
    PosItem(
      id: '5',
      name: 'Aspirin 500mg',
      manufacturer: 'MNO Labs',
      stock: 40,
      price: 2.50,
      batchNumber: 'BATCH005',
      expiryDate: DateTime(2025, 9, 30),
    ),
    PosItem(
      id: '6',
      name: 'Ibuprofen 200mg',
      manufacturer: 'PQR Pharma',
      stock: 60,
      price: 3.75,
      batchNumber: 'BATCH006',
      expiryDate: DateTime(2025, 11, 10),
    ),
  ];
}



/*

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../customers/db_helper.dart';
import '../models/pos_models.dart';

// Search query provider
final posSearchQueryProvider = StateProvider<String>((ref) => '');

// Available medicines provider (from DB)
final availableMedicinesProvider = FutureProvider<List<PosItem>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 150));
  final rows = await DBHelper.instance.getMedicines();
  if (rows.isEmpty) {
    // fallback to mock
    return _mockMedicines();
  }
  return rows.map((r) {
    return PosItem(
      id: r['id'].toString(),
      name: r['name'] ?? '',
      manufacturer: r['manufacturer'] ?? '',
      stock: (r['stock'] as int?) ?? 0,
      price: (r['price'] as num?)?.toDouble() ?? 0.0,
      batchNumber: r['batch_number'] ?? '',
      expiryDate: r['expiry_date'] != null ? DateTime.fromMillisecondsSinceEpoch(r['expiry_date'] as int) : DateTime.now(),
    );
  }).toList();
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
      customer: const Customer(), // Reset customer when clearing cart
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

List<PosItem> _mockMedicines() {
  return [
    PosItem(
      id: '1',
      name: 'Paracetamol 500mg',
      manufacturer: 'ABC Pharma',
      stock: 50,
      price: 3.00,
      batchNumber: 'BATCH001',
      expiryDate: DateTime(2025, 12, 31),
    ),
    PosItem(
      id: '2',
      name: 'Amoxicillin 250mg',
      manufacturer: 'XYZ Labs',
      stock: 30,
      price: 10.00,
      batchNumber: 'BATCH002',
      expiryDate: DateTime(2025, 8, 15),
    ),
    PosItem(
      id: '3',
      name: 'Omeprazole 20mg',
      manufacturer: 'GHI Pharma',
      stock: 75,
      price: 6.50,
      batchNumber: 'BATCH003',
      expiryDate: DateTime(2025, 10, 20),
    ),
    PosItem(
      id: '4',
      name: 'Metformin 500mg',
      manufacturer: 'JKL Pharma',
      stock: 100,
      price: 4.00,
      batchNumber: 'BATCH004',
      expiryDate: DateTime(2026, 3, 15),
    ),
    PosItem(
      id: '5',
      name: 'Aspirin 500mg',
      manufacturer: 'MNO Labs',
      stock: 40,
      price: 2.50,
      batchNumber: 'BATCH005',
      expiryDate: DateTime(2025, 9, 30),
    ),
    PosItem(
      id: '6',
      name: 'Ibuprofen 200mg',
      manufacturer: 'PQR Pharma',
      stock: 60,
      price: 3.75,
      batchNumber: 'BATCH006',
      expiryDate: DateTime(2025, 11, 10),
    ),
  ];
}
*/
