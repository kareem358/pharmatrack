import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/top_selling_medicine.dart';

final topSellingMedicinesProvider =
    FutureProvider<List<TopSellingMedicine>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return _mockTopSellingMedicines();
});

List<TopSellingMedicine> _mockTopSellingMedicines() {
  return [
    const TopSellingMedicine(
      id: '1',
      name: 'Metformin 500mg',
      category: 'Antidiabetic',
      quantitySold: 234,
      revenue: 936.00,
      stockStatus: StockStatus.active,
    ),
    const TopSellingMedicine(
      id: '2',
      name: 'Paracetamol 500mg',
      category: 'Analgesic',
      quantitySold: 145,
      revenue: 435.00,
      stockStatus: StockStatus.lowStock,
    ),
    const TopSellingMedicine(
      id: '3',
      name: 'Omeprazole 20mg',
      category: 'Antacid',
      quantitySold: 123,
      revenue: 799.50,
      stockStatus: StockStatus.expiringsoon,
    ),
    const TopSellingMedicine(
      id: '4',
      name: 'Amoxicillin 250mg',
      category: 'Antibiotic',
      quantitySold: 89,
      revenue: 890.00,
      stockStatus: StockStatus.active,
    ),
    const TopSellingMedicine(
      id: '5',
      name: 'Aspirin 75mg',
      category: 'Analgesic',
      quantitySold: 67,
      revenue: 100.50,
      stockStatus: StockStatus.expired,
    ),
  ];
}
