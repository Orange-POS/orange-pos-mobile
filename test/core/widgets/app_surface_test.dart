import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/app_surface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSurface', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppSurface(child: Text('Surface content'))),
        ),
      );

      expect(find.text('Surface content'), findsOneWidget);
    });

    testWidgets('applies width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSurface(width: 120, height: 80, child: SizedBox.shrink()),
          ),
        ),
      );

      final surface = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppSurface),
          matching: find.byType(Container),
        ),
      );

      expect(surface.constraints?.maxWidth, 120);
      expect(surface.constraints?.maxHeight, 80);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppSurface(
              padding: EdgeInsets.all(16),
              child: Text('Padded'),
            ),
          ),
        ),
      );

      final surface = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppSurface),
          matching: find.byType(Container),
        ),
      );

      expect(surface.padding, const EdgeInsets.all(16));
    });
  });
}
