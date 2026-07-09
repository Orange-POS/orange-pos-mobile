import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_radius.dart';
import 'package:flutter_app/core/theme/app_spacing.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/theme/app_brand.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSpacing', () {
    test('keeps common spacing values stable', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 12);
      expect(AppSpacing.lg, 16);
      expect(AppSpacing.xl, 20);
      expect(AppSpacing.xxl, 24);
    });

    test('keeps page padding stable', () {
      expect(AppSpacing.pagePadding, const EdgeInsets.fromLTRB(20, 19, 20, 10));
    });

    test('keeps field and error padding stable', () {
      expect(
        AppSpacing.fieldPadding,
        const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      );
      expect(AppSpacing.errorPadding, const EdgeInsets.all(14));
    });
  });

  group('AppRadius', () {
    test('keeps radius values stable', () {
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 10);
      expect(AppRadius.lg, 12);
      expect(AppRadius.xl, 24);
      expect(AppRadius.xxl, 49);
      expect(AppRadius.pill, 999);
    });
  });

  group('AppTextStyles', () {
    test('keeps page title style stable', () {
      expect(AppTextStyles.pageTitle.fontSize, 36);
      expect(AppTextStyles.pageTitle.fontWeight, FontWeight.w800);
      expect(AppTextStyles.pageTitle.color, AppBrand.textDarkGrey);
    });

    test('keeps button style stable', () {
      expect(AppTextStyles.button.fontSize, 16);
      expect(AppTextStyles.button.fontWeight, FontWeight.w800);
    });

    test('keeps error style stable', () {
      expect(AppTextStyles.error.color, Colors.red);
      expect(AppTextStyles.error.fontWeight, FontWeight.w600);
    });
  });
}
