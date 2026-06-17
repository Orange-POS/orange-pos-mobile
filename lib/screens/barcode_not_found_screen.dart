import 'package:flutter/material.dart';

class BarcodeNotFoundScreen extends StatelessWidget {
  final String barcode;

  const BarcodeNotFoundScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
          child: Column(
            children: [
              const _BarcodeNotFoundHeader(),
              const Spacer(),
              Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.barcode_reader,
                  size: 110,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Product Not Found',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                barcode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This barcode is not available in POS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.add, size: 21),
                  label: const Text('Add Product'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Scan Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeNotFoundHeader extends StatelessWidget {
  const _BarcodeNotFoundHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 48),
        Expanded(
          child: Text(
            'Barcode',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.black12,
          child: Icon(Icons.person_outline, color: Colors.black),
        ),
      ],
    );
  }
}
