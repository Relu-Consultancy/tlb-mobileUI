import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/format_events_screen.dart';
import 'package:tlb_mobile_ui/screens/format_programs_screen.dart';
import 'package:tlb_mobile_ui/screens/pace_classes_screen.dart';
import 'package:tlb_mobile_ui/widgets/format_circle_label.dart';

/// Selection on these rows is shown by growing the disc, but the row was
/// sized to the *unscaled* disc — so the grown one was clipped at the top by
/// the horizontal ListView's viewport, cutting a flat edge across the white
/// circle. Invisible on the events row (transparent artwork), obvious on the
/// classes and programs rows.
void main() {
  const discSize = 90.0;
  const fontSize = 11.0;

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pump();
  }

  /// The horizontal disc row — the first ListView on the screen.
  Rect rowRect(WidgetTester tester) =>
      tester.getRect(find.byType(ListView).first);

  final screens = <String, Widget>{
    'FormatEventsScreen': const FormatEventsScreen(initialFormatIndex: 0),
    'PaceClassesScreen': const PaceClassesScreen(initialPaceIndex: 0),
    'FormatProgramsScreen': const FormatProgramsScreen(initialFormatIndex: 0),
  };

  group('The selected disc is not clipped', () {
    screens.forEach((name, screen) {
      testWidgets('$name reserves room for the grown disc', (tester) async {
        await pump(tester, screen);

        // The row must be at least as tall as a grown disc plus its label,
        // or the top of the selected circle is cut off.
        final needed = FormatCircleLabel.rowHeight(
          tester.element(find.byType(ListView).first),
          discSize,
          fontSize,
        );
        expect(rowRect(tester).height, greaterThanOrEqualTo(needed - 0.5),
            reason: '$name row is shorter than a selected disc');
      });

      testWidgets('$name keeps the selected disc inside the row',
          (tester) async {
        await pump(tester, screen);

        // The selected disc is the first tile; its painted circle must sit
        // fully within the row's bounds.
        final row = rowRect(tester);
        final tile = tester.getRect(find.byType(OverflowBox).first);
        final grownTop =
            tile.center.dy - (discSize * FormatCircleLabel.selectedScale) / 2;

        expect(grownTop, greaterThanOrEqualTo(row.top - 0.5),
            reason: '$name clips the top of the selected disc');
      });
    });
  });

  group('FormatCircleLabel metrics', () {
    testWidgets('rowHeight allows for the selection growth', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final context = tester.element(find.byType(SizedBox));

      expect(
        FormatCircleLabel.rowHeight(context, discSize, fontSize),
        discSize * FormatCircleLabel.selectedScale +
            8 +
            FormatCircleLabel.boxHeight(context, fontSize),
      );
      // ...which is strictly more than sizing to the unscaled disc, the bug.
      expect(
        FormatCircleLabel.rowHeight(context, discSize, fontSize),
        greaterThan(
            discSize + 8 + FormatCircleLabel.boxHeight(context, fontSize)),
      );
    });
  });
}
