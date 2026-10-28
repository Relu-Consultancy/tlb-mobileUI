import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/screens/format_programs_screen.dart';
import 'package:tlb_mobile_ui/widgets/category_skeleton_card.dart';

/// The Programs tab's "Find Your Fit" discs were inert artwork — the Events
/// tab's formats and the Classes tab's paces both opened a browse screen, and
/// this one led nowhere. Same screen shape as those two, filtered on
/// program_format.
Future<void> _pump(WidgetTester tester, int index) async {
  tester.view.physicalSize = const Size(430, 900);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
      MaterialApp(home: FormatProgramsScreen(initialFormatIndex: index)));
  await tester.pump();
}

void main() {
  group('FormatProgramsScreen Tests', () {
    testWidgets('TC_S_FP_001 — opens on the disc that was tapped',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 1); // Camp Program
      expect(find.text('Camp Program'), findsWidgets);
      expect(find.text('Browse programs by fit'), findsOneWidget);
    });

    testWidgets('TC_S_FP_002 — the heading names the format on one line',
        (tester) async {
      // Disc labels wrap over two lines ("Batch\nProgram"); the heading
      // wants that as one.
      addTearDown(tester.view.reset);
      await _pump(tester, 0);
      expect(find.text('All Batch Program'), findsOneWidget);
    });

    testWidgets('TC_S_FP_003 — loads behind skeleton cards, not a spinner',
        (tester) async {
      // Same grid as the results, so the layout does not jump when they land.
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(430, 900);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
          const MaterialApp(home: FormatProgramsScreen(initialFormatIndex: 0)));
      expect(find.byType(CategorySkeletonCard), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('TC_S_FP_004 — the whole row is reachable from the header',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 0);

      // Every disc rides along, so switching format never means going back.
      // The row builds lazily, so the last one has to be scrolled to.
      await tester.dragUntilVisible(
        find.text('Recorded Program'),
        find.byType(ListView),
        const Offset(-120, 0),
      );
      await tester.pump();
      expect(find.text('Recorded Program'), findsOneWidget);
    });

    testWidgets('TC_S_FP_006 — tapping another disc switches the heading',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 0);
      expect(find.text('All Batch Program'), findsOneWidget);

      await tester.tap(find.text('Camp Program').first);
      await tester.pump();

      expect(find.text('All Camp Program'), findsOneWidget);
      expect(find.text('All Batch Program'), findsNothing);
    });

    testWidgets('TC_S_FP_005 — an out-of-range index is clamped, not crashed',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 99);
      expect(find.text('Browse programs by fit'), findsOneWidget);
    });
  });

  group('The disc artwork fills its circle', () {
    testWidgets('TC_S_FP_007 — the image covers the disc, no white ring',
        (tester) async {
      // The artwork is full-bleed illustration, drawn edge to edge in the
      // Find Your Fit row on the Programs tab. Insetting it and fitting by
      // `contain` left a white ring around every icon.
      addTearDown(tester.view.reset);
      await _pump(tester, 0);

      final image = tester.widget<Image>(
        find.descendant(of: find.byType(OverflowBox).first,
            matching: find.byType(Image)).first,
      );
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('TC_S_FP_008 — the artwork is as wide as the disc itself',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pump(tester, 0);

      final disc = find.descendant(
          of: find.byType(OverflowBox).first, matching: find.byType(Container));
      final image = find.descendant(
          of: find.byType(OverflowBox).first, matching: find.byType(Image));

      // Same width means no inset — a padded icon would be narrower.
      expect(
        tester.getSize(image.first).width,
        closeTo(tester.getSize(disc.first).width, 0.5),
      );
    });
  });

  group('Find Your Fit data', () {
    test('TC_D_FYF_001 — every disc carries a slug and an accent', () {
      for (final fit in DummyData.findYourFit) {
        expect(fit['formatSlug'], isA<String>(), reason: '${fit['label']}');
        expect(fit['accentColor'], isA<Color>(), reason: '${fit['label']}');
      }
    });

    test('TC_D_FYF_002 — the slugs are the API\'s program_format enum', () {
      // ProgramFormatEnum per /api/schema/ — one disc per value, so no format
      // is unreachable and none sends a value the backend rejects.
      const enumValues = {
        'batch',
        'short_term',
        'camp',
        'holiday',
        'regular',
        'weekend',
        'recorded',
      };
      final slugs =
          DummyData.findYourFit.map((f) => f['formatSlug'] as String).toSet();

      expect(slugs, enumValues);
      expect(slugs.length, DummyData.findYourFit.length,
          reason: 'two discs share a slug');
    });
  });
}
