import 'package:flutter/material.dart';

class AppSnackBar {
  const AppSnackBar._();

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
