import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

@Preview(name: 'Login Screen - iPhone')
Widget loginScreenPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const _PhoneFrame(
      child: LoginScreen(),
    ),
  );
}

class _PhoneFrame extends StatelessWidget {
  final Widget child;

  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Center(
        child: SizedBox(
          width: 393,
          height: 852,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: child,
          ),
        ),
      ),
    );
  }
}