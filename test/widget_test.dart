import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/app/inventory_tracker_app.dart';

void main() {
  testWidgets('Inventory Tracker app opens login screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const InventoryTrackerApp());

    await tester.pumpAndSettle();

    expect(find.text('Inventory Tracker'), findsOneWidget);
    expect(find.text('Tap to Scan Login QR'), findsOneWidget);
    expect(find.text('Scan the QR code shown in Odoo POS.'), findsOneWidget);
  });
}
