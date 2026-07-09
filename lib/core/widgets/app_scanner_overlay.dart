import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';

class AppScannerOverlay extends StatelessWidget {
  final double frameWidth;
  final double frameHeight;
  final double frameRadius;
  final String message;

  const AppScannerOverlay({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameRadius,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: frameWidth,
            height: frameHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppBrand.primary, width: 3),
              borderRadius: BorderRadius.circular(frameRadius),
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
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
