import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/screens/location_screen.dart';

import '../helpers/test_setup.dart';

/// The location picker's search box. It used to commit only through the
/// keyboard's search key, so dismissing the keyboard (a swipe, or Android
/// back) left the typed city with no way to be chosen at all — and typing
/// filtered nothing, so the city was not tappable either.
///
/// Nothing here touches the keyboard: that is the point. Every test commits
/// the search the way a customer can once the keyboard is gone.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocationState().resetForTest();
  });

  /// Opens the picker on a route that can be popped, which is what selecting
  /// a city does.
  Future<void> openPicker(WidgetTester tester) async {
    await pumpTLBApp(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationScreen()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  /// The commit button in the search bar.
  final searchButton = find.byIcon(Icons.arrow_forward_rounded);

  testWidgets('TC_S_LOC_001 — typing filters both city lists live',
      (tester) async {
    await openPicker(tester);
    expect(find.text('Popular Cities'), findsOneWidget);
    expect(find.text('Mumbai'), findsNWidgets(2), reason: 'popular + all');

    await type(tester, 'pune');
    // Pune is both popular and listed, so it survives in both sections.
    expect(find.text('Pune'), findsNWidgets(2));
    expect(find.text('Mumbai'), findsNothing);
    expect(find.text('Kolkata'), findsNothing);
    expect(find.text('Matching Cities'), findsOneWidget);
    expect(find.text('All Cities'), findsNothing);
  });

  testWidgets('TC_S_LOC_002 — the search button appears with the text and '
      'selects the typed city', (tester) async {
    await openPicker(tester);
    // Nothing typed: nothing to submit or clear.
    expect(searchButton, findsNothing);

    await type(tester, 'Kolkata');
    expect(searchButton, findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);

    // Committed without the keyboard's search key ever being involved.
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(LocationState().selectedCity.value, 'Kolkata');
    expect(LocationState().cityPickedByHand, isTrue);
    expect(LocationState().hasCoordinates, isFalse,
        reason: 'a typed city has no GPS fix behind it');
    expect(find.byType(LocationScreen), findsNothing, reason: 'picker closed');
  });

  testWidgets('TC_S_LOC_003 — a query that narrows to one city takes it, and '
      'a Delhi alias resolves', (tester) async {
    await openPicker(tester);
    await type(tester, 'pun');
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(LocationState().selectedCity.value, 'Pune');

    LocationState().resetForTest();
    await openPicker(tester);
    // Not in the list by that name, but it is the same place.
    await type(tester, 'Gurgaon');
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(LocationState().selectedCity.value, 'Delhi NCR');
  });

  testWidgets('TC_S_LOC_004 — a city the app does not cover is refused, not '
      'set verbatim', (tester) async {
    await openPicker(tester);
    await type(tester, 'Narnia');
    // No match in either list, so the page says so rather than going blank.
    expect(find.text('No cities match "Narnia"'), findsOneWidget);
    expect(find.text('Popular Cities'), findsNothing);

    await tester.tap(searchButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    // Taking free text used to set the location to whatever was typed, which
    // left Home permanently on "we don't serve this location".
    expect(LocationState().hasCity, isFalse);
    expect(find.text('We\'re not in "Narnia" yet. Pick a city from the list.'),
        findsOneWidget);
    expect(find.byType(LocationScreen), findsOneWidget, reason: 'stays open');
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('TC_S_LOC_005 — clearing brings the full list back',
      (tester) async {
    await openPicker(tester);
    await type(tester, 'goa');
    expect(find.text('Mumbai'), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(searchButton, findsNothing);
    expect(find.text('Mumbai'), findsNWidgets(2));
    expect(find.text('All Cities'), findsOneWidget);
    expect(LocationState().hasCity, isFalse, reason: 'clearing selects nothing');
  });

  testWidgets('TC_S_LOC_006 — a filtered city can simply be tapped',
      (tester) async {
    await openPicker(tester);
    await type(tester, 'hyder');
    // The list is the other half of the fix: the match is on screen, so it
    // can be picked without submitting anything.
    await tester.tap(find.text('Hyderabad').last);
    await tester.pumpAndSettle();
    expect(LocationState().selectedCity.value, 'Hyderabad');
  });
}
