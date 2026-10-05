import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/widgets/app_loader.dart';
import 'package:tlb_mobile_ui/widgets/empty_location_widget.dart';

import '../helpers/test_setup.dart';

void main() {
  final state = LocationState();

  setUp(() {
    state.selectedCity.value = '';
    state.resolvingLocation.value = false;
  });

  // The singleton is shared across tests, so put it back to a served city.
  tearDown(() {
    state.resolvingLocation.value = false;
    state.setCity('Mumbai');
  });

  group('Location not selected', () {
    testWidgets('TC_W_LNS_001 — shows the design copy and a Go to Location CTA',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: EmptyLocationWidget(onDark: true, notSelected: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Location not selected'), findsOneWidget);
      expect(find.textContaining('Please select from location'), findsOneWidget);
      expect(find.text('Go to Location'), findsOneWidget);
      // Not the unserved-city copy.
      expect(find.text('Change Location'), findsNothing);
      expect(find.textContaining("We're not currently serving"), findsNothing);
    });

    testWidgets('TC_W_LNS_002 — a loader replaces it while permission is asked',
        (tester) async {
      state.resolvingLocation.value = true;
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: EmptyLocationWidget(onDark: true, notSelected: true),
        ),
      );
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);
      expect(find.text('Location not selected'), findsNothing);

      state.resolvingLocation.value = false;
      await tester.pumpAndSettle();
      expect(find.text('Location not selected'), findsOneWidget);
    });

    testWidgets('TC_W_LNS_003 — an unserved city keeps its own copy',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: EmptyLocationWidget(onDark: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change Location'), findsOneWidget);
      expect(find.text('Location not selected'), findsNothing);
    });

    testWidgets('TC_W_LNS_004 — other tabs show it too when no city is set',
        (tester) async {
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
      expect(find.text('Location not selected'), findsOneWidget);
      expect(find.text('No events here yet'), findsNothing);
    });
  });
}
