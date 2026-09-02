import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/data/dummy_data.dart';
import 'package:tlb_mobile_ui/widgets/format_circle_label.dart';

const _kDiameter = 90.0;

List<String> get _labels =>
    DummyData.exploreFormats.map((f) => f['label'] as String).toList();

Future<void> _pumpRow(WidgetTester tester, double screenWidth,
    {double fontSize = 10.5}) async {
  tester.view.physicalSize = Size(screenWidth, 300);
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _labels
              .map((l) => SizedBox(
                    width: _kDiameter,
                    height: _kDiameter,
                    child: Stack(children: [
                      FormatCircleLabel(
                          label: l, diameter: _kDiameter, fontSize: fontSize),
                    ]),
                  ))
              .toList(),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('FormatCircleLabel Tests', () {
    testWidgets('TC_W_FCL_001 — every label ends on the same line',
        (tester) async {
      // The reported defect: one-line names floated at a different height
      // from the two-line ones, so the row never read as aligned.
      addTearDown(tester.view.reset);
      await _pumpRow(tester, 430);
      final bottoms =
          _labels.map((l) => tester.getRect(find.text(l)).bottom).toSet();
      expect(bottoms.length, 1, reason: 'labels sit at $bottoms');
    });

    testWidgets('TC_W_FCL_002 — the type never outgrows its fixed circle',
        (tester) async {
      // Responsive.sp scales with the screen, but the circle does not, so the
      // label is capped. Uncapped, an 11-character word overflows the box and
      // Flutter breaks it mid-word.
      addTearDown(tester.view.reset);
      for (final w in [360.0, 430.0, 720.0]) {
        await _pumpRow(tester, w);
        final style = tester
            .renderObject<RenderParagraph>(find.text('Competition'))
            .text
            .style!;
        expect(style.fontSize, lessThanOrEqualTo(10.5),
            reason: 'font grew to ${style.fontSize} at ${w}px');
      }
    });

    testWidgets('TC_W_FCL_003 — the box is wider than the old 0.14 inset',
        (tester) async {
      // "Competition", "MasterClass" and "Performance" were each a few pixels
      // too wide for the old box, which is what produced "Competiti / on".
      expect(FormatCircleLabel.insetFraction, lessThan(0.14));
      final width = _kDiameter * (1 - 2 * FormatCircleLabel.insetFraction);
      expect(width, greaterThan(78));
    });

    testWidgets('TC_W_FCL_004 — no label is clipped away', (tester) async {
      addTearDown(tester.view.reset);
      await _pumpRow(tester, 430);
      for (final l in _labels) {
        expect(find.text(l), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });
}
