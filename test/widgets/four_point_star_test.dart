import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/four_point_star.dart';

import '../helpers/test_setup.dart';

void main() {
  group('FourPointStar Tests', () {
    testWidgets('TC_W_FPS_001 — renders a CustomPaint', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Center(child: FourPointStar(size: 16, color: Colors.amber)),
        ),
      );
      // The star's own CustomPaint sits under the widget (ignores the
      // framework's ambient CustomPaints elsewhere in the tree).
      expect(
        find.descendant(
          of: find.byType(FourPointStar),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
    });

    testWidgets('TC_W_FPS_002 — occupies the requested square size', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Center(child: FourPointStar(size: 20, color: Colors.amber)),
        ),
      );
      final size = tester.getSize(find.byType(FourPointStar));
      expect(size.width, 20);
      expect(size.height, 20);
    });

    testWidgets('TC_W_FPS_003 — renders without exception for a tiny size', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Center(child: FourPointStar(size: 4, color: Colors.white)),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_W_FPS_004 — renders multiple stars independently', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FourPointStar(size: 14, color: Colors.amber),
              FourPointStar(size: 14, color: Colors.amber),
            ],
          ),
        ),
      );
      expect(find.byType(FourPointStar), findsNWidgets(2));
    });
  });
}
