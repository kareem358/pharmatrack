import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pos_models.dart';

class InvoiceScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceScreen({required this.invoice, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Transaction Receipt', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to printer...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing invoice...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 600,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medication_rounded, size: 40, color: Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PharmaTrack Receipt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice #${invoice.invoiceNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Details Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailColumn('DATE & TIME', invoice.formattedDate),
                          _buildDetailColumn('PAYMENT MODE', invoice.paymentMethod.toUpperCase(), alignEnd: true),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Customer Section
                      const Text(
                        'BILL TO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.cartSummary.customer.name ?? 'Walking Customer',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                            ),
                            if (invoice.cartSummary.customer.phone != null) ...[
                              const SizedBox(height: 4),
                              Text(invoice.cartSummary.customer.phone!, style: const TextStyle(color: Color(0xFF4B5563))),
                            ],
                            if (invoice.cartSummary.customer.address != null && invoice.cartSummary.customer.address!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(invoice.cartSummary.customer.address!, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Items Table
                      const Text(
                        'ORDER SUMMARY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(4),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 2)),
                            ),
                            children: [
                              _buildTableHeader('Medicine'),
                              _buildTableHeader('Qty', textAlign: TextAlign.center),
                              _buildTableHeader('Price', textAlign: TextAlign.right),
                              _buildTableHeader('Total', textAlign: TextAlign.right),
                            ],
                          ),
                          ...invoice.cartSummary.items.map((item) => TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(item.quantity.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(item.formattedPrice, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(item.formattedTotal, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              ),
                            ],
                          )),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Financial Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _buildSummaryRow('Subtotal', invoice.cartSummary.formattedSubtotal),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Sales Tax (5%)', invoice.cartSummary.formattedTax),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                                ),
                                _buildSummaryRow('Grand Total', invoice.cartSummary.formattedTotal, isTotal: true),
                                const SizedBox(height: 16),
                                _buildSummaryRow('Paid Amount', 'Rs. ${invoice.amountPaid.toStringAsFixed(2)}'),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Change Return', 'Rs. ${invoice.change.toStringAsFixed(2)}', color: Colors.green.shade700),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      // Footer
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'THANK YOU FOR SHOPPING WITH US!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF111827),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please keep this receipt for your records.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Software Powered by PharmaTrack Solutions',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to POS'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt successfully saved to database'),
                      backgroundColor: Color(0xFF111827),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save & Print'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String label, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        textAlign: textAlign,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? (isTotal ? const Color(0xFF111827) : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}
