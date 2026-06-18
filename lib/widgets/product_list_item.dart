import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onOpen;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name),
              Text(
                product.formattedPrice,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: onOpen,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(72, 34),
          ),
          child: const Text('Open'),
        ),
      ],
    );
  }
}
