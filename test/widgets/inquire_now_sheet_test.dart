import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/inquire_now_sheet.dart';

import '../helpers/test_setup.dart';

Future<void> _openSheet(WidgetTester tester, {bool isVenue = false}) async {
  await pumpTLBApp(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () =>
                showInquireNow(context, listingId: 'l1', isVenue: isVenue),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('Inquire Now form', () {
    // Locality and Message were labelled "(Optional)" but an enquiry is not
    // actionable without them.
    testWidgets('TC_W_IN_001 — no section is labelled Optional',
        (tester) async {
      await _openSheet(tester, isVenue: true);
      expect(find.textContaining('Optional'), findsNothing);
    });

    testWidgets('TC_W_IN_002 — Locality and Message are still shown',
        (tester) async {
      await _openSheet(tester, isVenue: true);
      expect(find.textContaining('Locality / Area'), findsOneWidget);
      expect(find.textContaining('Message'), findsOneWidget);
    });

    testWidgets('TC_W_IN_003 — an empty form will not submit', (tester) async {
      await _openSheet(tester, isVenue: true);

      await tester.tap(find.text('Send Enquiry'));
      await tester.pumpAndSettle();

      // Still on the form — validation blocked it before any request.
      expect(find.text('Inquire Now'), findsOneWidget);
      expect(find.text('Please enter your locality.'), findsOneWidget);
      expect(find.text('Please enter a short message.'), findsOneWidget);
    });

    // Previously Message was only required on programs, so a venue enquiry
    // could be sent with no message at all.
    testWidgets('TC_W_IN_004 — a venue enquiry demands a message too',
        (tester) async {
      await _openSheet(tester, isVenue: true);

      await tester.tap(find.text('Send Enquiry'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a short message.'), findsOneWidget);
    });

    testWidgets('TC_W_IN_005 — the mobile field shows +91', (tester) async {
      await _openSheet(tester, isVenue: true);
      expect(find.text('+91'), findsOneWidget);
    });
  });
}
