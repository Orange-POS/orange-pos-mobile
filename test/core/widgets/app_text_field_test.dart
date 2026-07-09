import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders hint text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              hintText: 'Product name',
            ),
          ),
        ),
      );

      expect(find.text('Product name'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('updates controller when text is entered', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(controller: controller, hintText: 'Price'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '12.50');

      expect(controller.text, '12.50');

      controller.dispose();
    });

    testWidgets('can be disabled', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              hintText: 'Disabled',
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);

      controller.dispose();
    });

    testWidgets('applies keyboard and action configuration', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              hintText: 'Amount',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.number);
      expect(textField.textInputAction, TextInputAction.done);

      controller.dispose();
    });
  });
}
