import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../controller/inventory_controller.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMedicines = ref.watch(filteredMedicinesProvider);
    final categories = ref.watch(medicinesCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note: Header is provided by RoleDashboard shell
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
            color: Colors.grey.withOpacity(0.1),
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
              // Responsive layout: Switch to Column if width is too narrow
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
        ref.read(searchQueryProvider.notifier).state = value;
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
      value: selectedCategory ?? 'All Categories',
      isExpanded: true,
      items: categories
          .map((category) => DropdownMenuItem(
        value: category,
        child: Text(category, overflow: TextOverflow.ellipsis, maxLines: 1),
      ))
          .toList(),
      onChanged: (value) {
        ref.read(selectedCategoryProvider.notifier).state =
        value == 'All Categories' ? null : value;
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
      value: selectedStatus,
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
        ))
            .toList(),
      ],
      onChanged: (value) {
        ref.read(selectedStatusProvider.notifier).state = value;
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
      loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
                        Icon(Icons.inventory_2,
                            size: 48, color: Colors.grey.shade300),
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
              if (medicine.isLowStock) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning, size: 16, color: Colors.orange),
              ],
            ],
          ),
        ),
        DataCell(Text(medicine.formattedPrice)),
        DataCell(Text(medicine.formattedExpiryDate)),
        DataCell(_buildStatusBadge(medicine.status)),
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
                onPressed: () =>
                    _showEditMedicineDialog(context, ref, medicine),
                tooltip: 'Edit Medicine',
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
        border: Border.all(color: textColor.withOpacity(0.2)),
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
                _detailRow('Status', medicine.status.displayName),
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

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine added')));
            },
            child: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicineDialog(
      BuildContext context,
      WidgetRef ref,
      Medicine medicine,
      ) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine updated')));
            },
            child: const Text('Update Medicine'),
          ),
        ],
      ),
    );
  }
}

class _MedicineForm extends StatefulWidget {
  final Medicine? initial;
  const _MedicineForm({Key? key, this.initial}) : super(key: key);

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
      status: MedicineStatus.active,
      batchNumber: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Medicine Name', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Category', _categoryController),
            const SizedBox(height: 16),
            _buildTextField('Manufacturer', _manufacturerController),
            const SizedBox(height: 16),
            _buildTextField('Stock', _stockController, inputType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Reorder Level', _reorderLevelController,
                inputType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Price', _priceController, inputType: TextInputType.number),
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
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
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
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 1825)),
        );
        if (date != null) {
          setState(() => _expiryDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Expiry Date: ${_expiryDate.toString().split(' ')[0]}'),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}




/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine.dart';
import '../controller/inventory_controller.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredMedicines = ref.watch(filteredMedicinesProvider);
    final categories = ref.watch(medicinesCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note: Header is provided by RoleDashboard shell
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
            color: Colors.grey.withOpacity(0.1),
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
              // Responsive layout: Switch to Column if width is too narrow
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
        ref.read(searchQueryProvider.notifier).state = value;
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
      value: selectedCategory ?? 'All Categories',
      isExpanded: true,
      items: categories
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category, overflow: TextOverflow.ellipsis, maxLines: 1),
              ))
          .toList(),
      onChanged: (value) {
        ref.read(selectedCategoryProvider.notifier).state =
            value == 'All Categories' ? null : value;
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
      value: selectedStatus,
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
                ))
            .toList(),
      ],
      onChanged: (value) {
        ref.read(selectedStatusProvider.notifier).state = value;
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
      loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
                        Icon(Icons.inventory_2,
                            size: 48, color: Colors.grey.shade300),
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
              if (medicine.isLowStock) ...[
                const SizedBox(width: 8),
                const Icon(Icons.warning, size: 16, color: Colors.orange),
              ],
            ],
          ),
        ),
        DataCell(Text(medicine.formattedPrice)),
        DataCell(Text(medicine.formattedExpiryDate)),
        DataCell(_buildStatusBadge(medicine.status)),
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
                onPressed: () =>
                    _showEditMedicineDialog(context, ref, medicine),
                tooltip: 'Edit Medicine',
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
        border: Border.all(color: textColor.withOpacity(0.2)),
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
                _detailRow('Status', medicine.status.displayName),
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

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine added')));
            },
            child: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _showEditMedicineDialog(
    BuildContext context,
    WidgetRef ref,
    Medicine medicine,
  ) {
    final formKey = GlobalKey<__MedicineFormState>();
    showDialog(
      context: context,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine updated')));
            },
            child: const Text('Update Medicine'),
          ),
        ],
      ),
    );
  }
}

class _MedicineForm extends StatefulWidget {
  final Medicine? initial;
  const _MedicineForm({Key? key, this.initial}) : super(key: key);

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
      status: MedicineStatus.active,
      batchNumber: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      createdAt: widget.initial?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Medicine Name', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Category', _categoryController),
            const SizedBox(height: 16),
            _buildTextField('Manufacturer', _manufacturerController),
            const SizedBox(height: 16),
            _buildTextField('Stock', _stockController, inputType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Reorder Level', _reorderLevelController,
                inputType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Price', _priceController, inputType: TextInputType.number),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
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
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 1825)),
        );
        if (date != null) {
          setState(() => _expiryDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Expiry Date: ${_expiryDate.toString().split(' ')[0]}'),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
*/
