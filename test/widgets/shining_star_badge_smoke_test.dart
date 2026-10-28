import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tlb_mobile_ui/widgets/shining_star_badge.dart';

void main() {
  testWidgets('ShiningStarBadge builds, loads SVG, and animates without error',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ShiningStarBadge(size: 40)),
        ),
      ),
    );

    // Renders the badge + its SVG.
    expect(find.byType(ShiningStarBadge), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    // Advance the looping shine animation a few frames — must not throw
    // (e.g. non-monotonic gradient stops).
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 2400));
    expect(tester.takeException(), isNull);
  });
}
