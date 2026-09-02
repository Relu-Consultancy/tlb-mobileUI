import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';

import '../helpers/test_setup.dart';

const _kLongAddress =
    '4W83+V63, Orchard Ave, MHADA Colony, Powai, Mumbai, Maharashtra 400076, India';

void main() {
  group('DetailLocationRow Tests', () {
    testWidgets('TC_W_DLR_001 — shows the address and a navigate button',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: 'Mumbai', onNavigate: () {})),
      );
      expect(find.text('Mumbai'), findsOneWidget);
      expect(find.byIcon(Icons.near_me), findsOneWidget);
    });

    testWidgets('TC_W_DLR_002 — a short address shows no See more',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: 'Mumbai', onNavigate: () {})),
      );
      expect(find.text('See more'), findsNothing);
    });

    testWidgets('TC_W_DLR_003 — a long address collapses behind See more',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: _kLongAddress, onNavigate: () {})),
      );
      expect(find.text('See more'), findsOneWidget);
      final text = tester.widget<Text>(find.text(_kLongAddress));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('TC_W_DLR_004 — collapsed, it stays one line tall',
        (tester) async {
      // The whole point of putting "See more" inline rather than beneath the
      // address: this row must match the height of the date/time row under it.
      await pumpTLBApp(
        tester,
        Scaffold(
          body: Column(children: [
            DetailLocationRow(text: _kLongAddress, onNavigate: () {}),
            DetailLocationRow(text: 'Mumbai', onNavigate: () {}),
          ]),
        ),
      );
      final heights = tester
          .widgetList<DetailLocationRow>(find.byType(DetailLocationRow))
          .map((w) => tester.getSize(find.byWidget(w)).height)
          .toList();
      expect(heights[0], heights[1]);
    });

    testWidgets('TC_W_DLR_005 — See more reveals the full address',
        (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: _kLongAddress, onNavigate: () {})),
      );
      await tester.tap(find.text('See more'));
      await tester.pumpAndSettle();

      expect(find.text('See less'), findsOneWidget);
      expect(find.text('See more'), findsNothing);
      final text = tester.widget<Text>(find.text(_kLongAddress));
      expect(text.maxLines, isNull);
    });

    testWidgets('TC_W_DLR_006 — See less collapses it again', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: _kLongAddress, onNavigate: () {})),
      );
      await tester.tap(find.text('See more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See less'));
      await tester.pumpAndSettle();
      expect(find.text('See more'), findsOneWidget);
    });

    testWidgets('TC_W_DLR_007 — tapping the arrow runs the navigate action',
        (tester) async {
      var taps = 0;
      await pumpTLBApp(
        tester,
        Scaffold(
          body: DetailLocationRow(text: 'Mumbai', onNavigate: () => taps++),
        ),
      );
      await tester.tap(find.byIcon(Icons.near_me));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('TC_W_DLR_008 — online listings get no navigate button',
        (tester) async {
      // There is nowhere to route to, so the button is omitted rather than
      // shown inert.
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: DetailLocationRow(
              text: 'Online', icon: Icons.videocam_outlined),
        ),
      );
      expect(find.byIcon(Icons.near_me), findsNothing);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('TC_W_DLR_009 — the navigate button is labelled for a11y',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTLBApp(
        tester,
        Scaffold(body: DetailLocationRow(text: 'Mumbai', onNavigate: () {})),
      );
      expect(find.bySemanticsLabel('Get directions'), findsOneWidget);
      handle.dispose();
    });
  });
}
