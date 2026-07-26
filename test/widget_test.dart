// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_mutashibihat_app/src/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MutashabihatApp());

    // Verify the app builds without errors
    expect(find.byType(MutashabihatApp), findsOneWidget);
  });
}
