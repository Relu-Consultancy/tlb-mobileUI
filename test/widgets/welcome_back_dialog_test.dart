import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/app_colors.dart';
import 'package:tlb_mobile_ui/widgets/login_sheet.dart';

import '../helpers/test_setup.dart';

/// The gradient-filled card at the heart of the dialog.
BoxDecoration _card(WidgetTester tester) {
  final container = tester.widgetList<Container>(find.byType(Container)).firstWhere(
        (c) => c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).gradient != null,
      );
  return container.decoration! as BoxDecoration;
}

Future<void> _open(WidgetTester tester) async {
  await pumpTLBApp(
    tester,
    Scaffold(
      body: Builder(
        builder: (c) => Center(
          child: ElevatedButton(
            onPressed: () => showWelcomeBackDialog(c),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('Welcome Back dialog Tests', () {
    testWidgets('TC_W_WBD_001 — shows the greeting and its CTA', (tester) async {
      await _open(tester);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text("Let's Go!"), findsOneWidget);
    });

    testWidgets('TC_W_WBD_002 — the card wears the app gradient, not violet',
        (tester) async {
      await _open(tester);
      final gradient = _card(tester).gradient! as LinearGradient;
      expect(gradient.colors,
          containsAll([AppColors.headerGradientTop, AppColors.headerGradientBottom]));
      // The hard-coded violet the card used to be.
      expect(gradient.colors, isNot(contains(const Color(0xFF7C3AED))));
    });

    testWidgets('TC_W_WBD_003 — the headline is readable on gold',
        (tester) async {
      // White on this gradient measures ~1.8:1 at the light end; navy is ~11:1.
      await _open(tester);
      final title = tester.widget<Text>(find.text('Welcome Back!'));
      expect(title.style!.color, AppColors.textPrimary);
    });

    testWidgets('TC_W_WBD_004 — the CTA inverts against the card',
        (tester) async {
      await _open(tester);
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text("Let's Go!"),
          matching: find.byType(ElevatedButton),
        ),
      );
      final bg = button.style!.backgroundColor!.resolve({});
      // Gold on gold would vanish.
      expect(bg, AppColors.textPrimary);
      expect(bg, isNot(AppColors.primaryLight));
    });
  });
}
