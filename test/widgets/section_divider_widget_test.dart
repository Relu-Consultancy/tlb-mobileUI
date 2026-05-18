import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/section_divider_widget.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SectionDividerWidget Tests', () {
    testWidgets('TC_W_SDW_001 — renders title text', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: SectionDividerWidget(title: 'Top Events')),
      );
      expect(find.text('Top Events'), findsOneWidget);
    });

    testWidgets('TC_W_SDW_002 — renders two gradient line containers', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: SectionDividerWidget(title: 'Events')),
      );
      // Two Expanded children for the left and right gradient lines
      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('TC_W_SDW_003 — title is centre-aligned between two lines', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: SectionDividerWidget(title: 'Venues')),
      );
      final row = tester.widget<Row>(find.byType(Row).first);
      expect(row.children.length, 3); // left line, title, right line
    });

    testWidgets('TC_W_SDW_004 — long title does not overflow', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SectionDividerWidget(
            title: 'Explore the Stage for All Ages and Interests',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_W_SDW_005 — renders with empty string title', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: SectionDividerWidget(title: '')),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
