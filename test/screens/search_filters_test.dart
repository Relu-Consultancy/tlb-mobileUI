import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/search_screen.dart';

import '../helpers/test_setup.dart';

Future<void> _openSearch(WidgetTester tester) async {
  await pumpTLBApp(tester, const SearchScreen());
  await tester.pumpAndSettle();
}

Future<void> _openFilters(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.tune).first);
  await tester.pumpAndSettle();
}

void main() {
  group('Search filters', () {
    testWidgets('TC_S_SF_001 — the sheet offers a listing-type picker',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      expect(find.text('Show'), findsOneWidget);
      // Both the screen's chip row and the sheet's picker render these.
      for (final t in ['Events', 'Classes', 'Programs', 'Venues']) {
        expect(find.text(t), findsWidgets, reason: t);
      }
    });

    // Nothing is selected initially, so the row must not take up space.
    testWidgets('TC_S_SF_002 — no active-filter row when nothing is selected',
        (tester) async {
      await _openSearch(tester);
      expect(find.text('Clear all'), findsNothing);
    });

    testWidgets('TC_S_SF_003 — a selected filter appears as a removable chip',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      await tester.tap(find.text('6-8 years'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      // Shown outside the sheet now, with a Clear all beside it.
      expect(find.text('6-8 years'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('TC_S_SF_004 — the chip\'s cross removes just that filter',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      await tester.tap(find.text('6-8 years'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9-12 years'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.text('6-8 years'), findsNothing);
      expect(find.text('9-12 years'), findsOneWidget);
    });

    testWidgets('TC_S_SF_005 — Clear all empties the row', (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      await tester.tap(find.text('6-8 years'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Clear all'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // The Location section (City / Area dropdowns) was removed from the
    // sheet — it was never wired to the search results in the first place.
    testWidgets('TC_S_SF_006 — the Location section is gone', (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      expect(find.text('Location'), findsNothing);
      expect(find.text('City'), findsNothing);
      expect(find.text('Area/Locality'), findsNothing);
      // Neighbouring sections still render either side of where it was.
      expect(find.text('Mode'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
    });
  });
}
