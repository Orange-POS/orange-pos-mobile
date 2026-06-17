import 'package:flutter/material.dart';

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
              const Text(
                'Powered by OrangePOS',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                  Icon(leadingIcon, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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
              color: Colors.black,
              style: IconButton.styleFrom(backgroundColor: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }
}
