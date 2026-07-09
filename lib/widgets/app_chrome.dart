import 'package:flutter/material.dart';

import '../theme/app_brand.dart';
import '../core/theme/app_spacing.dart';

import '../core/theme/app_text_styles.dart';

class AppChrome {
  static const EdgeInsets pagePadding = AppSpacing.pagePadding;

  static EdgeInsets scrollPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      pagePadding.left,
      pagePadding.top,
      pagePadding.right,
      MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
    );
  }

  static const double headerHeight = 48;
  static const double headerSideWidth = 48;
}

class AppHeader extends StatelessWidget {
  final String? title;
  final bool showBrand;
  final bool showProfile;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;

  const AppHeader({
    super.key,
    this.title,
    this.showBrand = false,
    this.showProfile = false,
    this.onBackPressed,
    this.onProfilePressed,
  });

  const AppHeader.brand({super.key, this.onProfilePressed})
    : title = null,
      showBrand = true,
      showProfile = true,
      onBackPressed = null;

  const AppHeader.title({super.key, required this.title, this.onBackPressed})
    : showBrand = false,
      showProfile = false,
      onProfilePressed = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppChrome.headerHeight,
      child: Row(
        children: [
          _HeaderLeading(showBrand: showBrand, onBackPressed: onBackPressed),
          Expanded(
            child: showBrand
                ? const SizedBox.shrink()
                : Text(
                    title ?? '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.screenTitle,
                  ),
          ),
          _HeaderTrailing(
            showProfile: showProfile,
            onProfilePressed: onProfilePressed,
          ),
        ],
      ),
    );
  }
}

class _HeaderLeading extends StatelessWidget {
  final bool showBrand;
  final VoidCallback? onBackPressed;

  const _HeaderLeading({required this.showBrand, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    if (showBrand) {
      return const _OrangeOneTitle();
    }

    return SizedBox(
      width: AppChrome.headerSideWidth,
      height: AppChrome.headerHeight,
      child: onBackPressed == null
          ? null
          : IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back),
              color: AppBrand.primary,
            ),
    );
  }
}

class _HeaderTrailing extends StatelessWidget {
  final bool showProfile;
  final VoidCallback? onProfilePressed;

  const _HeaderTrailing({
    required this.showProfile,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppChrome.headerSideWidth,
      height: AppChrome.headerHeight,
      child: showProfile
          ? IconButton.filledTonal(
              onPressed: onProfilePressed,
              icon: const Icon(Icons.person_outline),
              color: AppBrand.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppBrand.profileBackground,
              ),
            )
          : null,
    );
  }
}

class _OrangeOneTitle extends StatelessWidget {
  const _OrangeOneTitle();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Orange',
            style: TextStyle(
              color: AppBrand.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'ONE',
            style: TextStyle(
              color: AppBrand.textDarkGrey,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Powered By ',
              style: TextStyle(
                color: AppBrand.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'OrangePos',
              style: TextStyle(
                color: AppBrand.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
