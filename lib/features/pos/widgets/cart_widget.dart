import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_models.dart';
import '../controller/pos_controller.dart';

class CartWidget extends ConsumerWidget {
  final CartSummary cartSummary;

  const CartWidget({required this.cartSummary, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cartSummary.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Cart is empty',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Necessary inside SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Let the parent scroll
      itemCount: cartSummary.items.length,
      itemBuilder: (context, index) {
        final item = cartSummary.items[index];
        return _CartItemTile(item: item, ref: ref);
      },
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final PosItem item;
  final WidgetRef ref;

  const _CartItemTile({
    required this.item,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.formattedPrice,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.formattedTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: item.quantity > 1
                          ? () => ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.id, item.quantity - 1)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.remove, size: 16, color: item.quantity > 1 ? Colors.black : Colors.grey.shade300),
                      ),
                    ),
                    Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    InkWell(
                      onTap: item.quantity < item.stock
                          ? () => ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.id, item.quantity + 1)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.add, size: 16, color: item.quantity < item.stock ? Colors.green : Colors.grey.shade300),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
