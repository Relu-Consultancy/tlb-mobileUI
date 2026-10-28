import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/screens/pace_classes_screen.dart';
import 'package:tlb_mobile_ui/widgets/category_skeleton_card.dart';

Future<void> _pump(WidgetTester tester, int index) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
      MaterialApp(home: PaceClassesScreen(initialPaceIndex: index)));
  await tester.pump();
}

void main() {
  group('PaceClassesScreen Tests', () {
    testWidgets('TC_S_PC_001 — opens on the pace that was tapped',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 1); // Monthly Programs
      expect(find.text('Monthly Programs'), findsWidgets);
      expect(find.text('Browse classes by pace'), findsOneWidget);
    });

    testWidgets('TC_S_PC_002 — the heading names the pace', (tester) async {
      // Disc labels wrap over two lines; the heading wants one.
      addTearDown(tester.view.reset);
      await _pump(tester, 0); // Weekly Classes
      expect(find.text('All Weekly Classes'), findsOneWidget);
    });

    testWidgets('TC_S_PC_003 — loads behind skeleton cards, not a spinner',
        (tester) async {
      // Same grid as the results, so the layout does not jump when they land.
      // Asserted on the very first frame: with no network under test the
      // fetch fails almost immediately, and a further pump would already
      // show the error state.
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
          const MaterialApp(home: PaceClassesScreen(initialPaceIndex: 0)));
      expect(find.byType(CategorySkeletonCard), findsWidgets);
    });

    testWidgets('TC_S_PC_004 — every pace is reachable by scrolling the row',
        (tester) async {
      // The row is a lazy ListView, so the far end is not built until it is
      // scrolled to — reaching all of them is the thing worth asserting.
      addTearDown(tester.view.reset);
      await _pump(tester, 0);
      final seen = <String>{};
      for (var i = 0; i < 8; i++) {
        for (final p in DummyData.pickYourPace) {
          final label = (p['label'] as String).replaceAll('\n', ' ');
          if (find.text(label).evaluate().isNotEmpty) seen.add(label);
        }
        await tester.drag(find.byType(ListView).first, const Offset(-200, 0));
        await tester.pump();
      }
      expect(seen.length, DummyData.pickYourPace.length,
          reason: 'only reached $seen');
    });

    testWidgets('TC_S_PC_005 — tapping another pace re-heads the list',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 0);
      expect(find.text('All Weekly Classes'), findsOneWidget);

      await tester.tap(find.text('Bootcamps').first);
      await tester.pump();
      expect(find.text('All Bootcamps'), findsOneWidget);
      expect(find.text('All Weekly Classes'), findsNothing);
    });

    testWidgets('TC_S_PC_006 — an out-of-range index is clamped',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 99);
      expect(tester.takeException(), isNull);
      final last = (DummyData.pickYourPace.last['label'] as String)
          .replaceAll('\n', ' ');
      expect(find.text('All $last'), findsOneWidget);
    });

    testWidgets('TC_S_PC_007 — every pace carries a slug to filter on',
        (tester) async {
      // The screen sends this as the classes endpoint's `format` param; a
      // missing one would silently fetch the whole catalogue.
      for (final p in DummyData.pickYourPace) {
        final slug = p['paceSlug'] as String?;
        expect(slug, isNotNull, reason: '${p['label']} has no paceSlug');
        expect(slug, isNotEmpty);
      }
    });
  });
}
