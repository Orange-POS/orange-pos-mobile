import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final double borderWidth;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsets contentPadding;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.borderWidth = 2,
    this.textStyle,
    this.hintStyle,
    this.contentPadding = AppSpacing.fieldPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      style: textStyle ?? AppTextStyles.body,
      decoration: decoration(
        hintText: hintText,
        borderWidth: borderWidth,
        hintStyle: hintStyle,
        contentPadding: contentPadding,
      ),
    );
  }

  static InputDecoration decoration({
    String? hintText,
    double borderWidth = 2,
    TextStyle? hintStyle,
    EdgeInsets contentPadding = AppSpacing.fieldPadding,
  }) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.small,
      borderSide: BorderSide(color: AppBrand.primaryDark, width: borderWidth),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle:
          hintStyle ?? const TextStyle(fontSize: 16, color: Color(0xFF535353)),
      contentPadding: contentPadding,
      enabledBorder: border,
      focusedBorder: border,
      disabledBorder: border,
    );
  }
}
