import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: handleBarcode),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(18),
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
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Point your camera at the login QR code shown in Odoo POS.',
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
