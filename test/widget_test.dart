import 'package:field_log_application/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ranger can save a sighting to the local queue', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FieldLogApp());

    expect(find.text('Field Log'), findsOneWidget);
    expect(find.text('2 pending'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('speciesField')), 'Giraffe');
    await tester.enterText(find.byKey(const Key('countField')), '3');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Browsing near the ridge line.',
    );
    await tester.ensureVisible(find.byKey(const Key('saveLogButton')));
    await tester.tap(find.byKey(const Key('saveLogButton')));
    await tester.pumpAndSettle();

    expect(find.text('Giraffe'), findsOneWidget);
    expect(find.text('3 pending'), findsOneWidget);
    expect(
      find.text('Log saved offline and queued for end-of-shift sync.'),
      findsOneWidget,
    );
  });
}
