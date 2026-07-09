import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_badge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBadge', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge(label: 'Demo Mode')),
        ),
      );

      expect(find.text('Demo Mode'), findsOneWidget);
    });

    testWidgets('uses compact container styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge(label: 'Demo Product')),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppBadge),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      );
    });
  });
}
