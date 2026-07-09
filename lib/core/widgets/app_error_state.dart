import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final String? title;
  final String? details;
  final VoidCallback? onCopyDetails;
  final bool boxed;
  final TextAlign textAlign;

  const AppErrorState({
    super.key,
    required this.message,
    this.title,
    this.details,
    this.onCopyDetails,
    this.boxed = false,
    this.textAlign = TextAlign.left,
  });

  const AppErrorState.box({
    super.key,
    required this.message,
    this.title,
    this.details,
    this.onCopyDetails,
    this.textAlign = TextAlign.left,
  }) : boxed = true;

  @override
  Widget build(BuildContext context) {
    final content = _ErrorContent(
      title: title,
      message: message,
      details: details,
      onCopyDetails: onCopyDetails,
      textAlign: textAlign,
    );

    if (!boxed) {
      return Align(
        alignment: textAlign == TextAlign.center
            ? Alignment.center
            : Alignment.centerLeft,
        child: content,
      );
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.errorPadding,
      decoration: BoxDecoration(
        color: AppBrand.errorBackground,
        border: Border.all(color: AppBrand.errorBorder),
        borderRadius: AppRadius.large,
      ),
      child: content,
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String? title;
  final String message;
  final String? details;
  final VoidCallback? onCopyDetails;
  final TextAlign textAlign;

  const _ErrorContent({
    required this.title,
    required this.message,
    required this.details,
    required this.onCopyDetails,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(message, textAlign: textAlign, style: AppTextStyles.error),
        if (details != null) ...[
          const SizedBox(height: AppSpacing.md),
          SelectableText(
            details!,
            style: const TextStyle(fontSize: 10, color: AppBrand.textSecondary),
          ),
          if (onCopyDetails != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onCopyDetails,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Error Details'),
            ),
          ],
        ],
      ],
    );
  }
}
