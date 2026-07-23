import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/db_helper.dart';
import '../models/medicine.dart';

class MedicineNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    return _fetchMedicines();
  }

  Future<List<Medicine>> _fetchMedicines() async {
    final rows = await DBHelper.instance.getMedicines();
    return rows.map((r) => Medicine(
      id: r['id'].toString(),
      name: r['name'] ?? '',
      category: r['category'] ?? '',
      manufacturer: r['manufacturer'] ?? '',
      stock: (r['stock'] as int?) ?? 0,
      reorderLevel: (r['reorder_level'] as int?) ?? 0,
      price: (r['price'] as num?)?.toDouble() ?? 0.0,
      expiryDate: DateTime.fromMillisecondsSinceEpoch((r['expiry_date'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
      status: MedicineStatus.values[(r['status'] as int?) ?? 0],
      batchNumber: r['batch_number'] as String?,
      createdAt: r['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int) : null,
      updatedAt: r['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int) : null,
    )).toList();
  }

  Future<void> addMedicine(Medicine medicine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await DBHelper.instance.insertMedicine({
        'id': medicine.id,
        'name': medicine.name,
        'category': medicine.category,
        'manufacturer': medicine.manufacturer,
        'stock': medicine.stock,
        'reorder_level': medicine.reorderLevel,
        'price': medicine.price,
        'expiry_date': medicine.expiryDate.millisecondsSinceEpoch,
        'status': medicine.status.index,
        'description': medicine.description,
        'batch_number': medicine.batchNumber,
        'created_at': now,
        'updated_at': now,
      });
      return _fetchMedicines();
    });
  }

  Future<void> updateMedicine(Medicine medicine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await DBHelper.instance.updateMedicine(medicine.id, {
        'name': medicine.name,
        'category': medicine.category,
        'manufacturer': medicine.manufacturer,
        'stock': medicine.stock,
        'reorder_level': medicine.reorderLevel,
        'price': medicine.price,
        'expiry_date': medicine.expiryDate.millisecondsSinceEpoch,
        'status': medicine.status.index,
        'description': medicine.description,
        'batch_number': medicine.batchNumber,
        'updated_at': now,
      });
      return _fetchMedicines();
    });
  }

  Future<void> addStock(String id, int quantity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rows = await DBHelper.instance.getMedicinesByIds([id]);
      if (rows.isNotEmpty) {
        final currentStock = (rows.first['stock'] as int?) ?? 0;
        await DBHelper.instance.updateMedicine(id, {
          'stock': currentStock + quantity,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      return _fetchMedicines();
    });
  }

  Future<void> deleteMedicine(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DBHelper.instance.deleteMedicine(id);
      return _fetchMedicines();
    });
  }
}

final medicineListProvider = AsyncNotifierProvider<MedicineNotifier, List<Medicine>>(MedicineNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? category) => state = category;
}
final selectedCategoryProvider = NotifierProvider<CategoryFilterNotifier, String?>(CategoryFilterNotifier.new);

class StatusFilterNotifier extends Notifier<MedicineStatus?> {
  @override
  MedicineStatus? build() => null;
  void set(MedicineStatus? status) => state = status;
}
final selectedStatusProvider = NotifierProvider<StatusFilterNotifier, MedicineStatus?>(StatusFilterNotifier.new);

final inventoryFilteredMedicinesProvider = Provider<AsyncValue<List<Medicine>>>((ref) {
  final medicinesState = ref.watch(medicineListProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);

  return medicinesState.whenData((medicineList) {
    var filtered = medicineList;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((m) =>
          m.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          m.manufacturer.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    if (selectedCategory != null && selectedCategory != 'All Categories') {
      filtered = filtered.where((m) => m.category == selectedCategory).toList();
    }
    if (selectedStatus != null) {
      filtered = filtered.where((m) => m.computedStatus == selectedStatus).toList();
    }
    return filtered;
  });
});

final medicinesCategoriesProvider = Provider<List<String>>((ref) {
  final medicinesState = ref.watch(medicineListProvider);
  return medicinesState.maybeWhen(
    data: (list) {
      final categories = list.map((e) => e.category).toSet();
      return ['All Categories', ...categories.toList()..sort()];
    },
    orElse: () => ['All Categories'],
  );
});
