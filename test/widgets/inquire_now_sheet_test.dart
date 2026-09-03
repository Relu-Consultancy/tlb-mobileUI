import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/inquire_now_sheet.dart';

import '../helpers/test_setup.dart';

Future<void> _openSheet(
  WidgetTester tester, {
  bool isVenue = false,
  bool isProgram = false,
}) async {
  await pumpTLBApp(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showInquireNow(
              context,
              listingId: 'l1',
              isVenue: isVenue,
              isProgram: isProgram,
            ),
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

    testWidgets('TC_W_IN_003 — an empty form will not submit', (tester) async {
      await _openSheet(tester, isVenue: true);

      await tester.tap(find.text('Send Enquiry'));
      await tester.pumpAndSettle();

      // Still on the form — validation blocked it before any request.
      expect(find.text('Inquire Now'), findsOneWidget);
      expect(find.text("Please enter the attendee's name."), findsOneWidget);
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

  // The backend cut all three enquiry endpoints down to a minimal shape on
  // 2026-09-03. `parent_name` and `area` are no longer fields on any of them,
  // so a form that still asks for them takes details off the customer that
  // the organiser will never receive.
  group('Inquire Now — trimmed field set', () {
    for (final type in const ['class', 'program', 'venue']) {
      testWidgets('TC_W_IN_006 — $type asks for no parent name or locality',
          (tester) async {
        await _openSheet(
          tester,
          isVenue: type == 'venue',
          isProgram: type == 'program',
        );

        expect(find.textContaining('parent'), findsNothing);
        expect(find.textContaining('guardian'), findsNothing);
        expect(find.textContaining('Locality'), findsNothing);
        expect(find.textContaining('locality'), findsNothing);
      });

      testWidgets('TC_W_IN_007 — $type asks for one name, phone and message',
          (tester) async {
        await _openSheet(
          tester,
          isVenue: type == 'venue',
          isProgram: type == 'program',
        );

        // The two section headers are Text.rich with a red '*' span, so
        // an exact match against the label alone never hits them.
        expect(find.textContaining('Attendee Details'), findsOneWidget);
        expect(find.textContaining('Message'), findsOneWidget);
        expect(find.text('Attendee name*'), findsOneWidget);
        expect(find.text('Mobile number*'), findsOneWidget);
      });
    }

    // Age is a field on the class and program endpoints (`student_age`) but
    // not on the venue one — hiring a space is not about a particular child.
    testWidgets('TC_W_IN_008 — a class enquiry asks for an age',
        (tester) async {
      await _openSheet(tester);
      expect(find.text('Select age*'), findsOneWidget);
    });

    testWidgets('TC_W_IN_009 — a program enquiry asks for an age',
        (tester) async {
      await _openSheet(tester, isProgram: true);
      expect(find.text('Select age*'), findsOneWidget);
    });

    testWidgets('TC_W_IN_010 — a venue enquiry does not ask for an age',
        (tester) async {
      await _openSheet(tester, isVenue: true);
      expect(find.text('Select age*'), findsNothing);

      await tester.tap(find.text('Send Enquiry'));
      await tester.pumpAndSettle();
      // ...and cannot be blocked by an age it never showed.
      expect(find.text('Please select an age.'), findsNothing);
    });

    testWidgets('TC_W_IN_011 — a class enquiry will not submit without an age',
        (tester) async {
      await _openSheet(tester);

      await tester.tap(find.text('Send Enquiry'));
      await tester.pumpAndSettle();

      expect(find.text('Please select an age.'), findsOneWidget);
    });
  });
}
