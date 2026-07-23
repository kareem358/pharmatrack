import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../controller/inventory_controller.dart';
import '../../pos/controller/pos_controller.dart' as pos;

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMedicines = ref.watch(inventoryFilteredMedicinesProvider);
    final categories = ref.watch(medicinesCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderWithAddButton(context, ref),
              const SizedBox(height: 24),
              _buildSearchAndFilter(
                context,
                ref,
                categories,
                selectedCategory,
                selectedStatus,
                filteredMedicines,
              ),
              const SizedBox(height: 32),
              _buildMedicineTable(context, ref, filteredMedicines),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context, ref),
        label: const Text('Add Medicine'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderWithAddButton(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Manage your medicine stock and categories',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddMedicineDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('New Medicine'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> categories,
    String? selectedCategory,
    MedicineStatus? selectedStatus,
    AsyncValue<List<Medicine>> filteredMedicines,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Text(
                'Search & Filter',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 750) {
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildSearchField(ref),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryDropdown(ref, categories, selectedCategory),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusDropdown(ref, selectedStatus),
                    ),
                    const SizedBox(width: 16),
                    _buildItemCountBadge(filteredMedicines),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchField(ref),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryDropdown(ref, categories, selectedCategory)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatusDropdown(ref, selectedStatus)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildItemCountBadge(filteredMedicines),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(WidgetRef ref) {
    return TextField(
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).set(value);
      },
      decoration: InputDecoration(
        hintText: 'Search medicines...',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    WidgetRef ref,
    List<String> categories,
    String? selectedCategory,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: selectedCategory ?? 'All Categories',
      isExpanded: true,
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category, overflow: TextOverflow.ellipsis, maxLines: 1),
              ))
          .toList(),
      onChanged: (value) {
        ref.read(selectedCategoryProvider.notifier).set(
              value == 'All Categories' ? null : value,
            );
      },
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildStatusDropdown(WidgetRef ref, MedicineStatus? selectedStatus) {
    return DropdownButtonFormField<MedicineStatus?>(
      initialValue: selectedStatus,
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Status'),
        ),
        ...MedicineStatus.values
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName, overflow: TextOverflow.ellipsis, maxLines: 1),
                )),
      ],
      onChanged: (value) {
        ref.read(selectedStatusProvider.notifier).set(value);
      },
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildItemCountBadge(AsyncValue<List<Medicine>> filteredMedicines) {
    return filteredMedicines.when(
      data: (medicines) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${medicines.length} Items Found',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      loading: () => const SizedBox(
          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMedicineTable(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Medicine>> filteredMedicines,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
            child: Text(
              'Medicine Inventory',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          filteredMedicines.when(
            data: (medicines) {
              if (medicines.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No medicines found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(label: Text('Medicine Name')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Manufacturer')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Expiry')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: medicines
                      .map((medicine) => _buildMedicineRow(context, ref, medicine))
                      .toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Error loading medicines: $error'),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMedicineRow(
    BuildContext context,
    WidgetRef ref,
    Medicine medicine,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(medicine.category)),
        DataCell(Text(medicine.manufacturer)),
        DataCell(
          Row(
            children: [
              Text(medicine.stock.toString()),
              if (medicine.isLowStock || medicine.isOutOfStock) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning, size: 16, color: Colors.orange),
              ],
            ],
          ),
        ),
        DataCell(Text(medicine.formattedPrice)),
        DataCell(Text(medicine.formattedExpiryDate)),
        // Using computedStatus for real-time accuracy
        DataCell(_buildStatusBadge(medicine.computedStatus)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => _showMedicineDetails(context, medicine),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditMedicineDialog(context, ref, medicine),
                tooltip: 'Edit Medicine',
              ),
              IconButton(
                icon: const Icon(Icons.add_box_outlined, size: 18, color: Colors.green),
                onPressed: () => _showRestockDialog(context, ref, medicine),
                tooltip: 'Quick Restock',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => _confirmDelete(context, ref, medicine),
                tooltip: 'Delete Medicine',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(MedicineStatus status) {
    final colors = {
      MedicineStatus.active: (Colors.green, Colors.green.shade50),
      MedicineStatus.lowStock: (Colors.orange, Colors.orange.shade50),
      MedicineStatus.expired: (Colors.red, Colors.red.shade50),
      MedicineStatus.discontinued: (Colors.grey, Colors.grey.shade50),
    };

    final (textColor, bgColor) = colors[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicine.name),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Category', medicine.category),
                _detailRow('Manufacturer', medicine.manufacturer),
                _detailRow('Stock', medicine.stock.toString()),
                _detailRow('Reorder Level', medicine.reorderLevel.toString()),
                _detailRow('Price', medicine.formattedPrice),
                _detailRow('Expiry Date', medicine.formattedExpiryDate),
                _detailRow('Batch Number', medicine.batchNumber ?? 'N/A'),
                _detailRow('Status', medicine.computedStatus.displayName),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${medicine.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity to add',
            hintText: 'e.g. 50',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(controller.text) ?? 0;
              if (qty > 0) {
                await ref.read(medicineListProvider.notifier).addStock(medicine.id, qty);
                ref.invalidate(pos.availableMedicinesProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $qty to ${medicine.name}'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Add Medicine'),
        content: _MedicineForm(key: formKey),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final med = formKey.currentState?.toMedicine();
              if (med == null) return;
              await ref.read(medicineListProvider.notifier).addMedicine(med);
              ref.invalidate(pos.availableMedicinesProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medicine added successfully'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicineDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Edit Medicine'),
        content: _MedicineForm(key: formKey, initial: medicine),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final med = formKey.currentState?.toMedicine();
              if (med == null) return;
              await ref.read(medicineListProvider.notifier).updateMedicine(med);
              ref.invalidate(pos.availableMedicinesProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medicine updated successfully'), backgroundColor: Colors.blue),
                );
              }
            },
            child: const Text('Update Medicine'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine?'),
        content: Text('Are you sure you want to delete ${medicine.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(medicineListProvider.notifier).deleteMedicine(medicine.id);
              ref.invalidate(pos.availableMedicinesProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medicine deleted'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MedicineForm extends StatefulWidget {
  final Medicine? initial;
  const _MedicineForm({super.key, this.initial});

  @override
  State<_MedicineForm> createState() => __MedicineFormState();
}

class __MedicineFormState extends State<_MedicineForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _stockController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _priceController;
  late final TextEditingController _batchController;
  late DateTime _expiryDate;
  late MedicineStatus _status;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameController = TextEditingController(text: init?.name ?? '');
    _categoryController = TextEditingController(text: init?.category ?? '');
    _manufacturerController = TextEditingController(text: init?.manufacturer ?? '');
    _stockController = TextEditingController(text: init?.stock.toString() ?? '0');
    _reorderLevelController = TextEditingController(text: init?.reorderLevel.toString() ?? '0');
    _priceController = TextEditingController(text: init?.price.toStringAsFixed(2) ?? '0.00');
    _batchController = TextEditingController(text: init?.batchNumber ?? '');
    _expiryDate = init?.expiryDate ?? DateTime.now().add(const Duration(days: 365));
    // Default to active, or user selection if discontinued
    _status = init?.status ?? MedicineStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _manufacturerController.dispose();
    _stockController.dispose();
    _reorderLevelController.dispose();
    _priceController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Medicine? toMedicine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return null;
    final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    return Medicine(
      id: id,
      name: name,
      category: _categoryController.text.trim(),
      manufacturer: _manufacturerController.text.trim(),
      stock: int.tryParse(_stockController.text) ?? 0,
      reorderLevel: int.tryParse(_reorderLevelController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0.0,
      expiryDate: _expiryDate,
      status: _status,
      batchNumber: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Medicine Name', _nameController, isRequired: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Category', _categoryController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Manufacturer', _manufacturerController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Stock Quantity', _stockController, inputType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Price (Rs.)', _priceController, inputType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Reorder Level', _reorderLevelController, inputType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<MedicineStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Manual Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: [MedicineStatus.active, MedicineStatus.discontinued]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                        .toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Batch Number', _batchController),
            const SizedBox(height: 16),
            _buildExpiryDatePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    bool isRequired = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildExpiryDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _expiryDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        if (date != null) {
          setState(() => _expiryDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expiry Date: ${"${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}"}',
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
