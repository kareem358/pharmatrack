import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/top_selling_medicine.dart';
import '../controller/dashboard_controller.dart';

class TopSellingMedicinesWidget extends ConsumerWidget {
  const TopSellingMedicinesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topMedicines = ref.watch(topSellingMedicinesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Selling Medicines',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best performing medicines by quantity sold',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          topMedicines.when(
            data: (medicines) {
              if (medicines.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No sales data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Quantity Sold')),
                    DataColumn(label: Text('Revenue')),
                    DataColumn(label: Text('Stock Status')),
                  ],
                  rows: medicines
                      .map((medicine) => _buildMedicineRow(medicine))
                      .toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Error: $error'),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMedicineRow(TopSellingMedicine medicine) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            medicine.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(medicine.category)),
        DataCell(
          Text(
            medicine.quantitySold.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(
          Text(
            medicine.formattedRevenue,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        DataCell(_buildStockStatusBadge(medicine.stockStatus)),
      ],
    );
  }

  Widget _buildStockStatusBadge(StockStatus status) {
    final colors = {
      StockStatus.active: (Colors.green, Colors.green.shade100),
      StockStatus.lowStock: (Colors.orange, Colors.orange.shade100),
      StockStatus.expiringsoon: (Colors.amber, Colors.amber.shade100),
      StockStatus.expired: (Colors.red, Colors.red.shade100),
    };

    final (textColor, bgColor) = colors[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
