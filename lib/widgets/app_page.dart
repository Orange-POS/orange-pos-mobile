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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 42),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(leadingIcon, size: 16),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.black12,
                    child: IconButton(
                      icon: const Icon(Icons.person_outline),
                      color: Colors.black,
                      onPressed: onProfilePressed,
                    ),
                  ),
                ],
              ),
              Expanded(child: child),
              const Text(
                'Powered By OrangePos',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}