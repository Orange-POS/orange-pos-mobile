import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showChevron;

  const AppButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppBrand.primaryDark,
          foregroundColor: AppBrand.white,
          disabledBackgroundColor: AppBrand.primaryDark.withValues(alpha: 0.65),
          disabledForegroundColor: AppBrand.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
        ),
        child: Row(
          children: [
            const Spacer(),
            if (isLoading)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppBrand.white,
                ),
              )
            else
              Icon(icon, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.button,
              ),
            ),
            const Spacer(),
            if (showChevron) const Icon(Icons.chevron_right, size: 36),
          ],
        ),
      ),
    );
  }
}
