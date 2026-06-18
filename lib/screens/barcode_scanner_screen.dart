import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_brand.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool hasScanned = false;

  void handleBarcode(BarcodeCapture capture) {
    if (hasScanned) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      return;
    }

    final String? barcodeValue = barcodes.first.rawValue;

    if (barcodeValue == null || barcodeValue.isEmpty) {
      return;
    }

    setState(() {
      hasScanned = true;
    });

    Navigator.pop(context, barcodeValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Product Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: AppBrand.primary,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: handleBarcode),
          Center(
            child: Container(
              width: 320,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppBrand.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppBrand.primary.withValues(alpha: 0.45),
                ),
              ),
              child: const Text(
                'Point your camera at the product barcode.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
