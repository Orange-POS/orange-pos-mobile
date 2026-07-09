import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';
import '../theme/app_radius.dart';

class AppBadge extends StatelessWidget {
  final String label;

  const AppBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppBrand.primaryLight,
        borderRadius: AppRadius.pillShape,
        border: Border.all(color: AppBrand.primary),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppBrand.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
