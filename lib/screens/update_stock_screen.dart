import 'package:flutter/material.dart';

import '../models/product.dart';

class UpdateStockScreen extends StatefulWidget {
  final Product product;
  final String authToken;
  final String backendUrl;

  const UpdateStockScreen({
    super.key,
    required this.product,
    required this.authToken,
    required this.backendUrl,
  });

  @override
  State<UpdateStockScreen> createState() =>
      _UpdateStockScreenState();
}

class _UpdateStockScreenState extends State<UpdateStockScreen> {
  final TextEditingController stockController =
      TextEditingController();

  String? errorMessage;

  @override
  void dispose() {
    stockController.dispose();
    super.dispose();
  }

  void saveStock() {
    final newStock =
        double.tryParse(stockController.text.trim());

    if (newStock == null || newStock < 0) {
      setState(() {
        errorMessage = 'Enter a valid stock quantity.';
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'The Odoo stock update endpoint is not available yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(34, 16, 34, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 42),
                  const Expanded(
                    child: Text(
                      'Update Stock',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.black12,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Current Stock',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                widget.product.formattedStock,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'New Stock',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'New Stock',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const Spacer(),
              _ActionButton(
                label: 'Save Stock',
                icon: Icons.save_outlined,
                onPressed: saveStock,
                filled: true,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
                filled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool filled;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return Center(
      child: SizedBox(
        width: 245,
        height: 44,
        child: filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: child,
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: child,
              ),
      ),
    );
  }
}