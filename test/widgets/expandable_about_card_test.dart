import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';

import '../helpers/test_setup.dart';

const _kLongBody =
    'A long description that comfortably runs past three lines so the clamp '
    'and the See more toggle are both exercised, well beyond anything a short '
    'one-line summary would ever need to occupy on the detail screen.';

void main() {
  group('ExpandableAboutCard Tests', () {
    testWidgets('TC_W_EAC_001 — renders the title and body', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: ExpandableAboutCard(title: 'About Event', text: 'Art Festival'),
        ),
      );
      expect(find.text('About Event'), findsOneWidget);
      expect(find.text('Art Festival'), findsOneWidget);
    });

    testWidgets('TC_W_EAC_002 — width is fixed, not content-driven',
        (tester) async {
      // The card used to hug its text, so a one-line description produced a
      // narrow card that sat out of line with every other block on the page
      // and changed width from one listing to the next.
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpandableAboutCard(title: 'About Event', text: 'Short'),
              ExpandableAboutCard(title: 'About Event', text: _kLongBody),
            ],
          ),
        ),
      );
      final widths = tester
          .widgetList<ExpandableAboutCard>(find.byType(ExpandableAboutCard))
          .map((w) => tester.getSize(find.byWidget(w)).width)
          .toList();
      expect(widths[0], widths[1]);
      // And it fills the screen rather than stopping at its text.
      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(widths[0], screenWidth);
    });

    testWidgets('TC_W_EAC_003 — a short body shows no See more',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: ExpandableAboutCard(title: 'About Event', text: 'Short'),
        ),
      );
      expect(find.text('See more'), findsNothing);
    });

    testWidgets('TC_W_EAC_004 — a long body clamps to three lines behind '
        'See more', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: ExpandableAboutCard(title: 'About Event', text: _kLongBody),
        ),
      );
      expect(find.text('See more'), findsOneWidget);
      expect(tester.widget<Text>(find.text(_kLongBody)).maxLines, 3);

      await tester.tap(find.text('See more'));
      await tester.pumpAndSettle();
      expect(find.text('See less'), findsOneWidget);
      expect(tester.widget<Text>(find.text(_kLongBody)).maxLines, isNull);
    });
  });
}
