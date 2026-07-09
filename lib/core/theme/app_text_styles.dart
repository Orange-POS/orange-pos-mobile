import 'package:flutter/material.dart';

import '../../theme/app_brand.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle pageTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppBrand.textDarkGrey,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppBrand.textDarkGrey,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppBrand.textDarkGrey,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppBrand.textDarkGrey,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle error = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w600,
  );
}
