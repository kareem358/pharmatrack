enum StockStatus {
  active,
  lowStock,
  expiringsoon,
  expired;

  String get displayName {
    switch (this) {
      case StockStatus.active:
        return 'Active';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.expiringsoon:
        return 'Expiring Soon';
      case StockStatus.expired:
        return 'Expired';
    }
  }
}

class TopSellingMedicine {
  final String id;
  final String name;
  final String category;
  final int quantitySold;
  final double revenue;
  final StockStatus stockStatus;

  const TopSellingMedicine({
    required this.id,
    required this.name,
    required this.category,
    required this.quantitySold,
    required this.revenue,
    required this.stockStatus,
  });

  String get formattedRevenue => '\₹${revenue.toStringAsFixed(2)}';
}
