# UI Design System

This document defines the current UI foundation for OrangeONE.

## Goal

The UI system keeps the app consistent, fast to use, and easier to maintain.

Design priorities:

1. Clear screens for heavy users.
2. Large tap targets.
3. Consistent OrangeONE branding.
4. Shared widgets instead of repeated screen styling.
5. Responsive layouts with no overflow.
6. Simple future replacement of colors, spacing, and branding assets.

## Theme Tokens

Theme tokens live in `lib/core/theme/`.

Current token files:

- `app_spacing.dart`
- `app_radius.dart`
- `app_text_styles.dart`

Use these instead of hardcoding common spacing, radius, and text styles.

Common tokens:

- `AppSpacing.pagePadding`
- `AppSpacing.fieldPadding`
- `AppRadius.heroCard`
- `AppRadius.pillShape`
- `AppTextStyles.pageTitle`
- `AppTextStyles.button`
- `AppTextStyles.error`

## Shared Widgets

Shared UI widgets live in `lib/core/widgets/`.

Current widgets:

- `app_badge.dart`
- `app_button.dart`
- `app_error_state.dart`
- `app_surface.dart`
- `app_text_field.dart`

## Widget Usage

Use `AppButton` for primary full-width actions.

Used for:

- Update Price
- Edit Name & Tax
- Add New Product

Use `AppTextField` for form input fields.

Used for:

- Product name
- Product price
- New price

Use `AppErrorState` for inline and boxed errors.

Supported modes:

- Simple inline message
- Boxed message
- Boxed message with diagnostic details and copy action

Use `AppSurface` for soft orange cards with shadow.

Used for:

- Login scan card
- Scanner card
- Product name card

Use `AppBadge` for pill-style labels.

Used for:

- Demo Mode
- Demo Product

## Responsive Checks

Responsive smoke tests live in `test/ui/responsive_smoke_test.dart`.

They currently validate:

- LoginScreen
- ScannerScreen
- ProductScreen

These tests should stay green before release.

## Rules For Future UI Work

1. Do not add repeated `FilledButton` styling inside screens.
2. Do not create local `_OrangeTextField` widgets inside screens.
3. Do not duplicate soft orange card decoration in screens.
4. Do not duplicate pill/badge styling in screens.
5. Add or extend shared widgets first.
6. Run responsive tests after layout changes.
7. Keep heavy-user flows short and readable.