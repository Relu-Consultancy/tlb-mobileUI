import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlb_mobile_ui/providers/location_state.dart';
import 'package:tlb_mobile_ui/screens/search_screen.dart';
import 'package:tlb_mobile_ui/sections/home_header.dart';

import '../helpers/test_setup.dart';

/// The home header's search bar is a facade — the whole pill opens
/// [SearchScreen]. It used to paint a filter glyph at its trailing edge, which
/// could never be a button: the tap target is the entire bar, so tapping the
/// glyph merely opened the search screen like tapping anywhere else. Filtering
/// belongs on the search screen, next to the results it narrows.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocationState().resetForTest();
  });

  for (final onDark in [false, true]) {
    final variant = onDark ? 'dark' : 'light';

    testWidgets('TC_W_HSB_001 — the $variant search bar shows no filter glyph',
        (tester) async {
      await pumpTLBApp(tester, Scaffold(body: HomeHeader(onDark: onDark)));
      await tester.pump();
      expect(find.byIcon(Icons.search), findsOneWidget,
          reason: 'the bar still reads as a search bar');
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
      expect(find.byIcon(Icons.filter_list), findsNothing);
      expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
    });
  }

  testWidgets('TC_W_HSB_002 — tapping the bar opens the search screen, which '
      'is where filtering lives', (tester) async {
    await pumpTLBApp(tester, const Scaffold(body: HomeHeader(onDark: true)));
    await tester.pump();
    await tester.tap(find.text('Search...'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    // The search screen's own filter entry point, which is a real button.
    expect(find.byIcon(Icons.tune), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
