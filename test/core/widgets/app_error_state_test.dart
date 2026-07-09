import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_error_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppErrorState', () {
    testWidgets('renders simple error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorState(message: 'Something went wrong.')),
        ),
      );

      expect(find.text('Something went wrong.'), findsOneWidget);
    });

    testWidgets('renders boxed error with title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorState.box(
              title: 'Product Lookup Failed',
              message: 'Could not find product.',
            ),
          ),
        ),
      );

      expect(find.text('Product Lookup Failed'), findsOneWidget);
      expect(find.text('Could not find product.'), findsOneWidget);
    });

    testWidgets('renders details and copy action', (tester) async {
      var copied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorState.box(
              title: 'Request Failed',
              message: 'Server returned HTTP 500.',
              details: 'URL: https://example.com',
              onCopyDetails: () {
                copied = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('URL: https://example.com'), findsOneWidget);
      expect(find.text('Copy Error Details'), findsOneWidget);

      await tester.tap(find.text('Copy Error Details'));

      expect(copied, true);
    });
  });
}
