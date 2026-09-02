import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/app_colors.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';

import '../helpers/test_setup.dart';

/// Finds the decorated box the tag paints its chip with (the outermost
/// Container inside DetailCategoryTag).
BoxDecoration _chipDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(DetailCategoryTag),
      matching: find.byType(Container),
    ).first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('DetailCategoryTag Tests', () {
    testWidgets('TC_W_DCT_001 — renders the label', (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailCategoryTag('Holiday Special Events')),
      );
      expect(find.text('Holiday Special Events'), findsOneWidget);
    });

    testWidgets('TC_W_DCT_002 — chip is a soft wash, not a solid fill',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailCategoryTag('Events')),
      );
      final decoration = _chipDecoration(tester);
      // The point of the Session-66 restyle: the tag must not repaint the
      // saturated CTA yellow it used to wear, and must stay far more
      // transparent than an opaque block.
      expect(decoration.color, isNot(AppColors.primaryLight));
      expect(decoration.color!.opacity, lessThan(0.2));
      expect(decoration.border, isNotNull);
    });

    testWidgets('TC_W_DCT_003 — label stays readable against the wash',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(body: DetailCategoryTag('Events')),
      );
      final text = tester.widget<Text>(find.text('Events'));
      // Amber-on-amber would measure ~2.4:1 against the page; the label is
      // deliberately a dark neutral so it clears the 4.5:1 bar at this size.
      expect(text.style!.color, kDetailText);
      expect(text.style!.fontWeight, FontWeight.w500);
    });

    testWidgets('TC_W_DCT_004 — a long label ellipsizes onto one line',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: DetailCategoryTag(
              'Performing Arts and Creative Expression Workshops'),
        ),
      );
      final text = tester.widget<Text>(
        find.text('Performing Arts and Creative Expression Workshops'),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_W_DCT_005 — hugs its text rather than filling the row',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [DetailCategoryTag('Art')],
          ),
        ),
      );
      final width = tester.getSize(find.byType(DetailCategoryTag)).width;
      final screenWidth = tester.view.physicalSize.width /
          tester.view.devicePixelRatio;
      expect(width, lessThan(screenWidth / 2));
    });
  });
}
