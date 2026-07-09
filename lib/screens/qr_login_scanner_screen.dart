import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_brand.dart';
import '../core/widgets/app_scanner_overlay.dart';

class QrLoginScannerScreen extends StatefulWidget {
  const QrLoginScannerScreen({super.key});

  @override
  State<QrLoginScannerScreen> createState() => _QrLoginScannerScreenState();
}

class _QrLoginScannerScreenState extends State<QrLoginScannerScreen> {
  bool hasScanned = false;

  void handleBarcode(BarcodeCapture capture) {
    if (hasScanned) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      return;
    }

    final String? qrValue = barcodes.first.rawValue;

    if (qrValue == null || qrValue.isEmpty) {
      return;
    }

    setState(() {
      hasScanned = true;
    });

    Navigator.pop(context, qrValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Login QR'),
        backgroundColor: Colors.black,
        foregroundColor: AppBrand.primary,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: handleBarcode),
          const AppScannerOverlay(
            frameWidth: 260,
            frameHeight: 260,
            frameRadius: 18,
            message:
                'Point your camera at the login QR code shown in Odoo POS.',
          ),
        ],
      ),
    );
  }
}
