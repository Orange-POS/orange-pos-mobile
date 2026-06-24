import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/app/inventory_tracker_app.dart';

void main() {
  testWidgets('OrangeONE app opens login screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const InventoryTrackerApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Tap to Scan'), findsOneWidget);
    expect(find.textContaining('OrangePos'), findsOneWidget);
  });
}
