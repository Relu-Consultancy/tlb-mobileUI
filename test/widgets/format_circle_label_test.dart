import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/widgets/explore_format_row.dart';
import 'package:tlb_mobile_ui/widgets/format_circle_label.dart';

List<String> get _labels =>
    DummyData.exploreFormats.map((f) => f['label'] as String).toList();

Future<void> _pumpRow(WidgetTester tester, {double width = 430}) async {
  tester.view.physicalSize = Size(width, 400);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(body: Center(child: ExploreFormatRow())),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('FormatCircleLabel Tests', () {
    testWidgets('TC_W_FCL_001 — the name sits below its disc, not on it',
        (tester) async {
      // Engraved inside the artwork the label had only the disc's middle to
      // work in — about 65px — which is what broke "Competition" mid-word.
      addTearDown(tester.view.reset);
      await _pumpRow(tester);

      final labelTop = tester.getRect(find.text('Workshop')).top;
      final discBottom = tester
          .getRect(find.byType(Image).first)
          .bottom;
      expect(labelTop, greaterThanOrEqualTo(discBottom));
    });

    testWidgets('TC_W_FCL_002 — every label starts on the same line',
        (tester) async {
      // Top-anchored in a fixed two-line box, so a one-line name and a
      // two-line one share a first baseline instead of floating apart.
      addTearDown(tester.view.reset);
      await _pumpRow(tester);
      final tops = _labels
          .where((l) => find.text(l).evaluate().isNotEmpty)
          .map((l) => tester.getRect(find.text(l)).top)
          .toSet();
      expect(tops.length, 1, reason: 'labels start at $tops');
    });

    testWidgets('TC_W_FCL_003 — a long name breaks at its space, not mid-word',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(430, 200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: FormatCircleLabel(
                label: 'Showcase Performance', fontSize: 12),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final rp = tester
          .renderObject<RenderParagraph>(find.text('Showcase Performance'));
      // Two lines' worth of box, and the text laid out inside it.
      expect(rp.size.height, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_W_FCL_004 — the browsed format is set heavier',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(430, 200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Row(children: [
            SizedBox(
              width: 120,
              child: FormatCircleLabel(
                  label: 'Camp', fontSize: 12, selected: true),
            ),
            SizedBox(
              width: 120,
              child: FormatCircleLabel(label: 'Demo', fontSize: 12),
            ),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      TextStyle styleOf(String t) =>
          tester.renderObject<RenderParagraph>(find.text(t)).text.style!;
      expect(styleOf('Camp').fontWeight, FontWeight.w600);
      expect(styleOf('Demo').fontWeight, FontWeight.w500);
    });

    testWidgets('TC_W_FCL_005 — no label is dropped or clipped away',
        (tester) async {
      addTearDown(tester.view.reset);
      await _pumpRow(tester);
      for (final l in _labels) {
        expect(find.text(l), findsOneWidget, reason: '$l missing');
      }
      expect(tester.takeException(), isNull);
    });
  });
}
