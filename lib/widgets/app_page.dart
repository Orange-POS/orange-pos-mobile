import 'package:flutter/material.dart';

import '../theme/app_brand.dart';

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? leadingIcon;
  final VoidCallback? onProfilePressed;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.leadingIcon,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
          child: Column(
            children: [
              _AppHeader(
                title: title,
                leadingIcon: leadingIcon,
                onProfilePressed: onProfilePressed,
              ),
              const SizedBox(height: 12),
              Expanded(child: child),
              const SizedBox(height: 12),
              const _AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onProfilePressed;

  const _AppHeader({
    required this.title,
    required this.leadingIcon,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18, color: AppBrand.primary),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppBrand.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton.filledTonal(
              onPressed: onProfilePressed,
              icon: const Icon(Icons.person_outline),
              color: AppBrand.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppBrand.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppBrand.orangePosLogo,
      width: 110,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Powered by OrangePOS',
          style: TextStyle(
            fontSize: 12,
            color: AppBrand.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
