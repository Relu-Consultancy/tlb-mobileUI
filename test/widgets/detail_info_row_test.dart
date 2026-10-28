import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/listing_languages.dart';
import 'package:tlb_mobile_ui/widgets/detail_sections.dart';

import '../helpers/test_setup.dart';

/// Bug report: languages added in the Partner Portal ran off the screen in the
/// app's "Things to Know" Language row instead of truncating. The row now
/// clamps to one line with an ellipsis and offers "Show more".
void main() {
  // Many languages plus a long custom "Other" one, built the way the app
  // builds it from the API fields.
  final longLanguages = ListingLanguages.label(
    ['english', 'hindi', 'bengali', 'gujarati', 'marathi', 'tamil', 'telugu',
     'kannada', 'malayalam', 'punjabi', 'other'],
    'Bhojpuri and Maithili (regional dialects)',
  )!;

  Future<void> pumpRow(WidgetTester tester, double width, String value) async {
    await pumpTLBApp(
      tester,
      Scaffold(
        body: Padding(
          // The detail screens' horizontal padding.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DetailInfoRow(
              icon: Icons.translate, label: 'Language', value: value),
        ),
      ),
    );
    // pumpTLBApp fixes a 360px phone; resize to the width under test after it.
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpAndSettle();
  }

  Text valueText(WidgetTester tester, String value) =>
      tester.widget<Text>(find.text(value));

  for (final width in [320.0, 360.0, 393.0, 430.0]) {
    testWidgets(
        'TC_W_DIR_001 — many languages stay inside a ${width.toInt()}px '
        'screen, truncated with an ellipsis', (tester) async {
      await pumpRow(tester, width, longLanguages);

      // Any overflow would already have failed the test; check the clamp too.
      final text = valueText(tester, longLanguages);
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      final rect = tester.getRect(find.text(longLanguages));
      expect(rect.right, lessThanOrEqualTo(width - 16 + 0.5));
      expect(find.text('Show more'), findsOneWidget);
    });
  }

  testWidgets('TC_W_DIR_002 — Show more reveals the full list, Show less folds',
      (tester) async {
    await pumpRow(tester, 360, longLanguages);

    await tester.tap(find.text('Show more'));
    await tester.pumpAndSettle();
    final expanded = valueText(tester, longLanguages);
    expect(expanded.maxLines, isNull, reason: 'wraps onto as many lines as needed');
    expect(tester.getRect(find.text(longLanguages)).right,
        lessThanOrEqualTo(360 - 16 + 0.5));
    expect(find.text('Show less'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pumpAndSettle();
    expect(valueText(tester, longLanguages).maxLines, 1);
  });

  testWidgets('TC_W_DIR_003 — one very long unbroken name is clamped too',
      (tester) async {
    const unbroken = 'SuperLongCustomLanguageNameWithNoSpacesAtAllTypedByAPartner';
    await pumpRow(tester, 320, unbroken);
    expect(tester.getRect(find.text(unbroken)).right,
        lessThanOrEqualTo(320 - 16 + 0.5));
    expect(find.text('Show more'), findsOneWidget);
  });

  // Seen on device: Spacer + Flexible split the free space in half, so every
  // value started at the row's midpoint instead of sitting flush right.
  testWidgets('TC_W_DIR_005 — values sit flush right, not at the midpoint',
      (tester) async {
    for (final value in ['Hindi', '2–12 years', '155 Students']) {
      await pumpRow(tester, 360, value);
      final paragraph =
          tester.renderObject<RenderParagraph>(find.text(value));
      final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: value.length));
      final paintedRight = paragraph.localToGlobal(Offset(boxes.last.right, 0)).dx;
      expect(paintedRight, closeTo(360 - 16, 1.5),
          reason: '"$value" should end at the right edge of the row');
    }
  });

  testWidgets('TC_W_DIR_004 — a short value shows in full, no Show more',
      (tester) async {
    await pumpRow(tester, 360, 'English, Hindi');
    expect(find.text('English, Hindi'), findsOneWidget);
    expect(find.text('Show more'), findsNothing);
  });
}
