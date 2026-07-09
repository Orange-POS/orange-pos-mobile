import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';
import '../theme/app_radius.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color color;
  final Color? shadowColor;
  final double blurRadius;
  final Offset shadowOffset;

  const AppSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.color = const Color(0xFFFEF6EE),
    this.shadowColor,
    this.blurRadius = 24,
    this.shadowOffset = const Offset(0, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? AppBrand.primaryDark).withValues(
              alpha: 0.18,
            ),
            blurRadius: blurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}
