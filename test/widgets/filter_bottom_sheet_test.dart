import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tlb_mobile_ui/core/app_theme.dart';
import 'package:tlb_mobile_ui/widgets/filter_bottom_sheet.dart';

/// The sheet's left rail lists "Sort by", "Filters" and "Categories". The rail
/// width scales linearly with the screen, but Responsive.sp stops shrinking
/// the font at 80% of its design size — so on a narrow phone the longest label
/// no longer fitted and wrapped, dropping the "s" of "Categories" onto a
/// second line.
///
/// These pump the sheet across the range of phone widths the app ships to and
/// assert every label stays on one line inside the rail.
void main() {
  /// Real device widths, narrowest first: Galaxy A01-class, common Android,
  /// the 393dp design base, and a large phone.
  const widths = <double>[320, 360, 393, 430];

  /// The rail's tab for [label] — the sidebar sits before the content panel
  /// in the Row, so the rail's copy of a label is always the first. Anchoring
  /// on AnimatedContainer (the tab's own background) keeps this test honest:
  /// it measures the text, not the particular widget used to fit it.
  Finder railTab(WidgetTester tester, String label) => find
      .ancestor(
        of: find.text(label).first,
        matching: find.byType(AnimatedContainer),
      )
      .first;

  RenderParagraph railLabel(WidgetTester tester, String label) {
    final finder = find.descendant(
      of: find.byType(AnimatedContainer),
      matching: find.text(label),
    );
    expect(finder, findsOneWidget, reason: 'no rail label for "$label"');
    return tester.renderObject<RenderParagraph>(finder);
  }

  Future<void> pumpSheet(WidgetTester tester, double width) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = Size(width * 3, 850 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: FilterBottomSheet(
            sortOptions: ['Top Picks', 'Price- Low to High'],
            filterOptions: ['Online'],
            categoryOptions: ['Arts & Crafts'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('FilterBottomSheet — the rail labels survive every resolution', () {
    for (final width in widths) {
      testWidgets('TC_W_FBS_${width.toInt()} — no label wraps at ${width.toInt()}dp',
          (tester) async {
        await pumpSheet(tester, width);

        // All three share one style in one rail, so a label that wrapped
        // would stand out as roughly twice as tall as the others. "Filters"
        // is short enough that it cannot wrap at any of these widths, which
        // makes it the reference height.
        final oneLine = railLabel(tester, 'Filters').size.height;
        for (final label in ['Sort by', 'Categories']) {
          expect(
            railLabel(tester, label).size.height,
            closeTo(oneLine, 0.5),
            reason: '"$label" wrapped onto a second line at ${width}dp',
          );
        }
      });

      testWidgets('TC_W_FBS_${width.toInt()}F — "Categories" fits inside the '
          'rail at ${width.toInt()}dp', (tester) async {
        await pumpSheet(tester, width);

        // The tab's own box is the rail's full width; the text must stay
        // inside it rather than being clipped away at the divider.
        final tab = tester.getRect(railTab(tester, 'Categories'));
        final text = railLabel(tester, 'Categories').size;
        expect(text.width, lessThanOrEqualTo(tab.width + 0.5));
      });
    }

    testWidgets('TC_W_FBS_TAP — the rail still switches panels', (tester) async {
      // Wrapping the label in a FittedBox must not cost the tab its tap target.
      await pumpSheet(tester, 320);

      await tester.tap(find.text('Categories').first);
      await tester.pumpAndSettle();

      expect(find.text('Arts & Crafts'), findsOneWidget);
    });
  });
}
