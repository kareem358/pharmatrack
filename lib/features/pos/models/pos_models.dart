class PosItem {
  final String id;
  final String name;
  final String manufacturer;
  final int stock;
  final double price;
  int quantity;
  final String batchNumber;
  final DateTime expiryDate;

  PosItem({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.stock,
    required this.price,
    this.quantity = 1,
    required this.batchNumber,
    required this.expiryDate,
  });

  double get totalPrice => price * quantity;

  bool get isValid => quantity > 0 && quantity <= stock;

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(2)}';
  String get formattedTotal => 'Rs. ${totalPrice.toStringAsFixed(2)}';
  String get formattedExpiry => '${expiryDate.month}/${expiryDate.day}/${expiryDate.year}';

  PosItem copyWith({int? quantity}) {
    return PosItem(
      id: id,
      name: name,
      manufacturer: manufacturer,
      stock: stock,
      price: price,
      quantity: quantity ?? this.quantity,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
    );
  }
}

class Customer {
  final String? name;
  final String? phone;
  final String? address;

  const Customer({
    this.name,
    this.phone,
    this.address,
  });

  bool get isEmpty => (name?.isEmpty ?? true) && (phone?.isEmpty ?? true);

  Customer copyWith({
    String? name,
    String? phone,
    String? address,
  }) {
    return Customer(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class CartSummary {
  final List<PosItem> items;
  final Customer customer;

  CartSummary({
    required this.items,
    required this.customer,
  });

  int get itemCount => items.length;
  int get totalQuantity => items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  double get tax => subtotal * 0.05; // 5% GST/Sales Tax
  double get total => subtotal + tax;

  String get formattedSubtotal => 'Rs. ${subtotal.toStringAsFixed(2)}';
  String get formattedTax => 'Rs. ${tax.toStringAsFixed(2)}';
  String get formattedTotal => 'Rs. ${total.toStringAsFixed(2)}';

  bool get canCheckout => items.isNotEmpty && !customer.isEmpty;

  CartSummary copyWith({
    List<PosItem>? items,
    Customer? customer,
  }) {
    return CartSummary(
      items: items ?? this.items,
      customer: customer ?? this.customer,
    );
  }
}

class Invoice {
  final String invoiceNumber;
  final DateTime createdAt;
  final CartSummary cartSummary;
  final String paymentMethod;
  final double amountPaid;
  final double change;

  Invoice({
    required this.invoiceNumber,
    required this.createdAt,
    required this.cartSummary,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
  });

  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
}
