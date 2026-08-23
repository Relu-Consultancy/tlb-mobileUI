import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/widgets/empty_location_widget.dart';

import '../helpers/test_setup.dart';

void main() {
  // The singleton is shared across tests, so put it back to a served city.
  tearDown(() => LocationState().setCity('Mumbai'));

  group('LocationGate', () {
    testWidgets('TC_W_LG_001 — a served city shows the tab content',
        (tester) async {
      LocationState().setCity('Mumbai');
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: LocationGate(
            emptyTitle: 'No events here yet',
            child: Text('tab content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('tab content'), findsOneWidget);
      expect(find.text('No events here yet'), findsNothing);
    });

    // The bug: only Home checked this, so other tabs rendered as though they
    // simply had nothing on, with no explanation and no way forward.
    testWidgets('TC_W_LG_002 — an unserved city replaces the content',
        (tester) async {
      LocationState().setCity('Agra');
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: LocationGate(
            emptyTitle: 'No events here yet',
            child: Text('tab content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('tab content'), findsNothing);
      expect(find.text('No events here yet'), findsOneWidget);
      expect(find.text('Change Location'), findsOneWidget);
    });

    testWidgets('TC_W_LG_003 — each tab names its own content', (tester) async {
      LocationState().setCity('Agra');
      for (final title in [
        'No classes here yet',
        'No programs here yet',
        'No venues here yet',
      ]) {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: LocationGate(
              emptyTitle: title,
              child: const Text('tab content'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });

    // Changing the city anywhere must update every gated tab, without each
    // screen keeping its own listener.
    testWidgets('TC_W_LG_004 — reacts to the city changing beneath it',
        (tester) async {
      LocationState().setCity('Agra');
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: LocationGate(
            emptyTitle: 'No events here yet',
            child: Text('tab content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('tab content'), findsNothing);

      LocationState().setCity('Pune');
      await tester.pumpAndSettle();

      expect(find.text('tab content'), findsOneWidget);
      expect(find.text('No events here yet'), findsNothing);
    });
  });
}
