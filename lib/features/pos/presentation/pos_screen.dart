import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pos_models.dart';
import '../controller/pos_controller.dart';
import '../widgets/medicine_list_widget.dart';
import '../widgets/cart_widget.dart';
import 'invoice_screen.dart';
import 'package:pharmatrack/features/customers/db_helper.dart';
import 'package:pharmatrack/features/customers/controller/customer_controller.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  void _clearCustomerFields() {
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerAddressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cartSummary = ref.watch(cartProvider);
    final filteredMedicines = ref.watch(filteredMedicinesProvider);

    // Explicitly typed <Customer> to resolve the 'isEmpty' and nullability errors.
    ref.listen<Customer>(customerProvider, (previous, next) {
      if (next.isEmpty && previous?.isEmpty == false) {
        _clearCustomerFields();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(context, cartSummary),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildMedicineSection(context, ref, filteredMedicines),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 1,
                  child: _buildCheckoutSection(context, ref, cartSummary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CartSummary cartSummary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
         /* IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),*/
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.green,
            radius: 18,
            child: Icon(Icons.shopping_cart, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Point of Sale',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                cartSummary.formattedTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PosItem>> filteredMedicines,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              ref.read(posSearchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search medicines...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: MedicineListWidget(filteredMedicines: filteredMedicines),
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    WidgetRef ref,
    CartSummary cartSummary,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildCustomerField(
                    'Full Name',
                    _customerNameController,
                    (value) {
                      ref.read(customerProvider.notifier).updateName(value);
                      ref.read(cartProvider.notifier).updateCustomer(
                        cartSummary.customer.copyWith(name: value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCustomerField(
                    'Phone Number',
                    _customerPhoneController,
                    (value) {
                      ref.read(customerProvider.notifier).updatePhone(value);
                      ref.read(cartProvider.notifier).updateCustomer(
                        cartSummary.customer.copyWith(phone: value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCustomerField(
                    'Address',
                    _customerAddressController,
                    (value) {
                      ref.read(customerProvider.notifier).updateAddress(value);
                      ref.read(cartProvider.notifier).updateCustomer(
                        cartSummary.customer.copyWith(address: value),
                      );
                    },
                    maxLines: 2,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cart Items',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${cartSummary.itemCount} items',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CartWidget(cartSummary: cartSummary),
                ],
              ),
            ),
          ),
          _buildFooter(context, ref, cartSummary),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, CartSummary cartSummary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Subtotal', cartSummary.formattedSubtotal),
              _buildSummaryItem('Tax (5%)', cartSummary.formattedTax),
              _buildSummaryItem('Total', cartSummary.formattedTotal, isTotal: true),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: cartSummary.canCheckout
                ? () => _proceedToCheckout(context, ref, cartSummary)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Confirm & Proceed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: cartSummary.items.isEmpty ? null : () => _clearCart(context, ref),
            child: Text(
              'Clear Cart',
              style: TextStyle(
                color: cartSummary.items.isEmpty ? Colors.grey : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: isTotal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerField(
    String label,
    TextEditingController controller,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _proceedToCheckout(BuildContext context, WidgetRef ref, CartSummary cartSummary) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(
        cartSummary: cartSummary,
        onSuccess: () {
          // Force refresh customer screen data
          ref.invalidate(customerControllerProvider);
          // Controllers will clear automatically via ref.listen in build
        },
      ),
    );
  }

  void _clearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('This will remove all items and customer info.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              ref.read(customerProvider.notifier).clear();
              // Controllers clear automatically via ref.listen
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class PaymentDialog extends ConsumerStatefulWidget {
  final CartSummary cartSummary;
  final VoidCallback onSuccess;
  const PaymentDialog({required this.cartSummary, required this.onSuccess, super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  String? selectedMethod = 'Cash';
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.cartSummary.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Complete Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Total Amount Due'),
            trailing: Text(
              widget.cartSummary.formattedTotal,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedMethod,
            items: ['Cash', 'UPI', 'Card', 'Cheque']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => selectedMethod = v),
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount Received',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final amountPaid = double.tryParse(_amountController.text) ?? widget.cartSummary.total;
            final change = amountPaid - widget.cartSummary.total;
            final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

            final invoice = Invoice(
              invoiceNumber: invoiceNumber,
              createdAt: DateTime.now(),
              cartSummary: widget.cartSummary,
              paymentMethod: selectedMethod ?? 'Cash',
              amountPaid: amountPaid,
              change: change,
            );

            try {
              await DBHelper.instance.saveInvoice(invoice);

              // 1. Reset state
              ref.read(cartProvider.notifier).clearCart();
              ref.read(customerProvider.notifier).clear();

              // 2. Notify parent to refresh and UI to clear
              widget.onSuccess();

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sale completed and saved'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceScreen(invoice: invoice)));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save invoice: $e'), backgroundColor: Colors.red));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Payment'),
        ),
      ],
    );
  }
}
