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

    // No HTTP is available in a widget test, so every taxonomy endpoint
    // fails — the same state a user sees offline. The section must say so and
    // offer a retry rather than rendering an empty "Category" heading, and it
    // must not take the rest of the sheet down with it.
    testWidgets('TC_S_SF_007 — an unloadable taxonomy degrades to a retry',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);

      expect(find.text("Categories couldn't be loaded"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // A heading with no chips under it would read as a broken filter.
      expect(find.text('Category'), findsNothing);
      expect(find.text('Subcategory'), findsNothing);
      // Everything else still works.
      expect(find.text('Age Group'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
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

  group('Search filters — price and distance', () {
    /// Scrolls the sheet until [label] is on screen; both new sections sit
    /// below the fold on a phone-sized viewport.
    Future<void> reveal(WidgetTester tester, String label) async {
      await tester.dragUntilVisible(
        find.text(label),
        find.byType(SingleChildScrollView).last,
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('TC_S_SF_008 — the sheet offers price bands', (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Price');

      expect(find.text('Price'), findsOneWidget);
      for (final band in ['Free', 'Under ₹500', 'Above ₹5,000']) {
        expect(find.text(band), findsOneWidget, reason: band);
      }
    });

    testWidgets('TC_S_SF_009 — the sheet offers distance options',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Distance');

      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Nearest first'), findsOneWidget);
      expect(find.text('Within 5 km'), findsOneWidget);
    });

    testWidgets('TC_S_SF_010 — a price band is single-select', (tester) async {
      // Two bands at once would describe a range no listing can sit in.
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Price');

      await tester.tap(find.text('Under ₹500'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('₹500 – ₹1,000'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('₹500 – ₹1,000'), findsOneWidget);
      expect(find.text('Under ₹500'), findsNothing);
    });

    testWidgets('TC_S_SF_011 — tapping the active band clears it',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Price');

      await tester.tap(find.text('Free'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Free'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Clear all'), findsNothing);
    });

    testWidgets('TC_S_SF_012 — both show as removable chips once applied',
        (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Price');
      await tester.tap(find.text('Under ₹500'));
      await tester.pumpAndSettle();
      await reveal(tester, 'Distance');
      await tester.tap(find.text('Within 5 km'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Under ₹500'), findsOneWidget);
      expect(find.text('Within 5 km'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('TC_S_SF_013 — Clear all drops them too', (tester) async {
      await _openSearch(tester);
      await _openFilters(tester);
      await reveal(tester, 'Price');
      await tester.tap(find.text('Under ₹500'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Clear all'), findsNothing);
      expect(find.text('Under ₹500'), findsNothing);
    });
  });
}
