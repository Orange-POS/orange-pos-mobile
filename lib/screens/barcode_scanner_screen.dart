import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/widgets/app_scanner_overlay.dart';
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
          const AppScannerOverlay(
            frameWidth: 320,
            frameHeight: 150,
            frameRadius: 16,
            message: 'Point your camera at the product barcode.',
          ),
        ],
      ),
    );
  }
}
