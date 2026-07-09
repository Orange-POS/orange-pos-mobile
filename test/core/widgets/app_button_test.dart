import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders label and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Update Price',
              icon: Icons.sell,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Update Price'), findsOneWidget);
      expect(find.byIcon(Icons.sell), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Save',
              icon: Icons.check,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));

      expect(tapped, true);
    });

    testWidgets('shows loading indicator and disables tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Saving...',
              icon: Icons.save,
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.save), findsNothing);

      await tester.tap(find.byType(AppButton));

      expect(tapped, false);
    });

    testWidgets('can hide chevron', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Add Product',
              icon: Icons.add,
              showChevron: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });
}
