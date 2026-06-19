import 'package:flutter/material.dart';

import '../theme/app_brand.dart';
import 'app_chrome.dart';

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
          padding: AppChrome.pagePadding,
          child: Column(
            children: [
              AppHeader.title(title: title),
              const SizedBox(height: 12),
              Expanded(child: child),
              const SizedBox(height: 12),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
