enum MedicineStatus {
  active,
  lowStock,
  expired,
  discontinued;

  String get displayName {
    switch (this) {
      case MedicineStatus.active:
        return 'Active';
      case MedicineStatus.lowStock:
        return 'Low Stock';
      case MedicineStatus.expired:
        return 'Expired';
      case MedicineStatus.discontinued:
        return 'Discontinued';
    }
  }
}

class Medicine {
  final String id;
  final String name;
  final String category;
  final String manufacturer;
  final int stock;
  final int reorderLevel;
  final double price;
  final DateTime expiryDate;
  final MedicineStatus status;
  final String? description;
  final String? batchNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.manufacturer,
    required this.stock,
    required this.reorderLevel,
    required this.price,
    required this.expiryDate,
    required this.status,
    this.description,
    this.batchNumber,
    this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isLowStock => stock <= reorderLevel && stock > 0;
  bool get isOutOfStock => stock <= 0;
  
  MedicineStatus get computedStatus {
    if (status == MedicineStatus.discontinued) return MedicineStatus.discontinued;
    if (isExpired) return MedicineStatus.expired;
    if (isLowStock || isOutOfStock) return MedicineStatus.lowStock;
    return MedicineStatus.active;
  }

  String get formattedExpiryDate => 
      '${expiryDate.month}/${expiryDate.day}/${expiryDate.year}';
  
  String get formattedPrice => 'Rs. ${price.toStringAsFixed(2)}';

  Medicine copyWith({
    String? id,
    String? name,
    String? category,
    String? manufacturer,
    int? stock,
    int? reorderLevel,
    double? price,
    DateTime? expiryDate,
    MedicineStatus? status,
    String? description,
    String? batchNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      stock: stock ?? this.stock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      description: description ?? this.description,
      batchNumber: batchNumber ?? this.batchNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
